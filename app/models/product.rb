class Product < ActiveRecord::Base
  self.primary_key = "product_id"

  has_many :price_histories, :foreign_key => :product_id
  has_many :stock_ins, :foreign_key => :product_id
  has_many :stock_outs, :foreign_key => :product_id

  default_scope {where ("voided = 0")}

  def self.search_products(q)
    products = Product.where(["name LIKE (?)", "%" + q.to_s + "%"]).order("product_id DESC")
    return products
  end

  def price
    price_histories = self.price_histories
    today = Date.today
    current_price = ""
    price_histories.each do |price_history|
      price = price_history.price
      start_date = price_history.start_date.to_date
      end_date = price_history.end_date.to_date

      if end_date.blank?
        if today >= start_date
          current_price = price
          break
        end
      end

      unless end_date.blank?
        if (today >= start_date && today <= end_date)
          current_price = price
          break
        end
      end

    end
    return current_price
  end
end
