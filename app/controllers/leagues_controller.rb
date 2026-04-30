class LeaguesController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user

    @leagues = League.joins(:league_memberships)
                     .where(league_memberships: {
                       user_id: current_user.id,
                       status: LeagueMembership.statuses[:approved]
                     })
                     .includes(:owner, :league_memberships)
                     .distinct

    @predictions = current_user.predictions.includes(:match)
    @total_points = @predictions.sum(&:points)

    @league_positions = {}

    @leagues.each do |league|
      ranking = build_league_ranking(league)
      position = ranking.find_index { |entry| entry[:user].id == current_user.id }
      @league_positions[league.id] = position.present? ? position + 1 : "-"
    end
  end

  def discover
    @query = params[:query].to_s.strip
    @leagues = League.includes(:owner, :league_memberships)

    if @query.present?
      @leagues = @leagues.where(
        "name ILIKE :query OR code ILIKE :query",
        query: "%#{@query}%"
      )
    end

    @leagues = @leagues.order(:name)
  end

  def show
    @league = League.find(params[:id])

    @approved_memberships = @league.league_memberships.approved.includes(:user).order(:created_at)
    @pending_memberships = @league.league_memberships.pending.includes(:user).order(:created_at)

    @ranking = build_league_ranking(@league)

    @current_membership = @league.league_memberships.find_by(user: current_user)
    @is_owner = @league.owner == current_user

    @upcoming_matches = Match.where(home_score: nil, away_score: nil)
                             .ordered
                             .limit(10)

    @user_position = nil

    if @current_membership&.approved?
      position = @ranking.find_index { |entry| entry[:user].id == current_user.id }
      @user_position = position.present? ? position + 1 : nil
    end
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(league_params)
    @league.owner = current_user

    if @league.save
      LeagueMembership.create!(
        user: current_user,
        league: @league,
        role: :owner,
        status: :approved
      )

      redirect_to @league, notice: "Liga criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join
    @league = League.find(params[:id])
    membership = @league.league_memberships.find_by(user: current_user)

    if membership.present?
      handle_existing_membership(@league, membership)
      return
    end

    status = @league.private? ? :pending : :approved

    LeagueMembership.create!(
      user: current_user,
      league: @league,
      role: :member,
      status: status
    )

    if @league.private?
      redirect_to @league, notice: "Solicitação de entrada enviada com sucesso."
    else
      redirect_to @league, notice: "Você entrou na liga com sucesso."
    end
  end

  def join_by_code
    code = params[:code].to_s.strip.upcase
    league = League.find_by("UPPER(code) = ?", code)

    if league.nil?
      redirect_to discover_leagues_path, alert: "Liga não encontrada com esse código."
      return
    end

    membership = league.league_memberships.find_by(user: current_user)

    if membership.present?
      handle_existing_membership(league, membership)
      return
    end

    status = league.private? ? :pending : :approved

    LeagueMembership.create!(
      user: current_user,
      league: league,
      role: :member,
      status: status
    )

    if league.private?
      redirect_to league_path(league), notice: "Solicitação enviada com sucesso."
    else
      redirect_to league_path(league), notice: "Você entrou na liga com sucesso."
    end
  end

  private

  def build_league_ranking(league)
    approved_users = league.league_memberships
                           .approved
                           .includes(user: { avatar_attachment: :blob })
                           .map(&:user)

    approved_users.map do |user|
      predictions = user.predictions.includes(:match)

      exact_scores = 0
      partial_scores = 0
      winners = 0
      errors = 0
      points = 0

      predictions.each do |prediction|
        match = prediction.match

        next unless match.present?
        next unless match.finished?
        next if match.home_score.nil? || match.away_score.nil?
        next if prediction.home_score.nil? || prediction.away_score.nil?

        home_prediction = prediction.home_score
        away_prediction = prediction.away_score
        home_real = match.home_score
        away_real = match.away_score

        if exact_score?(home_prediction, away_prediction, home_real, away_real)
          exact_scores += 1
          points += 5
        elsif partial_score?(home_prediction, away_prediction, home_real, away_real)
          partial_scores += 1
          points += 4
        elsif winner_or_draw?(home_prediction, away_prediction, home_real, away_real)
          winners += 1
          points += 3
        else
          errors += 1
        end
      end

      {
        user: user,
        points: points,
        exact_scores: exact_scores,
        partial_scores: partial_scores,
        winners: winners,
        errors: errors
      }
    end.sort_by do |entry|
      [
        -entry[:points],
        -entry[:exact_scores],
        -entry[:partial_scores],
        -entry[:winners],
        entry[:errors]
      ]
    end
  end

  def exact_score?(home_prediction, away_prediction, home_real, away_real)
    home_prediction == home_real && away_prediction == away_real
  end

  def partial_score?(home_prediction, away_prediction, home_real, away_real)
    home_prediction == home_real || away_prediction == away_real
  end

  def winner_or_draw?(home_prediction, away_prediction, home_real, away_real)
    prediction_result = match_result(home_prediction, away_prediction)
    real_result = match_result(home_real, away_real)

    prediction_result == real_result
  end

  def match_result(home_score, away_score)
    return :home if home_score > away_score
    return :away if away_score > home_score

    :draw
  end

  def handle_existing_membership(league, membership)
    case membership.status
    when "approved"
      redirect_to league_path(league), alert: "Você já participa desta liga."
    when "pending"
      redirect_to league_path(league), alert: "Sua solicitação já está pendente."
    when "rejected"
      new_status = league.private? ? :pending : :approved
      membership.update!(status: new_status)

      if league.private?
        redirect_to league_path(league), notice: "Sua solicitação foi reenviada."
      else
        redirect_to league_path(league), notice: "Você entrou na liga com sucesso."
      end
    else
      redirect_to league_path(league), alert: "Não foi possível solicitar entrada."
    end
  end

  def league_params
    params.require(:league).permit(:name, :image, :private)
  end
end
