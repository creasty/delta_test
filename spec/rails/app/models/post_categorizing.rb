class PostCategorizing < ActiveRecord::Base

  #  Associations
  #-----------------------------------------------
  belongs_to :post
  belongs_to :category


  #  Validations
  #-----------------------------------------------
  validates_associated :post
  validates_associated :category

end
