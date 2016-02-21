class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.integer :person_id
      t.string :full_name
      t.string :ssh_url
      t.string :data

      t.timestamps null: false
    end
  end
end
