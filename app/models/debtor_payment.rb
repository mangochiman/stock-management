class DebtorPayment < ActiveRecord::Base
  self.table_name = "debtor_payments"
  self.primary_key = "debtor_payment_id"

  belongs_to :debtor, :foreign_key => :debtor_id
  validates_presence_of :amount_paid
  validates_numericality_of :amount_paid
end
