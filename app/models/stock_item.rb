class StockItem < ActiveRecord::Base
  self.table_name = "stock_items"
  self.primary_key = "stock_item_id"

  belongs_to :stock, :foreign_key => :stock_id
end
