module Github
  class PullRequest
    attr_accessor :body, :pull_request, :number
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

    def base_sha
      @body['pull_request']['base']['sha']
    end

    def head_sha
      @body['pull_request']['head']['sha']
    end

    def ssh_url
      self.repository.fetch('ssh_url')
    end

    def self.token
      ENV['GITHUB_ACCESS_KEY']
    end

    def self.create(branch)
      owner = 'deanmarano'
      repo = 'my-test-repo'
      HTTParty.post("https://api.github.com/repos/#{owner}/#{repo}/pulls",
                    headers: {
                      "Authorization" => "token #{self.token}",
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
      self.pull_request.fetch('_links').fetch('issue').fetch('href')
    end

    def labels
      issue.fetch('labels')
    end

    def issue
      HTTParty.get(issues_url, headers: {
        "Authorization" => "token #{self.class.token}",
        "User-Agent" => "Rebaser",
        "Content-Type" => 'application/json'
      })
    end

    def has_approved_tag?
      labels.find {|tag| tag["name"] }.present?
    end

    def pull_request
      @body.fetch('pull_request')
    end

  end
end
