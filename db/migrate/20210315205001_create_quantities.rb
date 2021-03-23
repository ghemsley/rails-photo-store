class CreateQuantities < ActiveRecord::Migration[6.1]
  def change
    create_table :quantities do |t|
      t.integer :number
      
      t.belongs_to :cart

      t.timestamps
    end
  end
end
