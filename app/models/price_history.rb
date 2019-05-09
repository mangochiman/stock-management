class PriceHistory < ActiveRecord::Base
  self.table_name = "price_histories"
  self.primary_key = "price_history_id"

end
