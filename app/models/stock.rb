class Stock < ActiveRecord::Base
  self.table_name = "stocks"
  self.primary_key = "stock_id"

  has_many :stock_items, :foreign_key => :stock_id

  def self.debtors(date = Date.today, stock_id = nil)
    debtors = Debtor.where(["DATE(date) =?", date.to_date])
    total_debt = 0
    debtors.each do |debtor|
      total_debt += debtor.amount_owed.to_i
    end
    return total_debt
  end

  def self.damages_ever
    stock_items = StockItem.all
    total_damaged_stock = 0
    stock_items.each do |stock_item|
      total_damaged_stock += stock_item.damaged_stock.to_i
    end
    return total_damaged_stock
  end

  def self.complementary_ever
    stock_items = StockItem.all
    total_complementary_stock = 0
    stock_items.each do |stock_item|
      total_complementary_stock += stock_item.complementary_stock.to_i
    end
    return total_complementary_stock
  end

end
