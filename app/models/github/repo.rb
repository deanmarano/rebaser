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
      if pr_to_update = self.pull_requests.approved.checks_passed.shift
        merge = self.client.post("/repos/#{self.full_name}/merges", {
          base: pr_to_update.head.ref,
          head: 'master'
        })
        if merge.message = "Merge conflict"
          labels_url = pr_to_update.rels[:issue].get.data.rels[:self].href + "/labels"
          self.client.post(labels_url, [ "Changes Needed" ])
          self.client.delete(labels_url + "/Approved")
        end
      end
    end

    def current_sha
      commits = self.client.repo(self.full_name).rels[:commits].get
      commits.data.first.sha
    end
  end
end
