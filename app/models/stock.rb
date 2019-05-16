class Stock < ActiveRecord::Base
  self.table_name = "stocks"
  self.primary_key = "stock_id"

  has_many :stock_items, :foreign_key => :stock_id
end
