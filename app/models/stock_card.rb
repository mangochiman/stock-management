class StockCard < ActiveRecord::Base
  self.table_name = "stock_cards"
  self.primary_key = "stock_card_id"
end
