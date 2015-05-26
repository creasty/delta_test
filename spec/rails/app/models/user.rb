class User < ActiveRecord::Base

  #  Associations
  #-----------------------------------------------
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy


  #  Validations
  #-----------------------------------------------
  validates :name,
    presence: true,
    length: { maximum: 100 }

end
