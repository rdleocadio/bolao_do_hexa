module TeamsHelper
  def translated_team_name(team_name)
    return t("matches.to_be_defined") if team_name.blank?

    key = team_name.parameterize(separator: "_")

    t("teams.names.#{key}", default: team_name)
  end
end
