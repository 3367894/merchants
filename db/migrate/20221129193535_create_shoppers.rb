class CreateShoppers < ActiveRecord::Migration[7.0]
  def change
    create_table :shoppers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :nif, null: false

      t.timestamps
    end
  end
end
