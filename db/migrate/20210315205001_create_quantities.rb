class CreateQuantities < ActiveRecord::Migration[6.1]
  def change
    create_table :quantities do |t|
      t.belongs_to :product
      t.belongs_to :user
      t.integer :amount, default: 0

      t.timestamps
    end
  end
end
