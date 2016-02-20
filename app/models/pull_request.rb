class PullRequest < ActiveRecord::Base
  serialize :data, Hash
end
