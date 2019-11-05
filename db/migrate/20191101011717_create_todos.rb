class CreateTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :todos, :name
  end
end
