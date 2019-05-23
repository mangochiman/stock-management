class Debtor < ActiveRecord::Base
  self.table_name = "debtors"
  self.primary_key = "debtor_id"

  def amount_paid
    return 0
  end

  def balance_due
    return 0
  end
end
