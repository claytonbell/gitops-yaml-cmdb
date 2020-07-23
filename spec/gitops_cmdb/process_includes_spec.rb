include SpecHelperGitopsCmdb

describe GitopsCmdb::ProcessIncludes do

  subject { GitopsCmdb::ProcessIncludes }

  context 'include file path validation' do

    subject { GitopsCmdb::ProcessIncludes::RelativePath }

    describe 'includes are relative to the yaml file they are in' do

      it 'include file.yaml from folder/root.yaml' do
        expect(
          subject.path_relative_to('folder/root.yaml', 'file.yaml')
        ).to eq('folder/file.yaml')
      end

      it 'include ./file.yaml from folder/root.yaml' do
        expect(
          subject.path_relative_to('folder/root.yaml', 'file.yaml')
        ).to eq('folder/file.yaml')
      end

      it 'include dir/file.yaml from folder/root.yaml' do
        expect(
          subject.path_relative_to('folder/root.yaml', 'dir/file.yaml')
        ).to eq('folder/dir/file.yaml')
      end

      it 'include ../dir/file.yaml from folder/root.yaml' do
        expect(
          subject.path_relative_to('folder/root.yaml', '../dir/file.yaml')
        ).to eq('folder/../dir/file.yaml')
      end

    end

    describe 'raises error when' do

      it 'including an absolute path' do
        expect {
          subject.path_relative_to('root.yaml', '/bad/path/file.yaml')
        }.to raise_error(GitopsCmdb::ProcessIncludes::Error, /must not be absolute.+ Found in file 'root.yaml'/)
      end

    end

  end

  context 'when there are no includes in the parent file' do

    it 'simply loads the parent yaml file like any normal yaml parser' do
      expect(
        subject.recursive_load('spec/fixtures/valid.yaml')
      ).to eq(load_yaml_file('spec/fixtures/valid.yaml'))
    end

  end

  describe 'includes are recursively loaded and deep merged' do

    context 'when a single include path is present in the parent' do

      let(:result) do
        subject.recursive_load('spec/fixtures/include_simplest/parent.yaml')
      end

      it 'loads parent and child keys' do
        expect(result['key1']).to eq('parent')
        expect(result['key2']).to eq('child')
      end

      it 'parent keys override the child keys' do
        expect(result['both']).to eq('parent')
      end

      it 'the include key is removed after processing all the recursive_load paths' do
        expect(result.key?('include')).to be(false)
      end

    end

    context 'parent has two or more includes' do

      let(:result) do
        subject.recursive_load('spec/fixtures/include_nested/parent.yaml')
      end

      it 'the first include takes precedence over later ones' do
        expect(result['child1_child2']).to eq('child1')
      end

    end

    context 'when a child has includes' do

      let(:result) do
        subject.recursive_load('spec/fixtures/include_nested/parent.yaml')
      end

      it 'grandchild keys will also be visable' do
        expect(result['grand_child']).to eq('grand_child')
      end

      it 'parent and child keys also present' do
        expect(result['parent']).to eq('parent')
        expect(result['child1']).to eq('child1')
        expect(result['child2']).to eq('child2')
      end

      it 'parent keys override the grandchild keys' do
        expect(result['parent_grand_child']).to eq('parent')
      end

    end

    context 'when ".." is in the included path' do

      let(:result) do
        subject.recursive_load('spec/fixtures/include_with_dot_dot/dir/parent.yaml')
      end

      it 'parent and child keys present' do
        expect(result['parent']).to eq('parent')
        expect(result['child']).to eq('child')
      end

    end

  end

  context 'include path does not exist' do

    it 'raises error showing the file name that could not be opened' do
      expect {
        subject.recursive_load('spec/fixtures/include_file_not_found/parent.yaml')
      }.to raise_error(Errno::ENOENT, /file_not_found\.yaml/)
    end

  end

  describe 'additional includes' do

    context 'when no additional includes' do

      it 'works like all the other examples' do
        result = subject.recursive_load(
          'spec/fixtures/include_additional/parent.yaml'
        )

        expect(result['parent']).to eq('parent')
        expect(result.key?('additional')).to be(false)
        expect(result['child']).to eq('child')
      end

    end

    context 'with additional includes' do

      it 'extra includes are processed first, then the includes in the file' do
        result = subject.recursive_load(
          'spec/fixtures/include_additional/parent.yaml',
          ['spec/fixtures/include_additional/additional.yaml']
        )

        expect(result['parent']).to eq('parent')
        expect(result['additional']).to eq('additional')
        expect(result['child']).to eq('additional')
      end

    end

  end

end
