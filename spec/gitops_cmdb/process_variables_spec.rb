include SpecHelperGitopsCmdb

describe GitopsCmdb::ProcessVariables do

  subject { GitopsCmdb::ProcessVariables }

  describe 'loading a valid file' do

    context 'when a litteral value used as a variable value' do

      let(:data) do
        subject.translate( load_yaml_file('spec/fixtures/variable_simple/file.yaml') )
      end

      it 'mustache {{ }} parts replaced by the literal value' do
        expect(data['variable']).to eq('value value1 nice')
      end

      it 'plain values are left unchanged' do
        expect(data['file']).to eq('file')
      end
    end

    context 'when OS environment variable used as a variable value' do

      after(:each) do
        ENV.delete('OS_ENVIRONMENT_VARIABLE')
      end

      it 'mustache {{ }} parts replaced by the OS environment variable\'s value' do
        ENV['OS_ENVIRONMENT_VARIABLE'] = 'os_env'

        data = load_yaml_file('spec/fixtures/variable_os_env/file.yaml')

        expect(
          subject.translate(data)
        ).to eq(
          { 'file' => 'file', 'variable' => 'value os_env nice' }
        )
      end

    end

    context 'when including other yaml files' do

      describe 'variable definitions are deep merged/inherited from child files' do

        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/variable_nested_includes/root.yaml')
        end

        it 'variable from the root file' do
          expect(data['var_root']).to eq('varRoot value')
          expect(data['concat_root']).to eq('blah varRoot value snoo')
        end

        it 'variabled defined in child1' do
          expect(data['var_child1']).to eq('varChild1 value')
        end

        it 'variabled defined in child2' do
          expect(data['var_child2']).to eq('varChild2 value')
        end
      end

    end

    context 'when overriding variable values' do

      it 'replaces existing variable value, as if it was defined in the file' do
        data = subject.translate(
          load_yaml_file('spec/fixtures/variable_simple/file.yaml'),
          { 'var1' => 'override blah' }
        )

        expect(data['variable']).to eq('value override blah nice')
      end

    end

    describe 'raises error when' do

      it 'OS environment variable not set or exported' do
        data = load_yaml_file('spec/fixtures/variable_os_env/file.yaml')

        expect {
          subject.translate(data)
        }.to raise_error(
          GitopsCmdb::ProcessVariables::Error,
          /OS Environment variable 'OS_ENVIRONMENT_VARIABLE' not defined/
        )
      end

      it "mustache {{ }} variable used, but not defined in 'variables:' hash" do
        data = load_yaml_file('spec/fixtures/variable_missing/easy.yaml')

        expect {
          subject.translate(data)
        }.to raise_error(
          GitopsCmdb::ProcessVariables::Error,
          /variable name 'bad_var' not defined/
        )
      end

      it "mustache {{ }} variable used, but there are no 'variables:' at all" do
        data = load_yaml_file('spec/fixtures/variable_missing/trivial.yaml')

        expect {
          subject.translate(data)
        }.to raise_error(
          GitopsCmdb::ProcessVariables::Error,
          /variable name 'bad_var' not defined/
        )
      end

    end

    describe 'white space around variable names is ignored' do
      let(:data) do
        GitopsCmdb.file_load('spec/fixtures/variable_simple/white_space.yaml')
      end

      before(:each) { ENV['myOS_variable'] = 'value2' }
      after(:each) { ENV.delete('myOS_variable') }

      it 'mustache variables {{ }}' do
        expect(data['key1']).to eq('blah value1 snoo')
      end

      it 'environment variables ${ }' do
        expect(data['key2']).to eq('blah value2 snoo')
      end
    end

    context 'when the file contains non-string values' do

      describe 'data value type is unchanged' do
        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/fixes/mixed_value_types.yaml')
        end

        it 'integers are integers' do
          expect(data['integer']).to eq(123)
        end

        it 'foats are floats' do
          expect(data['float']).to eq(1.2)
        end

        it 'booleans are booleans' do
          expect(data['bool']).to eq(true)
        end

        it 'nulls are nil' do
          expect(data['null']).to eq(nil)
        end
      end

      describe 'variable value type is unchanged, when mustache templated' do
        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/fixes/mixed_variable_name_types.yaml')
        end

        it 'bool is a string?' # do
        #   puts YAML.safe_load(File.readlines('spec/fixtures/fixes/mixed_variable_name_types.yaml').join("\n"))
        #   expect(data['boolean']).to eq(true)
        # end

        it 'integer is a string?' # do
        #   expect(data['integer']).to eq(4)
        # end
      end

      describe 'nested hash value' do
        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/value_is_an_object/file.yaml')
        end

        it 'mustache templating occurs in simple string values at the root' do
          expect(data['simple']).to eq('string replaced')
        end

        it 'descend recursively and mustache template the nested string values' do
          expect(data['complex']).to eq(
            { 'nested' => 'hashes also replaced' }
          )
        end

      end

    end

  end

end
