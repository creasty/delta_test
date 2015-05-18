class Post < ActiveRecord::Base

  belongs_to :author, class_name: 'User'
  has_many :comments, dependent: :destroy
  has_many :post_categorizings, dependent: :destroy
  has_many :categories, through: :post_categorizings

end
