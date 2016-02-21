class ReadMessageJob < ActiveJob::Base
  class ManualRebaseNeeded < StandardError; ; end
  class GitPushFailed < StandardError; ; end
  queue_as :default

  def perform(message_id)
    message = Message.find(id)
    repo = Git::Repo.new(message.body['repository']['full_name'])
    pr = Github::PullRequest.new(id)

    return if !pr.has_approved_tag?
    repo.pull
    repo.rebase(branch: branch, remote: 'origin', remote_branch: 'master')
    repo.merge(base: master, branch: branch)
  end
end
