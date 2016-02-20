require 'date'
require 'pry'

class Github
  def create_commit(name)
    File.open('./spec/my-test-repo/file.txt', 'w') do |file|
      file.write name
    end
    `git add -A`
    `git commit -m 'Github::create_commit-#{name}'`
  end

  def create_branch(name)
    `git checkout -b Github::create_branch-#{name}`
  end

  def push
    `git push`
  end

  def update_master
    `git checkout master && git pull`
  end
end
