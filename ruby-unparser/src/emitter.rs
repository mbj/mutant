use num_bigint::BigUint;
use ruby_prism::Node;

pub struct Emitter {
    buffer: String,
}

impl Emitter {
    pub fn new() -> Self {
        Self {
            buffer: String::new(),
        }
    }

    pub fn into_output(self) -> String {
        self.buffer
    }

    pub fn emit_node(&mut self, node: Node<'_>) {
        match node {
            Node::IntegerNode { .. } => {
                self.emit_integer(node.as_integer_node().unwrap())
            }
            Node::ProgramNode { .. } => {
                self.emit_program(node.as_program_node().unwrap())
            }
            Node::StatementsNode { .. } => {
                self.emit_statements(node.as_statements_node().unwrap())
            }
            other => panic!("Unsupported node type: {:?}", std::mem::discriminant(&other)),
        }
    }

    fn emit_program(&mut self, node: ruby_prism::ProgramNode<'_>) {
        self.emit_statements(node.statements());
    }

    fn emit_statements(&mut self, node: ruby_prism::StatementsNode<'_>) {
        let mut first = true;
        for statement in &node.body() {
            if !first {
                self.buffer.push('\n');
            }
            first = false;
            self.emit_node(statement);
        }
    }

    fn emit_integer(&mut self, node: ruby_prism::IntegerNode<'_>) {
        let integer = node.value();
        let (negative, digits) = integer.to_u32_digits();

        if negative {
            self.buffer.push('-');
        }

        let value = BigUint::new(digits.to_vec());
        self.buffer.push_str(&value.to_string());
    }
}
