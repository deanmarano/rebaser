module Github
  class PullRequest
    attr_reader :number, :body
    def self.from_message(message)
      self.new(message.body)
    end

    def initialize(body = {})
      @body = body
    end

    def number
      self.pull_request.fetch('number')
    end

    def repository
      @body.fetch('repository')
    end

    def ssh_url
      self.repository.fetch('ssh_url')
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

    def issues_url
      pull_request.fetch('_links').fetch('issue')
      @body.fetch('pull_request').fetch('_links').fetch('issue').fetch('href')
    end

    def has_approved_tag?
      HTTParty.get(issues_url, headers: {
        "Authorization" => "token #{token}",
        "User-Agent" => "Rebaser",
        "Content-Type" => 'application/json'
      })
    end

    private

    def pull_request
      @body.fetch('pull_request')
    end

    attr_accessor :body, :pull_request, :number
  end
end
