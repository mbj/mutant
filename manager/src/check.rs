use crate::tasks;
use ratatui::{
    TerminalOptions, Viewport,
    crossterm::{
        ExecutableCommand, cursor,
        event::{self, Event, KeyCode, KeyEventKind},
        terminal::{disable_raw_mode, enable_raw_mode},
    },
    prelude::*,
    widgets::{Cell, Row, Table},
};
use std::{
    io::{BufRead, BufReader, stdout},
    process::{Child, Command, Stdio},
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

#[derive(Clone, PartialEq)]
enum TaskStatus {
    Pending,
    Running,
    Success,
    Failed,
}

#[derive(Clone)]
struct TaskState {
    status: TaskStatus,
    last_line: String,
    full_output: Vec<String>,
}

impl Default for TaskState {
    fn default() -> Self {
        Self {
            status: TaskStatus::Pending,
            last_line: String::new(),
            full_output: Vec::new(),
        }
    }
}

struct AppState {
    tasks: Vec<TaskState>,
}

pub fn run() {
    crate::prepare();

    let state = Arc::new(Mutex::new(AppState {
        tasks: vec![TaskState::default(); tasks::ALL.len()],
    }));

    let mut handles: Vec<thread::JoinHandle<()>> = Vec::new();
    let mut children: Vec<Arc<Mutex<Option<Child>>>> = Vec::new();

    for (index, task) in tasks::ALL.iter().enumerate() {
        let state = Arc::clone(&state);
        let child_holder: Arc<Mutex<Option<Child>>> = Arc::new(Mutex::new(None));
        let child_holder_clone = Arc::clone(&child_holder);
        children.push(child_holder);

        let args: Vec<&'static str> = task.args.to_vec();

        let handle = thread::spawn(move || {
            run_task(index, &args, state, child_holder_clone);
        });
        handles.push(handle);
    }

    if let Err(error) = run_tui(Arc::clone(&state)) {
        eprintln!("TUI error: {}", error);
    }

    for child_holder in &children {
        if let Some(ref mut child) = *child_holder.lock().unwrap() {
            let _ = child.kill();
        }
    }

    for handle in handles {
        let _ = handle.join();
    }

    let final_state = state.lock().unwrap();
    let failed_tasks: Vec<_> = tasks::ALL
        .iter()
        .zip(final_state.tasks.iter())
        .filter(|(_, task_state)| task_state.status == TaskStatus::Failed)
        .collect();

    if !failed_tasks.is_empty() {
        println!("\n\x1b[1;31m=== Failed Tasks ===\x1b[0m\n");
        for (task, task_state) in failed_tasks {
            println!("\x1b[1;31m--- {} ---\x1b[0m", task.name);
            for line in &task_state.full_output {
                println!("{}", line);
            }
            println!();
        }
    }

    let failed = final_state
        .tasks
        .iter()
        .any(|t| t.status == TaskStatus::Failed);

    std::process::exit(if failed { 1 } else { 0 });
}

fn run_task(
    index: usize,
    args: &[&str],
    state: Arc<Mutex<AppState>>,
    child_holder: Arc<Mutex<Option<Child>>>,
) {
    {
        let mut state = state.lock().unwrap();
        state.tasks[index].status = TaskStatus::Running;
    }

    let mut child = match Command::new("bundle")
        .arg("exec")
        .args(args)
        .current_dir("ruby")
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
    {
        Ok(child) => child,
        Err(error) => {
            let mut state = state.lock().unwrap();
            state.tasks[index].status = TaskStatus::Failed;
            state.tasks[index].last_line = format!("Failed to spawn: {}", error);
            return;
        }
    };

    let stdout = child.stdout.take();
    let stderr = child.stderr.take();

    *child_holder.lock().unwrap() = Some(child);

    let state_clone = Arc::clone(&state);
    let stdout_handle = stdout.map(|out| {
        let state = Arc::clone(&state_clone);
        thread::spawn(move || {
            let reader = BufReader::new(out);
            for line in reader.lines().map_while(Result::ok) {
                let mut state = state.lock().unwrap();
                state.tasks[index].last_line = line.clone();
                state.tasks[index].full_output.push(line);
            }
        })
    });

    let stderr_handle = stderr.map(|err| {
        let state = Arc::clone(&state);
        thread::spawn(move || {
            let reader = BufReader::new(err);
            for line in reader.lines().map_while(Result::ok) {
                let mut state = state.lock().unwrap();
                state.tasks[index].last_line = line.clone();
                state.tasks[index].full_output.push(line);
            }
        })
    });

    if let Some(handle) = stdout_handle {
        let _ = handle.join();
    }
    if let Some(handle) = stderr_handle {
        let _ = handle.join();
    }

    let exit_status = child_holder
        .lock()
        .unwrap()
        .as_mut()
        .and_then(|c| c.wait().ok());

    let mut state = state.lock().unwrap();
    state.tasks[index].status = match exit_status {
        Some(status) if status.success() => TaskStatus::Success,
        _ => TaskStatus::Failed,
    };
}

fn run_tui(state: Arc<Mutex<AppState>>) -> std::io::Result<()> {
    let num_lines = tasks::ALL.len() as u16 + 2; // +2 for header and spacing

    // Reserve space for our output
    for _ in 0..num_lines {
        println!();
    }
    stdout().execute(cursor::MoveUp(num_lines))?;
    stdout().execute(cursor::SavePosition)?;

    enable_raw_mode()?;

    let mut terminal = Terminal::with_options(
        CrosstermBackend::new(stdout()),
        TerminalOptions {
            viewport: Viewport::Inline(num_lines),
        },
    )?;

    loop {
        terminal.draw(|frame| {
            let state = state.lock().unwrap();
            render(frame, &state);
        })?;

        if event::poll(Duration::from_millis(100))?
            && let Event::Key(key) = event::read()?
            && key.kind == KeyEventKind::Press
            && key.code == KeyCode::Char('q')
        {
            break;
        }

        let state = state.lock().unwrap();
        let all_done = state
            .tasks
            .iter()
            .all(|t| t.status == TaskStatus::Success || t.status == TaskStatus::Failed);
        if all_done {
            drop(state);
            thread::sleep(Duration::from_secs(1));
            break;
        }
    }

    disable_raw_mode()?;
    stdout().execute(cursor::MoveDown(num_lines))?;
    println!();

    Ok(())
}

fn render(frame: &mut Frame, state: &AppState) {
    let rows: Vec<Row> = tasks::ALL
        .iter()
        .zip(state.tasks.iter())
        .map(|(task, task_state)| {
            let status = match task_state.status {
                TaskStatus::Pending => ("⏳", Style::default().fg(Color::Gray)),
                TaskStatus::Running => ("🔄", Style::default().fg(Color::Yellow)),
                TaskStatus::Success => ("✓", Style::default().fg(Color::Green)),
                TaskStatus::Failed => ("✗", Style::default().fg(Color::Red)),
            };

            Row::new(vec![
                Cell::from(status.0).style(status.1),
                Cell::from(task.name),
                Cell::from(truncate_line(&task_state.last_line, 80)),
            ])
        })
        .collect();

    let widths = [
        Constraint::Length(3),
        Constraint::Length(28),
        Constraint::Fill(1),
    ];

    let table = Table::new(rows, widths).header(
        Row::new(vec!["", "Task", "Output"])
            .style(Style::default().bold())
            .bottom_margin(1),
    );

    frame.render_widget(table, frame.area());
}

fn truncate_line(line: &str, max_len: usize) -> String {
    if line.len() > max_len {
        format!("{}...", &line[..max_len - 3])
    } else {
        line.to_string()
    }
}
