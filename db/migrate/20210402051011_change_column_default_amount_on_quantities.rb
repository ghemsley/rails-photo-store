class ChangeColumnDefaultAmountOnQuantities < ActiveRecord::Migration[6.1]
  def change
    change_column_default :quantities, :amount, from: nil, to: 0
  end
end
