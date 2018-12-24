# frozen_string_literal: true

RSpec.describe Mutant::Loader, '.call' do
  subject do
    described_class.call(
      binding: binding,
      kernel:  kernel,
      source:  source,
      subject: mutation_subject
    )
  end

  let(:path)     { instance_double(Pathname, to_s: path_str) }
  let(:path_str) { instance_double(String)                   }
  let(:line)     { instance_double(0.class)                  }
  let(:kernel)   { class_double(Kernel)                      }
  let(:binding)  { instance_double(Binding)                  }
  let(:source)   { instance_double(String)                   }
  let(:node)     { instance_double(Parser::AST::Node)        }

  let(:mutation_subject) do
    instance_double(
      Mutant::Subject,
      source_path: path,
      source_line: line
    )
  end

  it 'performs expected kernel interaction' do
    expect(kernel).to receive(:eval)
      .with(
        "# frozen_string_literal: true\n#[InstanceDouble(String) (anonymous)]",
        binding,
        path_str,
        line
      )

    subject
  end
end
