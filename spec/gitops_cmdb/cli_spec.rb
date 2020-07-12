describe GitopsCmdb::CLI do

  before(:each) do
    allow(GitopsCmdb).to receive(:file_load).and_return({'simple' => 'hash'})
  end

  let(:options) do
    {
      input: 'fake.yaml',
      format: 'yaml',
      get: [],
      override: [],
      exec: false
    }
  end

  it 'can output in yaml format' do
    cli = GitopsCmdb::CLI.new(options)

    expect(cli.run).to eq(<<~YAML)
      ---
      simple: hash
YAML
  end

  it 'can output in json format' do
    cli = GitopsCmdb::CLI.new(options.merge(format: 'json'))

    expect(cli.run).to eq('{"simple":"hash"}')
  end

  it 'can output in bash environment variable format' do
    cli = GitopsCmdb::CLI.new(options.merge(format: 'bash'))

    expect(cli.run).to eq("simple='hash'")
  end

  it 'can output in bash export environment variable format' do
    cli = GitopsCmdb::CLI.new(options.merge(format: 'bash-export'))

    expect(cli.run).to eq("export simple='hash'")
  end

end