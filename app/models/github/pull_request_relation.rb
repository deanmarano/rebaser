class Github::PullRequestRelation < Array
  def initialize(repo, prs)
    @repo = repo
    self.concat(prs)
  end

  def approved
    self.class.new(@repo, self.select do |pr|
      labels = pr.rels[:issue].get.data.rels[:labels].get.data
      labels.any? {|l| l.name == 'Approved'} && labels.none? {|l| l.name == 'Changes Needed'}
    end)
  end

  def up_to_date(current_sha)
    self.class.new(@repo, self.select do |pr|
      pr.base.sha == current_sha
    end)
  end

  def checks_passed
    self.class.new(@repo, self.select do |pr|
      checks = pr.rels[:statuses].get.data
      checks.select { |c| c.context == 'ci/circleci' }.sort_by(&:updated_at).last.state == 'success'
    end)
  end
end
