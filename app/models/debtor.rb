class Debtor < ActiveRecord::Base
  self.table_name = "debtors"
  self.primary_key = "debtor_id"

  has_many :debtor_payments, :foreign_key => :debtor_id

  def amount_paid
    debtor_payments = self.debtor_payments
    total_amount_paid = 0
    debtor_payments.each do |debtor_payment|
      amount_paid = debtor_payment.amount_paid.to_f
      total_amount_paid += amount_paid
    end
    return total_amount_paid
  end

  def balance_due
    amount_owed = self.amount_owed.to_f
    debtor_payments = self.debtor_payments
    total_amount_paid = 0

    debtor_payments.each do |debtor_payment|
      amount_paid = debtor_payment.amount_paid.to_f
      total_amount_paid += amount_paid
    end

    balance = amount_owed - total_amount_paid
    return 0 if balance < 0
    return balance

  end

  def self.total_un_paid_debt(date)
    debtors = Debtor.where(["DATE(date) = ?", date.to_date])
    total_amount_owed = 0
    total_amount_paid = 0

    debtors.each do |debtor|
      debtor_payments = debtor.debtor_payments
      amount_owed = debtor.amount_owed.to_f
      total_amount_owed += amount_owed
      debtor_payments.each do |debtor_payment|
        amount_paid = debtor_payment.amount_paid.to_f
        total_amount_paid += amount_paid
      end
    end

    amount_remaining = total_amount_owed - total_amount_paid
    return 0 if amount_remaining < 0
    return amount_remaining
  end

  def self.total_ever_un_paid_debt
    total_unpaid = 0
    debtors = Debtor.all

    debtors.each do |debtor|
      debtor_payments = debtor.debtor_payments
      amount_owed = debtor.amount_owed.to_f
      total_amount_paid = 0

      debtor_payments.each do |debtor_payment|
        amount_paid = debtor_payment.amount_paid.to_f
        total_amount_paid += amount_paid
      end

      amount_remaining = amount_owed - total_amount_paid
      if amount_remaining > 0
        total_unpaid += 1
      end
    end

    return total_unpaid
  end


end
