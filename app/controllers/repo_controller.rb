class RepoController < ApplicationController
  def search
    @query = params["query"]

    if @query
      github_response = HTTParty.get("https://api.github.com/search/repositories?q=#{@query}")


      a_proc = proc { |x| OpenStruct.new(name: x["name"],
                                         description: x["description"],
                                         html_url: x["html_url"],
                                         owner_name: x["owner"]["login"],
                                         name_and_owner_name: x["name"] + x["owner"]["login"],
                                         forks: x["forks"],
                                         stars: x["stargazers_count"]) }

      @github_response = github_response["items"].collect { |x| a_proc.call(x) }


      all_owner_names = @github_response.collect(&:name_and_owner_name)
      existing_owner_names = Repo.where(name_and_owner_name: all_owner_names).collect(&:name_and_owner_name)

      @existing_repos_hash = Hash[ *existing_owner_names.collect { |v| [ v, true ] }.flatten ]
    end
  end

  def import
    # binding.pry
    repo_name, owner_name = params["name"], params["owner_name"]
    response = HTTParty.get("https://api.github.com/repos/#{owner_name}/#{repo_name}/contents/package.json")

    @content = []
    if response.code == 200
      json_content = JSON.parse(Base64.decode64(response["content"]))
      dependencies = json_content['dependencies'].try(:keys) || []
      dev_dependencies = json_content['devDependencies'].try(:keys) || []

      @content = dependencies + dev_dependencies
    end

    Repo.delay.update_or_import(repo_name, owner_name, @content)
  end

  def top_packages
    @packages = Package.joins("LEFT OUTER JOIN `packages_repos` ON `packages`.`id` = `packages_repos`.`package_id`")
               .group(:id)
               .order('COUNT(packages_repos.package_id) DESC')
               .order('id DESC')
               .limit(10)

    @counts = @packages.count
  end
end
