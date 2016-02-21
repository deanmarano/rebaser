module Github
  class PullRequest
    attr_reader :number
    def self.from_message(message)
      self.new(message.body)
    end

    def initialize(body = {})
      self.body = body
    end

    def number
      self.pull_request.fetch('number')
    end

    def repo
      self.body.fetch('repo')
    end

    def ssh_url
      self.repo.fetch('ssh_url')
    end

    def self.create(branch)
      owner = 'deanmarano'
      repo = 'my-test-repo'
      token = ENV['GITHUB_ACCESS_KEY']
      HTTParty.post("https://api.github.com/repos/#{owner}/#{repo}/pulls",
                    headers: {
                      "Authorization" => "token #{token}",
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

    private

    def pull_request
      self.body.fetch('pull_request')
    end

    attr_accessor :body, :pull_request, :number
  end
end
