class Match < ApplicationRecord
  belongs_to :home_team_record, class_name: "Team", foreign_key: :home_team_id, optional: true
  belongs_to :away_team_record, class_name: "Team", foreign_key: :away_team_id, optional: true

  has_many :predictions, dependent: :destroy

  enum :stage, {
    group_stage: 0,
    second_phase: 1,
    round_of_16: 2,
    quarterfinal: 3,
    semifinal: 4,
    third_place: 5,
    final: 6
  }

  validates :stage, :kickoff_at, presence: true
  validates :home_team, presence: true, unless: :dynamic_home_team?
  validates :away_team, presence: true, unless: :dynamic_away_team?

  validates :home_score, :away_score,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :penalty_winner,
            inclusion: { in: ->(match) { [match.home_team_name, match.away_team_name].compact } },
            allow_nil: true

  scope :ordered, -> { order(:kickoff_at) }

  def locked?
    manually_locked? || kickoff_locked?
  end

  def manually_locked?
    locked_at.present? && locked_at <= Time.current
  end

  def kickoff_locked?
    kickoff_at.present? && kickoff_at <= Time.current
  end

  def finished?
    home_score.present? && away_score.present?
  end

  def draw?
    finished? && home_score == away_score
  end

  def winner
    return nil unless finished?
    return home_team_name if home_score > away_score
    return away_team_name if away_score > home_score

    penalty_winner
  end

  def dynamic_home_team?
    source_home_type.present? && source_home_value.present?
  end

  def dynamic_away_team?
    source_away_type.present? && source_away_value.present?
  end

  def phase_label
    case stage
    when "group_stage" then "Fase de grupos"
    when "second_phase" then "Segunda fase"
    when "round_of_16" then "Oitavas de final"
    when "quarterfinal" then "Quartas de final"
    when "semifinal" then "Semifinal"
    when "third_place" then "Disputa de 3º lugar"
    when "final" then "Final"
    else
      stage.to_s.humanize
    end
  end

  def home_team_name
    home_team_record&.name || home_team
  end

  def away_team_name
    away_team_record&.name || away_team
  end

  def home_team_flag_url
    code = team_code_from_name(home_team_name)
    team_flag_path(code)
  end

  def away_team_flag_url
    code = team_code_from_name(away_team_name)
    team_flag_path(code)
  end

  private

  def team_flag_path(team_code)
    code = team_code.to_s.downcase.strip
    return "https://flagcdn.com/w40/un.png" if code.blank?

    "https://flagcdn.com/w40/#{code}.png"
  end

  def team_code_from_name(name)
    mapping = {
      "Canadá" => "ca",
      "Estados Unidos" => "us",
      "México" => "mx",
      "Arábia Saudita" => "sa",
      "Austrália" => "au",
      "Catar" => "qa",
      "Coreia do Sul" => "kr",
      "Irã" => "ir",
      "Iraque" => "iq",
      "Japão" => "jp",
      "Jordânia" => "jo",
      "Uzbequistão" => "uz",
      "África do Sul" => "za",
      "Argélia" => "dz",
      "Cabo Verde" => "cv",
      "Costa do Marfim" => "ci",
      "Egito" => "eg",
      "Gana" => "gh",
      "Marrocos" => "ma",
      "RD do Congo" => "cd",
      "Senegal" => "sn",
      "Tunísia" => "tn",
      "Argentina" => "ar",
      "Brasil" => "br",
      "Colômbia" => "co",
      "Equador" => "ec",
      "Paraguai" => "py",
      "Uruguai" => "uy",
      "Nova Zelândia" => "nz",
      "Alemanha" => "de",
      "Áustria" => "at",
      "Bélgica" => "be",
      "Bósnia e Herzegovina" => "ba",
      "Croácia" => "hr",
      "Escócia" => "gb-sct",
      "Espanha" => "es",
      "França" => "fr",
      "Holanda" => "nl",
      "Inglaterra" => "gb-eng",
      "Noruega" => "no",
      "Portugal" => "pt",
      "República Tcheca" => "cz",
      "Suécia" => "se",
      "Suíça" => "ch",
      "Turquia" => "tr",
      "Curaçau" => "cw",
      "Haiti" => "ht",
      "Panamá" => "pa"
    }

    mapping[name]
  end
end
