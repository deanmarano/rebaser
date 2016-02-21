module Github
  class Repo
    attr_reader :client, :full_name

    def self.me(repo = 'deanmarano/my-test-repo')
      self.new Person.first.github_client, repo
    end

    def initialize(client, full_name)
      @client = client
      @full_name = full_name
    end

    def current_sha
      commits = self.client.repo(self.full_name).rels[:commits].get
      commits.data.first.sha
    end

    def rebase_branch(branch_name, sha)
      repo = self.github_client.repo self.full_name
      repo.
      new_sha = branch_ref = repo.rels[:git_refs].get(ref: "heads/#{branch}")
      branch_ref.rels[:self].patch({
        sha: new_sha,
        force: true
      })
    end
  end
end
