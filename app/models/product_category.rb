class ProductCategory < ActiveRecord::Base
  self.table_name = "product_categories"
  self.primary_key = "product_category_id"

  belongs_to :category, :foreign_key => :category_id

end
