RSpec.describe Mutant do
  let(:object) { described_class }

  describe '.ci?' do
    subject { object.ci? }

    let(:result) { double('Result') }

    before do
      expect(ENV).to receive(:key?).with('CI').and_return(result)
    end

    it { should be(result) }
  end

  describe '.zombify' do
    subject { object.zombify }

    it 'calls the zombifier' do
      expect(Mutant::Zombifier).to receive(:run).with('mutant', :Zombie)
      subject
    end
  end

  describe '.singleton_subclass_instance' do
    subject { object.singleton_subclass_instance(name, superclass, &block) }

    before { subject }

    let(:name)       { 'Test'                }
    let(:block)      { proc { def foo; end } }
    let(:superclass) { Class.new             }

    let(:generated) { superclass.const_get(:Test) }

    it_should_behave_like 'a command method'

    it 'sets expected name' do
      name = generated.class.name
      expect(name).to eql("::#{self.name}")
      expect(name).to be_frozen
    end

    it 'stores instance of subclass' do
      expect(generated).to be_kind_of(superclass)
    end

    it 'evaluates the context of proc inside subclass' do
      expect(generated).to respond_to(:foo)
    end

    it 'generates nice #inspect' do
      inspect = generated.inspect
      expect(inspect).to eql("::#{self.name}")
      expect(inspect).to be_frozen
    end
  end
end
