class LeagueMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_membership
  before_action :authorize_owner!

  def approve
    if @membership.pending? || @membership.rejected?
      @membership.update!(status: :approved)
      redirect_to league_path(@league), notice: "Participante aprovado com sucesso."
    else
      redirect_to league_path(@league), alert: "Essa solicitação não pode ser aprovada."
    end
  end

  def reject
    if @membership.pending? || @membership.approved?
      if owner_membership?(@membership)
        redirect_to league_path(@league), alert: "O dono da liga não pode ser rejeitado."
        return
      end

      @membership.update!(status: :rejected)
      redirect_to league_path(@league), notice: "Solicitação rejeitada com sucesso."
    else
      redirect_to league_path(@league), alert: "Essa solicitação não pode ser rejeitada."
    end
  end

  def remove
    if owner_membership?(@membership)
      redirect_to league_path(@league), alert: "O dono da liga não pode ser removido."
      return
    end

    @membership.destroy
    redirect_to league_path(@league), notice: "Participante removido com sucesso."
  end

  private

  def set_membership
    @membership = LeagueMembership.find(params[:id])
    @league = @membership.league
  end

  def authorize_owner!
    unless @league.owner == current_user
      redirect_to league_path(@league), alert: "Apenas o dono da liga pode fazer isso."
    end
  end

  def owner_membership?(membership)
    membership.owner? || membership.user_id == @league.owner_id
  end
end
