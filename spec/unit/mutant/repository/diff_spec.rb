describe Mutant::Repository::Diff do
  describe '#touches?' do
    let(:object) do
      described_class.new(
        config: config,
        from:   'from_rev',
        to:     'to_rev'
      )
    end

    let(:config) do
      instance_double(
        Mutant::Config,
        kernel:   kernel,
        open3:    open3,
        pathname: pathname
      )
    end

    let(:pathname)   { class_double(Pathname, pwd: pwd) }
    let(:open3)      { class_double(Open3)              }
    let(:kernel)     { class_double(Kernel)             }
    let(:pwd)        { Pathname.new('/foo')             }
    let(:path)       { Pathname.new('/foo/bar.rb')      }
    let(:line_range) { 1..2                             }

    subject { object.touches?(path, line_range) }

    shared_context 'test if git tracks the file' do
      # rubocop:disable Lint/UnneededSplatExpansion
      before do
        expect(config.kernel).to receive(:system)
          .ordered
          .with(
            *%W[git ls-files --error-unmatch -- #{path}],
            out: File::NULL,
            err: File::NULL
          ).and_return(git_ls_success?)
      end
    end

    context 'when file is in a different subdirectory' do
      let(:path) { Pathname.new('/baz/bar.rb') }

      before do
        expect(config.kernel).to_not receive(:system)
      end

      it { should be(false) }
    end

    context 'when file is NOT tracked in repository' do
      let(:git_ls_success?) { false }

      include_context 'test if git tracks the file'

      it { should be(false) }
    end

    context 'when file is tracked in repository' do
      let(:git_ls_success?) { true                                                 }
      let(:status)          { instance_double(Process::Status, success?: success?) }
      let(:stdout)          { instance_double(String, empty?: stdout_empty?)       }
      let(:stdout_empty?)   { false                                                }

      include_context 'test if git tracks the file'

      before do
        expect(config.open3).to receive(:capture2)
          .ordered
          .with(*expected_git_log_command, binmode: true)
          .and_return([stdout, status])
      end

      let(:expected_git_log_command) do
        %W[git log from_rev...to_rev -L 1,2:#{path}]
      end

      context 'on failure of git log command' do
        let(:success?) { false }

        it 'raises error' do
          expect { subject }.to raise_error(
            Mutant::Repository::RepositoryError,
            "Command #{expected_git_log_command} failed!"
          )
        end
      end

      context 'on suuccess of git command' do
        let(:success?) { true }

        context 'on empty stdout' do
          let(:stdout_empty?) { true }

          it { should be(false) }
        end

        context 'on non empty stdout' do
          let(:stdout_empty?) { false }

          it { should be(true) }
        end
      end
    end
  end
end
