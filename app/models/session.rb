class Session < ApplicationRecord
  belongs_to :team

  def self.suggest_random_sessions_string
    rand(36**20).to_s(36)
  end
end
