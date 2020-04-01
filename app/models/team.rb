class Team < ApplicationRecord
  has_many :sessions

  def click_count
    self.sessions.sum{ |s| s.click_count}
  end

  def self.leaderboard
    Team.all.sort_by{ |team| team.click_count }.reverse
  end
end
