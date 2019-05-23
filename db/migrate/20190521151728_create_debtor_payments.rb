class CreateDebtorPayments < ActiveRecord::Migration
  def change
    create_table :debtor_payments, :primary_key => :debtor_payment_id do |t|
      t.float :amount_paid
      t.date :date_paid
      t.integer :debtor_id
      t.timestamps null: false
    end
  end
end
