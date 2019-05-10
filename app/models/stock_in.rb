class StockIn < ActiveRecord::Base
  self.table_name = "stock_ins"
  self.primary_key = "stock_in_id"
end
