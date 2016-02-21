module Github
  def self.client
    @@client ||= Octokit::Client.new(
      :client_id     => "6afa887e592f003fda15",
      :client_secret => '780e29772d9205cf2cb186dea27ea1a18ecfc2de'
    )
  end
end
