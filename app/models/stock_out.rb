class StockOut < ActiveRecord::Base
  self.table_name = "stock_outs"
  self.primary_key = "stock_out_id"
end
