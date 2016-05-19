class PullRequest < ActiveRecord::Base
  belongs_to :repository, foreign_key: :repo_id
  serialize :data, Hash
end
