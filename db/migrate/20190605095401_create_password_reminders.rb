class CreatePasswordReminders < ActiveRecord::Migration
  def change
    create_table :password_reminders, :primary_key => :password_reminder_id do |t|
      t.integer :user_id
      t.string :password
      t.string :salt
      t.integer :voided, :default => 0
      t.timestamps null: false
    end
  end
end
