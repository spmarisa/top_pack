class AddACombinedColumnFor < ActiveRecord::Migration
  def change
    add_column :repos, :name_and_owner_name, :string
  end
end
