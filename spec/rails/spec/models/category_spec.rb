describe Category do

  it 'should be able to create new model' do
    expect{ Category.new(name: 'test').test }.not_to raise_error
  end

end
