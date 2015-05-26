class Comment < ActiveRecord::Base

  #  Associations
  #-----------------------------------------------
  belongs_to :post
  belongs_to :user


  #  Validations
  #-----------------------------------------------
  validates_associated :post
  validates_associated :user

  validates :post, presence: true
  validates :user, presence: true
  validates :body,
    presence: true,
    length: { maximum: 1000 }

end
