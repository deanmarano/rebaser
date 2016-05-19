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
      self.repo.rels[:pulls].get.data
    end

    def approved_pull_requests
      pull_requests.select do |pr|
        pr.rels[:issue].get.data.rels[:labels].get.data.any? do |label|
          label.name == 'Approved'
        end
      end
    end

    def up_to_date_approved_pull_requests
      current_sha = self.current_sha
      approved_pull_requests.select do |pr|
        pr.base.sha == current_sha
      end
    end

    def good_prs
      approved_pull_requests.each do |pr|
        self.client.get("/repos/#{self.full_name}/commits/#{pr.head.ref}/statuses").all? do |status|
          status == 'success'
        end
      end
    end

    def merge_up_to_date_pull_request
      pr_to_merge = good_prs.shift
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
