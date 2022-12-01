class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements do |t|
      t.references :merchant, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.integer :year, null: false
      t.integer :week, null: false

      t.timestamps
    end

    add_index :disbursements, %i[merchant_id year week]
  end
end
