class Category < ActiveRecord::Base

  #  Associations
  #-----------------------------------------------
  has_many :post_categorizings, dependent: :destroy


  #  Validations
  #-----------------------------------------------
  validates :name,
    presence: true,
    length: { maximum: 100 }

end
