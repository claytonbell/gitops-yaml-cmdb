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

    context 'when a file contains values of mixed types' do

      describe 'variable values and data values are not strings' do
        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/fixes/mixed_value_types.yaml')
        end

        it 'integers are converted to strings' do
          expect(data['integer']).to eq('123')
        end

        it 'foats are converted to strings' do
          expect(data['float']).to eq('1.2')
        end

        it 'booleans are converted to strings' do
          expect(data['bool']).to eq('true')
        end

        it 'nulls are converted to EMPTY strings' do
          expect(data['null']).to eq('')
        end
      end

      describe 'variable name not a string' do
        let(:data) do
          GitopsCmdb.file_load('spec/fixtures/fixes/mixed_variable_name_types.yaml')
        end

        it 'integers are converted to strings' do
          expect(data).to eq({ 'a' => 'very true' })
        end
      end

    end

  end

end
