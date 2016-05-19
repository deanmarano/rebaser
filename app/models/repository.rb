class Repository < ActiveRecord::Base
  serialize :data, Hash
  belongs_to :person
  has_many :pull_requests, foreign_key: :repo_id

  def client
    @client ||= self.person.github_client
  end

  def github_repo
    client.repo self.full_name
  end

  def hooks
    github_repo.rels[:hooks].get
  end

  def create_rebaser_hook
    create_hook("web", ["pull_request"], "https://pacific-ocean-45584.herokuapp.com/github/webhooks/")
  end

  def create_hook(name, events, url)
    hook_data = {
      "name": name,
      "active": true,
      "events": events,
      "config": {
        "url": url,
        "content_type": "json"
      }
    }
    client.post(github_repo.rels[:hooks].href,hook_data)
  end
end
