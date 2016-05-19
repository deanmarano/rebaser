namespace :github do
  task :check_branches => :environment do
    Github::Repo.me.merge_up_to_date_pull_request
  end
end
