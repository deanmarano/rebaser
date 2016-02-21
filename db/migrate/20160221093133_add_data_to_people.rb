class AddDataToPeople < ActiveRecord::Migration
  def change
    add_column :people, :data, :string
  end
end
