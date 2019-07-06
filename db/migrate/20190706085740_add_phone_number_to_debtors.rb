class AddPhoneNumberToDebtors < ActiveRecord::Migration
  def change
    add_column :debtors, :phone_number, :string
  end
end
