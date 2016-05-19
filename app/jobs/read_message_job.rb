class ReadMessageJob < ActiveJob::Base
  class ManualRebaseNeeded < StandardError; ; end
  class GitPushFailed < StandardError; ; end
  queue_as :default

  def perform(message_id)
    Github::Repo.me.merge_up_to_date_pull_request
    #message = Message.find(message_id)
    #if message.is_pr?
      #pr = Github::PullRequest.from_message(message)
      #repo = Github::Repo.new(Person.last.github_client, pr.full_name)
      #if needs_rebase?(pr, repo)
        #repo.rebase_branch(pr, repo.current_sha)
      #end
    #end
  end

  def needs_rebase?(pr, repo)
    p pr.base_sha
    p repo.current_sha
    pr.base_sha != repo.current_sha
  end
end
