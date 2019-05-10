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

  def total_stock_ins
    sum = 0
    self.stock_ins.each {|stock_in| sum += stock_in.quantity.to_i}
    return sum
  end

  def total_stock_outs
    sum = 0
    self.stock_outs.each {|stock_out| sum += stock_out.quantity.to_i}
    return sum
  end

  def current_stock
    starting_inventory = self.starting_inventory.to_i
    available_stock = (starting_inventory + total_stock_ins) - total_stock_outs
    return available_stock
  end

  def self.incoming_stock_by_date_range(start_date, end_date)
    incoming_stock_by_range = StockIn.where(["DATE(date_in) >= ? AND DATE(date_in) <= ?", start_date.to_date, end_date.to_date])
    return incoming_stock_by_range
  end

  def self.outgoing_stock_by_date_range(start_date, end_date)
    outgoing_stock_by_range = StockOut.where(["DATE(date_out) >= ? AND DATE(date_out) <= ?", start_date.to_date, end_date.to_date])
    return outgoing_stock_by_range
  end

  def self.running_out_of_stock
    running_out_of_stock_products = []
    all_products = self.all
    all_products.each do |product|
      current_stock = product.current_stock
      if current_stock > 0 && current_stock <= product.minimum_required
        running_out_of_stock_products << product
      end
    end

    return running_out_of_stock_products
  end

  def self.products_not_in_stock
    not_in_stock_products = []
    all_products = self.all
    all_products.each do |product|
      current_stock = product.current_stock
      if current_stock <= 0
        not_in_stock_products << product
      end
    end

    return not_in_stock_products
  end

  def self.products_with_enough_stock
    products_with_enough_stock = []
    all_products = self.all
    all_products.each do |product|
      current_stock = product.current_stock
      if current_stock > product.minimum_required
        products_with_enough_stock << product
      end
    end

    return products_with_enough_stock
  end

end
