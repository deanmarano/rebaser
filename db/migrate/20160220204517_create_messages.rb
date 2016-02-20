class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :body
      t.string :headers

      t.timestamps null: false
    end
  end
end