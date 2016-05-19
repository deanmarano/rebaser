class ReadMessageJob < ActiveJob::Base
  class ManualRebaseNeeded < StandardError; ; end
  class GitPushFailed < StandardError; ; end
  queue_as :default

  def perform(message_id)
    Github::Repo.me.merge_up_to_date_pull_request
  end

  def needs_rebase?(pr, repo)
    p pr.base_sha
    p repo.current_sha
    pr.base_sha != repo.current_sha
  end
end
