class Repo < ActiveRecord::Base
  validates :name, presence: true
  validates :owner_name, presence: true

  has_and_belongs_to_many :packages

  before_validation do |repo|
    repo.name_and_owner_name = repo.name + repo.owner_name
  end

  def self.update_or_import(repo_name, owner_name, packages)
    repo = Repo.includes(:packages).find_or_create_by(name: repo_name, owner_name: owner_name)

    existing_packages = repo.packages.collect(&:name)
    new_packages = packages - existing_packages


    new_packages.each do |f|
      package = Package.find_or_create_by(name: f)
      repo.packages << package
    end
  end
end
