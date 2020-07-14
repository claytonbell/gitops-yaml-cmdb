context 'help on how to use this library' do

  describe 'keep your YAML configs DRY, by "include:"-ing multiple YAML files together' do

    let(:result) do
      GitopsCmdb.file_load('spec/fixtures/include_simplest/parent.yaml')
    end

    it 'included files are deep merged' do
      expect(result).to eq({
        'key1' => 'parent',
        'key2' => 'child',
        'both' => 'parent'
      })
    end

    it 'the "include:" key is removed from the final result' do
      expect(result.key?('include')).to be(false)
    end
  end

  describe 'mustache {{ }} templating can be used. Variable names are defined in the "variables:" hash' do

    describe 'static values can be defined' do

      let(:result) do
        GitopsCmdb.file_load('spec/fixtures/variable_simple/file.yaml')
      end

      it 'and the value substituted into the {{ }} mustache placeholder' do
        expect(result).to eq({
          'file' => 'file',
          'variable' => 'value value1 nice'
        })
      end

      it 'the "variables:" key is removed from the final result' do
        expect(result.key?('variables')).to be(false)
      end

    end

    describe 'or use OS environment variables' do

      after(:each) { ENV.delete('OS_ENVIRONMENT_VARIABLE') }

      it 'myValue' do
        ENV['OS_ENVIRONMENT_VARIABLE'] = 'myValue'

        result = GitopsCmdb.file_load('spec/fixtures/variable_os_env/file.yaml')

        expect(result).to eq({
          'file' => 'file',
          'variable' => 'value myValue nice'
        })
      end

      it 'blah snoo foo' do
        ENV['OS_ENVIRONMENT_VARIABLE'] = 'blah snoo foo'

        result = GitopsCmdb.file_load('spec/fixtures/variable_os_env/file.yaml')

        expect(result).to eq({
          'file' => 'file',
          'variable' => 'value blah snoo foo nice'
        })
      end

    end

  end

end