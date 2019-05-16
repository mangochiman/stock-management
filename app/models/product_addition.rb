class ProductAddition < ActiveRecord::Base
  self.table_name = "product_additions"
  self.primary_key = "product_addition_id"

  belongs_to :product, :foreign_key => :product_id
end
