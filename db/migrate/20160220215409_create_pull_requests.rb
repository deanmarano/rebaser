class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.string :repo_id
      t.string :owner_id
      t.string :status
      t.string :data

      t.timestamps null: false
    end
  end
end
