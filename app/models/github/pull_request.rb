module Github
  class PullRequest
    attr_reader :number
    def self.from_message(message)
      self.body = message.body
    end

    def number
      self.pull_request.fetch('number')
    end

    private

    def pull_request
      self.body.fetch('pull_request')
    end

    attr_accessor :body, :pull_request, :number
  end
end
