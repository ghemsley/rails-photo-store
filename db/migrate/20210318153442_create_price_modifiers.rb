class CreatePriceModifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :price_modifiers do |t|
      t.decimal :number
      t.string :unit

      t.belongs_to :dimension

      t.timestamps
    end
  end
end
