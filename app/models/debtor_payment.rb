class DebtorPayment < ActiveRecord::Base
  self.table_name = "debtor_payments"
  self.primary_key = "debtor_payment_id"
end
