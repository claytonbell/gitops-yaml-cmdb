require 'gitops_cmdb/cli'

describe GitopsCmdb::CLI do

  let(:options) do
    {
      input: 'fake.yaml',
      format: 'yaml',
      get: [],
      override: [],
      include: [],
      exec: false
    }
  end

  context 'selecting different output formats' do

    before(:each) do
      allow(GitopsCmdb).to receive(:file_load).and_return( { 'simple' => 'hash' } )
    end

    it 'yaml' do
      cli = GitopsCmdb::CLI.new(options)

      expect(cli.run).to eq(<<~YAML)
        ---
        simple: hash
        YAML
    end

    it 'json' do
      cli = GitopsCmdb::CLI.new(options.merge(format: 'json'))

      expect(cli.run).to eq('{"simple":"hash"}')
    end

    it 'bash environment variable' do
      cli = GitopsCmdb::CLI.new(options.merge(format: 'bash'))

      expect(cli.run).to eq("simple='hash'")
    end

    it 'export bash environment variable' do
      cli = GitopsCmdb::CLI.new(options.merge(format: 'bash-export'))

      expect(cli.run).to eq("export simple='hash'")
    end

  end

  context 'include an additional file' do
    it 'extra file is loaded as if its the first include in the list' do
      cli = GitopsCmdb::CLI.new(
        options.merge(
          input: 'spec/fixtures/include_additional/parent.yaml',
          include: 'spec/fixtures/include_additional/additional.yaml'
        )
      )

      expect(cli.run).to eq(<<~YAML)
        ---
        child: additional
        extra: child
        additional: additional
        parent: parent
        YAML
    end
  end
end
