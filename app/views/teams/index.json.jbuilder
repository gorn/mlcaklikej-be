json.array! @teams.each_with_index.to_a do |team, index|
  json.partial! "teams/team", team: team, poradi: index+1
end