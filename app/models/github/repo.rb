module Github
  class Repo
    attr_reader :client, :full_name

    def self.me(repo = "deanmarano/my-test-repo")
      self.new Person.first.github_client, repo
    end

    def initialize(client, full_name)
      @client = client
      @full_name = full_name
    end

    def repo
      self.client.repo self.full_name
    end

    def pull_requests
      Github::PullRequestRelation.new(self, self.repo.rels[:pulls].get.data)
    end

    def merge_up_to_date_pull_request
      pr_to_merge = self.pull_requests.approved.up_to_date(self.current_sha).checks_passed.shift
      if pr_to_merge.present?
        base_url = pr_to_merge._links.to_hash[:self].attrs[:href]
        self.client.put(base_url + "/merge", { sha: pr_to_merge.head.sha })
        self.client.delete("/repos/#{self.full_name}/git/refs/heads/#{pr_to_merge.head.ref}")
      end
      if pr_to_update = good_prs.shift || approved_pull_requests.shift
        self.client.post("/repos/#{self.full_name}/merges", {
          base: pr_to_update.head.ref,
          head: 'master'
        })
      end
    end

    def current_sha
      commits = self.client.repo(self.full_name).rels[:commits].get
      commits.data.first.sha
    end
  end
end
