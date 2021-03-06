class Person < ActiveRecord::Base
  serialize :data, Hash
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, :omniauth_providers => [:github]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.extra.raw_info.login
      user.password = Devise.friendly_token[0,20]
      user.data = auth
    end
  end

  def github_client
    @client ||= Octokit::Client.new(access_token: token)
  end

  def token
    self.data.credentials.token
  end
end
