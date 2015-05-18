class Category < ActiveRecord::Base

  has_many :post_categorizings, dependent: :destroy

end
