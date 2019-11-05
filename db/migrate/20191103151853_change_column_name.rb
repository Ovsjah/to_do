class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :todos, :name, :title
  end
end
