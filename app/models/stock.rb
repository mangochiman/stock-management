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

end
