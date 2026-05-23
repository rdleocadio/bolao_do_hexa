class LeagueMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_membership

  def approve
    unless owner?
      redirect_to league_path(@league),
        alert: t("league.errors.owner_only")
      return
    end

    if @membership.pending? || @membership.rejected?

      @membership.update!(status: :approved)

      redirect_to league_path(@league),
        notice: t("league.messages.approved_success")

    else

      redirect_to league_path(@league),
        alert: t("league.errors.cannot_approve")

    end
  end

  def reject
    unless owner?
      redirect_to league_path(@league),
        alert: t("league.errors.owner_only")
      return
    end

    if @membership.pending? || @membership.approved?

      if owner_membership?(@membership)

        redirect_to league_path(@league),
          alert: t("league.errors.owner_cannot_reject")

        return
      end

      @membership.update!(status: :rejected)

      redirect_to league_path(@league),
        notice: t("league.messages.rejected_success")

    else

      redirect_to league_path(@league),
        alert: t("league.errors.cannot_reject")

    end
  end

  def remove

    # ===== OWNER REMOVING MEMBER =====

    if owner? && @membership.user != current_user

      if owner_membership?(@membership)

        redirect_to league_path(@league),
          alert: t("league.errors.owner_cannot_remove")

        return
      end

      @membership.destroy

      redirect_to league_path(@league),
        notice: t("league.messages.member_removed")

      return
    end

    # ===== USER LEAVING LEAGUE =====

    if @membership.user == current_user

      if owner_membership?(@membership)

        redirect_to league_path(@league),
          alert: t("league.errors.owner_cannot_leave")

        return
      end

      @membership.destroy

      redirect_to leagues_path,
        notice: t("league.messages.left_successfully")

      return
    end

    redirect_to league_path(@league),
      alert: t("league.errors.not_allowed")
  end

  private

  def set_membership
    @membership = LeagueMembership.find(params[:id])
    @league = @membership.league
  end

  def owner?
    @league.owner == current_user
  end

  def owner_membership?(membership)
    membership.owner? || membership.user_id == @league.owner_id
  end
end
