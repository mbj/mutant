pub struct Task {
    pub name: &'static str,
    pub args: &'static [&'static str],
}

pub const RSPEC_SPEC_UNIT: Task = Task {
    name: "rspec spec-unit",
    args: &["rspec", "spec/unit"],
};

pub const MUTANT_TEST: Task = Task {
    name: "mutant test",
    args: &["mutant", "test", "spec/unit"],
};

pub const MUTANT_RUN: Task = Task {
    name: "mutant run",
    args: &["mutant", "run"],
};

pub const RSPEC_INTEGRATION_MISC: Task = Task {
    name: "rspec integration-misc",
    args: &[
        "rspec",
        "spec/integration/mutant/null_spec.rb",
        "spec/integration/mutant/isolation/fork_spec.rb",
        "spec/integration/mutant/test_mutator_handles_types_spec.rb",
        "spec/integration/mutant/parallel_spec.rb",
    ],
};

pub const RSPEC_INTEGRATION_MINITEST: Task = Task {
    name: "rspec integration-minitest",
    args: &["rspec", "spec/integration", "-e", "minitest"],
};

pub const RSPEC_INTEGRATION_RSPEC: Task = Task {
    name: "rspec integration-rspec",
    args: &["rspec", "spec/integration", "-e", "rspec"],
};

pub const RSPEC_INTEGRATION_GENERATION: Task = Task {
    name: "rspec integration-generation",
    args: &["rspec", "spec/integration", "-e", "generation"],
};

pub const RUBOCOP: Task = Task {
    name: "rubocop",
    args: &["rubocop"],
};

pub const ALL: &[&Task] = &[
    &RSPEC_SPEC_UNIT,
    &MUTANT_TEST,
    &RSPEC_INTEGRATION_MISC,
    &RSPEC_INTEGRATION_MINITEST,
    &RSPEC_INTEGRATION_RSPEC,
    &RSPEC_INTEGRATION_GENERATION,
    &RUBOCOP,
];
