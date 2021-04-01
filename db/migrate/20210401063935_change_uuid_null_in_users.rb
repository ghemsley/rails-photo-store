class ChangeUuidNullInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:users, :uuid, true)
  end
end
