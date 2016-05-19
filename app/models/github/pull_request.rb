module Github
  class PullRequest
    def self.create(branch)
      owner = 'deanmarano'
      repo = 'my-test-repo'
      body = {
        "title": "Amazing new feature",
        "body": "Please pull this in!",
        "head": branch,
        "base": "master"
      }
      Person.first.github_client.post("/repos/#{owner}/#{repo}/pulls", body)
    end
  end
end
