class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles, :primary_key => :user_role_id do |t|
      t.integer :user_id
      t.string :role
      t.timestamps null: false
    end
  end
end
