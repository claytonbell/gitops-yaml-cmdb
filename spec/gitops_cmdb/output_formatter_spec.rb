describe GitopsCmdb::OutputFormatter do

  subject { GitopsCmdb::OutputFormatter }

  it 'formatter can tell us what formats it support' do
    expect(
      subject.supported_types.sort
    ).to eq(
      %w[bash bash-export json keys yaml]
    )
  end

  context 'valid format types' do

    let(:data) { { 'key' => 'value' } }

    it 'yaml' do
      format = subject.new('yaml')
      expect(format.render(data)).to eq(<<~YAML)
        ---
        key: value
        YAML
    end

    it 'json' do
      format = subject.new('json')
      expect(format.render(data)).to eq('{"key":"value"}')
    end

    it 'bash' do
      format = subject.new('bash')
      expect(format.render(data)).to eq("key='value'")
    end

    it 'bash-export' do
      format = subject.new('bash-export')
      expect(format.render(data)).to eq("export key='value'")
    end

    it 'keys' do
      format = subject.new('keys')
      expect(format.render(data)).to eq('key')
    end

  end

  context 'unsupported format' do

    it 'raises error' do
      expect {
        subject.new('bad_format')
      }.to raise_error(GitopsCmdb::OutputFormatter::Error, /'bad_format' invalid/)
    end

  end

  context 'bash escaping' do

    let(:format) { subject.new('bash') }

    describe 'environment variable name' do

      it 'unsupported characters are replaced by _' do
        strange_key_name = '.KEY!'

        expect(
          format.render( { strange_key_name => 'value' } )
        ).to eq("_KEY_='value'")
      end

    end

    describe 'environment variable value' do

      it 'single quote is escaped with backlash' do
        value_with_single_quotes = " it\'s a lovely day."

        expect(
          format.render( { 'key' => value_with_single_quotes } )
        ).to eq("key=' it\\'s a lovely day.'")
      end

    end

  end

end
