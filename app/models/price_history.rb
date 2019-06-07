class PriceHistory < ActiveRecord::Base
  self.table_name = "price_histories"
  self.primary_key = "price_history_id"

  belongs_to :product, :foreign_key => :product_id
  validates_presence_of :price
  validates_numericality_of :price
  def self.set_price_end_dates(product_id, end_date)
    product = Product.find(product_id)
    product_price_histories = product.price_histories.where(["end_date IS NULL"])
    product_price_histories.each do |price_history|
      price_history.end_date = end_date.to_date
      price_history.save
    end
  end

end
