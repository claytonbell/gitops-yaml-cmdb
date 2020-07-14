describe GitopsCmdb::DataLoader do

  subject { GitopsCmdb::DataLoader }

  let(:data) do
    {
      'trivial' => 'file',
      'valid'  => true
    }
  end

  let(:error) { GitopsCmdb::DataLoader::Error }

  context 'read and parse a yaml file from the local filesystem' do
    it 'by filesystem path' do
      expect(subject.file('spec/fixtures/valid.yaml')).to eq(data)
    end

    it 'file extension can be .yml or .yaml' do
      expect(subject.file('spec/fixtures/valid.yaml')).to eq(data)
      expect(subject.file('spec/fixtures/valid.yml')).to eq(data)
    end
  end

  context 'raises error when' do
    it 'file not found' do
      expect { subject.file('spec/file_not_exist.yaml') }.to raise_error(Errno::ENOENT)
    end

    it 'can not parse yaml file' do
      expect { subject.file('spec/fixtures/invalid.yaml') }.to raise_error(Psych::SyntaxError)
    end

    it 'file name extension is not .yml or .yaml' do
      expect { subject.file('file.json') }.to raise_error(error)
    end
  end

end