class ProductAddition < ActiveRecord::Base
  self.table_name = "product_additions"
  self.primary_key = "product_addition_id"

  validates_presence_of :added_stock
  validates_numericality_of :added_stock
  belongs_to :product, :foreign_key => :product_id
end
