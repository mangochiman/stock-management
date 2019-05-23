class CreateDebtors < ActiveRecord::Migration
  def change
    create_table :debtors, :primary_key => :debtor_id do |t|
      t.string :name
      t.float :amount_owed
      t.string :description
      t.date :date
      t.integer :stock_id
      t.timestamps null: false
    end
  end
end
