class PriceHistory < ActiveRecord::Base
  self.table_name = "price_histories"
  self.primary_key = "price_history_id"

  belongs_to :product, :foreign_key => :product_id
end
