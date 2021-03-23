class CreateDiscounts < ActiveRecord::Migration[6.1]
  def change
    create_table :discounts do |t|
      t.integer :percentage
      t.integer :times_applied
      t.integer :max_applications

      t.belongs_to :order
      t.belongs_to :user

      t.timestamps
    end
  end
end
