module Git
  class Repo
    class CantFindBranch < StandardError; ; end
    class RemoteConnectionError < StandardError; ; end
    class ManualRebaseNeeded < StandardError; ; end
    attr_reader :git_url

    def self.test_repo
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

    def on_branch(branch, &block)
      in_repo do
        `git checkout #{branch}`
        if $?.exitstatus != 0
          raise CantFindBranch
        end
      end
    end

    def pull
      on_branch 'master' do
        `git pull`
        if $?.exitstatus != 0
          raise RemoteConnectionError
        end
      end
    end

    def new_pr
      name = Time.now.to_i
      branch_name = create_branch(name)
      create_commit(name)
      push(branch_name)
      create_pr(branch_name)
      pull
    end

    def merge(base:, branch:)
      on_branch base do
        `git merge #{branch}`
        if $?.exitstatus != 0
          `git merge --abort`
          raise ManualMergeNeeded
        end
        push(branch)
      end
    end

    def rebase(branch:, remote:, remote_branch:)
      on_branch branch do
        `git pull --rebase #{remote} #{remote_branch}`
        if $?.exitstatus != 0
          `git rebase --abort`
          raise ManualRebaseNeeded
        end
        push(branch, force: true)
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

    def push(branch, options = {})
      on_branch branch do
        if options[:force]
          `git push --force`
        else
          `git push`
        end
        if $?.exitstatus != 0
          raise RemoteConnectionError
        end
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
  end
end
