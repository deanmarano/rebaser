class ReadMessageJob < ActiveJob::Base
  class ManualRebaseNeeded < StandardError; ; end
  class GitPushFailed < StandardError; ; end
  queue_as :default

  def perform(message_id)
    message = Message.find(message_id)
    if message.is_pr?
      pr = Github::PullRequest.from_message(message)
      repo = Github::Repo.new(client, pr.full_name)
      if needs_rebase?(pr, repo)
        repo.rebase_branch(pr. repo.current_sha)
      end
    end
  end

    def needs_rebase?(pr, repo)
      pr.base_sha != repo.current_sha
    end
end
