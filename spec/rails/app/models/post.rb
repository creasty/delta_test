class Post < ActiveRecord::Base

  #  Associations
  #-----------------------------------------------
  belongs_to :author, class_name: 'User'
  has_many :comments, dependent: :destroy
  has_many :post_categorizings, dependent: :destroy
  has_many :categories, through: :post_categorizings


  #  Validations
  #-----------------------------------------------
  validates_associated :author

  validates :author, presence: true
  validates :title,
    presence: true,
    length: { maximum: 100 }
  validates :body,
    presence: true,
    length: { maximum: 1000 }

end
