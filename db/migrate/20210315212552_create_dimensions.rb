class CreateDimensions < ActiveRecord::Migration[6.1]
  def change
    create_table :dimensions do |t|
      t.decimal :width
      t.decimal :length
      t.decimal :height
      t.decimal :weight
      t.string :distance_unit
      t.string :weight_unit

      t.belongs_to :product

      t.timestamps
    end
  end
end
