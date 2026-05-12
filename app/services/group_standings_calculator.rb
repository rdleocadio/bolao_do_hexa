class GroupStandingsCalculator
  TeamStats = Struct.new(
    :team,
    :played,
    :wins,
    :draws,
    :losses,
    :goals_for,
    :goals_against,
    :goal_difference,
    :points,
    keyword_init: true
  )

  def self.call(group_code)
    new(group_code).call
  end

  def initialize(group_code)
    @group_code = group_code
  end

  def call
    manual_standings = manual_standings_for_group

    return manual_standings if manual_standings.any?

    automatic_standings
  end

  def automatic_standings
    stats = build_initial_stats

    finished_matches.each do |match|
      home_name = match.home_team_name
      away_name = match.away_team_name

      home = stats[home_name]
      away = stats[away_name]

      next if home.blank? || away.blank?

      update_played(home, away)
      update_goals(home, away, match)
      update_results(home, away, match)
      update_goal_difference(home)
      update_goal_difference(away)
    end

    apply_tiebreakers(stats.values)
  end

  private

  attr_reader :group_code

  def manual_standings_for_group
    GroupStandingOverride
      .where(group_code: group_code)
      .order(:position)
      .map do |standing|
        TeamStats.new(
          team: standing.team_name,
          played: standing.played || 0,
          wins: standing.wins || 0,
          draws: standing.draws || 0,
          losses: standing.losses || 0,
          goals_for: standing.goals_for || 0,
          goals_against: standing.goals_against || 0,
          goal_difference: standing.goal_difference || 0,
          points: standing.points || 0
        )
      end
  end

  def matches
    @matches ||= Match.where(stage: :group_stage, group_code: group_code).order(:kickoff_at)
  end

  def finished_matches
    matches.select(&:finished?)
  end

  def teams
    @teams ||= matches
      .flat_map { |match| [match.home_team_name, match.away_team_name] }
      .compact
      .reject { |team| team == "A definir" }
      .uniq
      .sort
  end

  def build_initial_stats
    teams.each_with_object({}) do |team, hash|
      hash[team] = TeamStats.new(
        team: team,
        played: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        goals_for: 0,
        goals_against: 0,
        goal_difference: 0,
        points: 0
      )
    end
  end

  def update_played(home, away)
    home.played += 1
    away.played += 1
  end

  def update_goals(home, away, match)
    home.goals_for += match.home_score
    home.goals_against += match.away_score

    away.goals_for += match.away_score
    away.goals_against += match.home_score
  end

  def update_results(home, away, match)
    if match.home_score > match.away_score
      home.wins += 1
      home.points += 3
      away.losses += 1
    elsif match.home_score < match.away_score
      away.wins += 1
      away.points += 3
      home.losses += 1
    else
      home.draws += 1
      away.draws += 1
      home.points += 1
      away.points += 1
    end
  end

  def update_goal_difference(team)
    team.goal_difference = team.goals_for - team.goals_against
  end

  def apply_tiebreakers(teams_stats)
    grouped_by_points = teams_stats.group_by(&:points)

    grouped_by_points.keys.sort.reverse.flat_map do |points|
      tied_teams = grouped_by_points[points]

      if tied_teams.size == 2
        sort_two_team_tie(tied_teams)
      else
        fallback_sort(tied_teams)
      end
    end
  end

  def sort_two_team_tie(tied_teams)
    team_a, team_b = tied_teams

    head_to_head_match = find_head_to_head_match(team_a.team, team_b.team)

    if head_to_head_match.present?
      winner = head_to_head_winner(head_to_head_match)

      return [team_a, team_b] if winner == team_a.team
      return [team_b, team_a] if winner == team_b.team
    end

    fallback_sort(tied_teams)
  end

  def fallback_sort(teams_stats)
    teams_stats.sort_by do |team|
      [
        -team.points,
        -team.goal_difference,
        -team.goals_for,
        team.team
      ]
    end
  end

  def find_head_to_head_match(team_a, team_b)
    finished_matches.find do |match|
      home_name = match.home_team_name
      away_name = match.away_team_name

      (home_name == team_a && away_name == team_b) ||
        (home_name == team_b && away_name == team_a)
    end
  end

  def head_to_head_winner(match)
    return match.home_team_name if match.home_score > match.away_score
    return match.away_team_name if match.away_score > match.home_score

    nil
  end
end
