class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :primary_key => :user_id do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :email
      t.string :password
      t.string :secret_question
      t.string :secret_answer
      t.string :salt
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps
    end
  end
end
