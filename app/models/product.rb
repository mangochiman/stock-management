class Product < ActiveRecord::Base
  self.primary_key = "product_id"
  self.table_name = "products"

  has_many :price_histories, :foreign_key => :product_id
  has_many :stock_ins, :foreign_key => :product_id
  has_many :stock_outs, :foreign_key => :product_id
  has_many :stock_cards, :foreign_key => :product_id
  has_many :product_additions, :foreign_key => :product_id
  has_many :stock_items, :foreign_key => :product_id
  has_one :product_category, :foreign_key => :product_id

  validates_uniqueness_of :name
  validates_presence_of :name, :starting_inventory
  default_scope {where ("voided = 0")}

  def self.search_products(q)
    products = Product.where(["name LIKE (?)", "%" + q.to_s + "%"]).order("product_id DESC")
    return products
  end

  def category_name
    product_category_name = self.product_category.category.name rescue nil
    product_category_name
  end

  def self.standard_items
    standard_category_id = Category.find_by_name("Standard").category_id
    standard_products = Product.joins([:product_category]).where(["category_id =?", standard_category_id])
    return standard_products
  end

  def self.non_standard_items
    non_standard_category_id = Category.find_by_name("Non standard").category_id
    non_standard_products = Product.joins([:product_category]).where(["category_id =?", non_standard_category_id])
    return non_standard_products
  end

  def price(today = Date.today)
    today = today.to_date
    price_histories = self.price_histories.order("DATE(start_date) DESC")
    current_price = ""
    price_histories.each do |price_history|
      price = price_history.price
      start_date = price_history.start_date.to_date
      end_date = price_history.end_date.to_date rescue nil

      if end_date.blank?
        if today >= start_date
          current_price = price
          break
        end
      end

      unless end_date.blank?
        if (today.to_date >= start_date && today <= end_date)
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

  def current_stock(date = Date.today, stock_id = nil)
    opening_stock = self.opening_stock_by_date(date, stock_id)
    added_stock = self.added_stock_by_date(date, stock_id)
    closed_stock = self.closed_stock_by_date(date, stock_id)
    current_stock_on_date = (opening_stock + added_stock)
    return current_stock_on_date
  end

  def self.incoming_stock_by_date_range(start_date, end_date)
    incoming_stock_by_range = StockIn.where(["DATE(date_in) >= ? AND DATE(date_in) <= ?", start_date.to_date, end_date.to_date])
    return incoming_stock_by_range
  end

  def get_incoming_stock_report(start_date, end_date)
    incoming_stocks = self.stock_ins.where(["DATE(date_in) >= ? AND DATE(date_in) <= ?", start_date.to_date, end_date.to_date])
    return incoming_stocks
  end

  def get_outgoing_stock_report(start_date, end_date)
    incoming_stocks = self.stock_outs.where(["DATE(date_out) >= ? AND DATE(date_out) <= ?", start_date.to_date, end_date.to_date])
    return incoming_stocks
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

  def stock_card_by_date(date)
    self.stock_cards.where(["DATE(date) =?", date.to_date]).last
  end

  def opening_stock_by_date(date, stock_id = nil)
    latest_closing_value = StockItem.joins(:stock).where(["product_id =? AND closing_stock is NOT NULL AND DATE(stock_time) <= ? ",
                                                          self.product_id, date.to_date]).order("stocks.stock_id DESC").first
    if stock_id.blank?
      if latest_closing_value.blank?
        return self.starting_inventory
      else
        latest_closing_value.closing_stock
      end
    else
      stock_item = StockItem.where(["stock_id =? AND product_id =?", stock_id, self.product_id]).last
      unless stock_item.blank?
        return stock_item.opening_stock
      else
        if latest_closing_value.blank?
          return self.starting_inventory
        else
          latest_closing_value.closing_stock
        end
      end
    end
  end

  def added_stock_by_date(date, stock_id = nil)
    product_additions = self.product_additions.where(["DATE(date_added) =?", date.to_date])
    sum = 0
    product_additions.each do |prediction|
      sum += prediction.added_stock.to_i
    end
    return sum
  end

  def closed_stock_by_date(date, stock_id = nil)
    closing_value_by_date = StockItem.joins(:stock).where(["product_id =? AND closing_stock is NOT NULL AND DATE(stock_time) = ? ",
                                                           self.product_id, date.to_date]).order("stocks.stock_id DESC").first
    if stock_id.blank?
      if closing_value_by_date.blank?
        return 0
      else
        closing_value_by_date.closing_stock.to_i
      end
    else
      stock_item = StockItem.where(["stock_id =? AND product_id =?", stock_id, self.product_id]).last
      unless stock_item.blank?
        return stock_item.closing_stock
      else
        if closing_value_by_date.blank?
          return 0
        else
          closing_value_by_date.closing_stock.to_i
        end
      end
    end

  end

  def shots_by_date(date, stock_id = nil)
    stock_items = StockItem.joins(:stock).where(["product_id =? AND shots_sold is NOT NULL AND
      DATE(stock_time) = ? ", self.product_id, date.to_date])
    sum = 0

    if stock_id.blank?
      stock_items.each do |stock_item|
        sum += stock_item.shots_sold.to_i
      end
      return sum
    else
      stock_items = StockItem.where(["stock_id =? AND product_id =? AND shots_sold is NOT NULL", stock_id, self.product_id])
      unless stock_items.blank?
        stock_items.each do |stock_item|
          sum += stock_item.shots_sold.to_i
        end
        return sum
      else
        return 0
      end
    end
  end

  def stock_closed?(stock_id)
    self.stock_items.where(["stock_id =?", stock_id]).last.closing_stock rescue nil
  end

  def shots_sold?(stock_id)
    self.stock_items.where(["stock_id =?", stock_id]).last.shots_sold rescue nil
  end

  def damaged_stock(stock_id)
    self.stock_items.where(["stock_id =?", stock_id]).last.damaged_stock rescue nil
  end

  def complementary_stock(stock_id)
    self.stock_items.where(["stock_id =?", stock_id]).last.complementary_stock rescue nil
  end

  def self.stock_stats_by_date(date, stock_id = nil)

    if stock_id.blank?
      stock_items = StockItem.joins(:stock).where(["DATE(stock_time) = ? ", date.to_date])
    else
      stock_items = StockItem.where(["stock_id =?", stock_id])
    end
    total_sales = 0
    complementary_total = 0
    damages_total = 0

    stock_items.each do |stock_item|
      stock_id = stock_item.stock_id
      product = Product.find(stock_item.product_id)
      current_price = product.price(date).to_f
      current_stock = product.current_stock(date, stock_id).to_i
      damaged_stock = product.damaged_stock(stock_id).to_i
      complementary_stock = product.complementary_stock(stock_id).to_i
      closing_stock = product.closed_stock_by_date(date, stock_id).to_i

      difference = current_stock - closing_stock
      total_sales += current_price * (difference.to_i - damaged_stock.to_i - complementary_stock.to_i)
      complementary_total += current_price * complementary_stock
      damages_total += current_price * damaged_stock
    end

    data = {"total_sales" => total_sales, "complementary_total" => complementary_total, "damages_total" => damages_total}
    return data
  end

  def self.stock_stats_by_date_and_product(date, product)
    stock_items = StockItem.joins(:stock).where(["DATE(stock_time) = ? AND product_id =?", date.to_date, product.product_id])
    total_sales = 0
    complementary_total = 0
    damages_total = 0

    stock_items.each do |stock_item|
      stock_id = stock_item.stock_id
      product = Product.find(stock_item.product_id)
      current_price = product.price(date)
      current_stock = product.current_stock(date, stock_id).to_i
      damaged_stock = product.damaged_stock(stock_id).to_i
      complementary_stock = product.complementary_stock(stock_id).to_i
      closing_stock = product.closed_stock_by_date(date, stock_id).to_i

      difference = current_stock - closing_stock
      total_sales += current_price * (difference.to_i - damaged_stock.to_i - complementary_stock.to_i)
      complementary_total += current_price * complementary_stock
      damages_total += current_price * damaged_stock
    end

    data = {"total_sales" => total_sales, "complementary_total" => complementary_total, "damages_total" => damages_total}
    return data
  end


end
