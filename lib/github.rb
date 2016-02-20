require 'date'
require 'pry'
require 'httparty'

class Github
  def new_pr
    name = Time.now.to_i
    branch_name = create_branch(name)
    create_commit(name)
    push
    create_pr(branch_name)
    update_master
  end

  def in_repo(&block)
    current_wd = Dir.pwd
    wd = "./spec/my-test-repo"
    Dir.chdir wd
    yield
    Dir.chdir current_wd
  end

  def create_commit(name)
    in_repo do
      File.open("file.txt", 'w') do |file|
        file.write name
      end
      `git add -A`
      `git commit -m 'Github::create_commit-#{name}'`
    end
  end

  def create_branch(name)
    branch_name = "Github-create_branch-#{name}"
    in_repo do
      `git checkout -b #{branch_name}`
    end
    branch_name
  end

  def push
    in_repo do
      `git push`
    end
  end

  def create_pr(branch)
    owner = 'deanmarano'
    repo = 'my-test-repo'
    HTTParty.post("https://api.github.com/repos/#{owner}/#{repo}/pulls",
                  headers: {
                    "Authorization" => "token ff3864a7ca119627030e867dceda5638ca4eacb8",
                    "User-Agent" => "Rebaser",
                    "Content-Type" => 'application/json'
                  },
                  body: JSON.generate({
                    "title": "Amazing new feature",
                    "body": "Please pull this in!",
                    "head": branch,
                    "base": "master"
                  }))
  end

  def update_master
    in_repo do
      `git checkout master && git pull`
    end
  end
end
