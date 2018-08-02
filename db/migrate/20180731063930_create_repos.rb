class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name
      t.string :owner_name

      t.timestamps null: false
    end
  end
end
