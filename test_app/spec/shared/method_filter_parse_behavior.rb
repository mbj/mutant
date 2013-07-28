shared_examples_for 'a method filter parse result' do
  before do
    expected_class.stub(:new => response)
  end

  let(:response) { double('Response') }

  it { should be(response) }

  it 'should initialize method filter with correct arguments' do
    expected_class.should_receive(:new)
      .with(TestApp::Literal, :string)
      .and_return(response)
    subject
  end
end
