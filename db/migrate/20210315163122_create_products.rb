class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.text :tags
      t.decimal :price
      t.string :price_unit

      t.belongs_to :category

      t.timestamps
    end
  end
end
