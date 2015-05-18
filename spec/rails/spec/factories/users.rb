FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| 'User %d' % n }
  end
end
