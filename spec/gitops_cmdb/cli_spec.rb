require 'gitops_cmdb/cli'

describe GitopsCmdb::CLI do

  subject { GitopsCmdb::CLI }

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
      cli = subject.new(options)

      expect(cli.run).to eq(<<~YAML)
        ---
        simple: hash
        YAML
    end

    it 'json' do
      cli = subject.new(options.merge(format: 'json'))

      expect(cli.run).to eq('{"simple":"hash"}')
    end

    it 'bash environment variable' do
      cli = subject.new(options.merge(format: 'bash'))

      expect(cli.run).to eq("simple='hash'")
    end

    it 'export bash environment variable' do
      cli = subject.new(options.merge(format: 'bash-export'))

      expect(cli.run).to eq("export simple='hash'")
    end

  end

  context 'include an additional file' do
    it 'extra file is loaded as if its the first include in the list' do
      cli = subject.new(
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

  context 'override variables' do
    it 'value can be set, as if it was in the file' do
      cli = subject.new(
        options.merge(
          input: 'spec/fixtures/variable_simple/file.yaml',
          override: ['var1=blah snoo']
        )
      )

      expect(cli.run).to eq(<<~YAML)
        ---
        file: file
        variable: value blah snoo nice
        YAML
    end
  end

  context 'specific list of data keys to get' do
    it 'whitelist of keys to display' do
      cli = subject.new(
        options.merge(
          input: 'spec/fixtures/include_simplest/parent.yaml',
          get: %w[key1 key2]
        )
      )

      expect(cli.run).to eq(<<~YAML)
        ---
        key1: parent
        key2: child
        YAML
    end

    it 'defaults to returning all key/values' do
      cli = subject.new(
        options.merge(
          input: 'spec/fixtures/include_simplest/parent.yaml',
          get: []
        )
      )

      expect(cli.run).to eq(<<~YAML)
        ---
        key2: child
        both: parent
        key1: parent
        YAML
    end

    it 'unknown key to get raises error' do
      cli = subject.new(
        options.merge(
          input: 'spec/fixtures/include_simplest/parent.yaml',
          get: ['bad_key_name']
        )
      )

      expect { cli.run }.to raise_error(
        subject::Error,
        %r{key name 'bad_key_name' not found when loading file 'spec/fixtures/include_simplest/parent.yaml'}
      )
    end
  end

end
