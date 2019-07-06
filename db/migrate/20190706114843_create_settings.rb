class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings, :primary_key => :setting_id do |t|
      t.string :property
      t.string :value
      t.timestamps null: false
    end
  end
end
