class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories, :primary_key => :category_id do |t|
      t.string :name
      t.integer :voided, :default => 0
      t.integer :voided_by
      t.date :date_voided
      t.timestamps null: false
    end
  end
end
