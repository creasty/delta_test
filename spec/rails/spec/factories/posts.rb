FactoryGirl.define do
  factory :post do
    author nil
    sequence(:title) { |n| 'Post title %d' % n }
    body 'Here goes body'
  end
end
