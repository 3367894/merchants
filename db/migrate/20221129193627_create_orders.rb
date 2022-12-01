class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :merchant, null: false
      t.references :shopper, null: false
      t.integer :amount_cents, null: false
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
