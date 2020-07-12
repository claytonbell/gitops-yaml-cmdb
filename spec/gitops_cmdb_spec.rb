context 'help on how to use this library' do

  let(:result) do
    GitopsCmdb.file_load('spec/fixtures/include_simplest/parent.yaml')
  end

  it 'load a yaml file, also load the "include" yaml files and deep merges the result' do
    expect(result).to eq({
      'key1' => 'parent',
      'key2' => 'child',
      'both' => 'parent'
    })
  end

  it 'the "include" key is removed once all the files have been loaded' do
    expect(result.has_key?('include')).to be(false)
  end
end