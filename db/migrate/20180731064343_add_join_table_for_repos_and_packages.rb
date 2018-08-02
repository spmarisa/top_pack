class AddJoinTableForReposAndPackages < ActiveRecord::Migration
  def change
    create_table :packages_repos, id: false do |t|
      t.belongs_to :package, index: true
      t.belongs_to :repo, index: true
    end
  end
end
