context 'help on how to use this library' do

  it 'recursively loads yaml files via the "include" key and deep merges the result' do
    expect(
      GitopsCmdb.file_load('spec/fixtures/include_simplest/parent.yaml')
    ).to eq({
      'key1' => 'parent',
      'key2' => 'child',
      'both' => 'parent'
    })
  end

end