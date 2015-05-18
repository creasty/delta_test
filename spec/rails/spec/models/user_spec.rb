describe User do

  describe '.create' do

    it 'should be a validation error without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end

    it 'should create a user with a name' do
      name = 'John Smith'
      user = build(:user, name: name)
      user.save
      expect(user).to be_persisted
      expect(user.name).to eq(name)
    end

  end

end
