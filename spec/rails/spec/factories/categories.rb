FactoryGirl.define do
  factory :category do
    sequence(:name) { |n| 'Category %d' % n }
  end
end
