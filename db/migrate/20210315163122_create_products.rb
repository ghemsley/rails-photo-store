class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :price_unit

      t.belongs_to :category
      t.belongs_to :quantity

      t.timestamps
    end
  end
end
