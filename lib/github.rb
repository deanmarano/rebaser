require 'date'
require 'pry'
require 'httparty'

module Git
  class Repository
    attr_reader :git_url

    def self.my_test_repo
      load './lib/github.rb'
      self.new("git@github.com:deanmarano/my-test-repo.git")
    end

    def initialize(git_url)
      @git_url = git_url
      # Example: git://github.com/deanmarano/my-test-repo.git
      # git@github.com/deanmarano/my-test-repo.git
    end

    def chdir(dir, &block)
      current_dir = Dir.pwd
      Dir.chdir dir
      yield
      Dir.chdir current_dir
    end

    def path
      "repos/#{owner}/#{name}"
    end

    def git_config_path
      path + "/.git/config"
    end

    def clone
      `mkdir -p repos/#{self.owner}`
      chdir "repos/#{self.owner}" do
        `git clone #{self.git_url}`
      end
    end

    def owner
      self.git_url.split(/[\/:]/)[1]
    end

    def name
      self.git_url.split(/[\/:]/)[2][0...-4]
    end

    def in_repo(&block)
      clone if !Dir.exist?(self.path) || !File.exist?(self.git_config_path)
      chdir self.path do
        yield
      end
    end

    def rebase(remote, branch)
      in_repo do
        `git pull --rebase #{remote} #{branch}`
      end
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
end
