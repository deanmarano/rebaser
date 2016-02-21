class ReadMessageJob < ActiveJob::Base
  class ManualRebaseNeeded < StandardError; ; end
  class GitPushFailed < StandardError; ; end
  queue_as :default

  def perform(message_id)
    message = Message.find(message_id)
    if message.is_pr?
      pr = Github::PullRequest.from_message(message)
      repo = Github::Repo.new(
      repo = Git::Repo.new(pr.ssh_url)

      if pr.needs_rebase?(pr, repo)
        #GET /repos/:owner/:repo/commits
        repo.create_tree(base, pr)
        repo.tags
        update_ref sha
      end
  end

    def needs_rebase?(pr, repo)
      pr.base_sha != repo.current_sha
    end
end
