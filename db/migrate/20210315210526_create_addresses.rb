class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :street_line1
      t.string :street_line2
      t.string :city
      t.string :state
      t.string :province
      t.string :country
      t.string :postal_code
      t.string :phone_number

      t.belongs_to :user

      t.timestamps
    end
  end
end
