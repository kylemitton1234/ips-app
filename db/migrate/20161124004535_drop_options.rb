class DropOptions < ActiveRecord::Migration[5.0]
  def change
    drop_table :options
  end
end
