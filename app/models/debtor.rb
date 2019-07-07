class Debtor < ActiveRecord::Base
  self.table_name = "debtors"
  self.primary_key = "debtor_id"

  has_many :debtor_payments, :foreign_key => :debtor_id
  validates_presence_of :name
  validates_presence_of :amount_owed
  validates_numericality_of :amount_owed

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

  def self.total_debts_by_date(date)
    debtors = Debtor.where(["DATE(date) = ?", date.to_date])
    total_amount_owed = 0

    debtors.each do |debtor|
      amount_owed = debtor.amount_owed.to_f
      total_amount_owed += amount_owed
    end

    return total_amount_owed
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

  def self.unpaid_debts_records
    debtors = Debtor.all
    debts = []
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
        debts << debtor
      end
    end

    return debts
  end

  def self.overdue_debtors(today = Date.today)
    today = today.to_date
    debt_payment_period = Setting.find_by_property("debt.payment.period").value.to_i rescue nil
    return [] if debt_payment_period.blank?
    unpaid_debtors = self.unpaid_debts_records
    overdue_debtors_list = []
    unpaid_debtors.each do |debtor|
      debt_date = debtor.date.to_date
      days_gone = (today - debt_date).to_i
      if days_gone > debt_payment_period
        overdue_debtors_list << debtor
      end
    end

    return overdue_debtors_list
  end

end
