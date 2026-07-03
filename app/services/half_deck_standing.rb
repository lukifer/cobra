# frozen_string_literal: true

class HalfDeckStanding # rubocop:disable Style/Documentation
  attr_reader :player, :side, :points, :sos, :extended_sos

  delegate :name, :pronouns, :name_with_pronouns, to: :player
  delegate :tournament, to: :player

  def initialize(player, values = {})
    @player = player
    @side = values.fetch(:side)
    @points = values.fetch(:points, 0) || 0
    @sos = values.fetch(:sos, 0) || 0
    @extended_sos = values.fetch(:extended_sos, 0) || 0
  end

  def <=>(other)
    other.tiebreakers <=> tiebreakers
  end

  def tiebreakers
    [points, sos, extended_sos]
  end

  def corp?
    side == :corp
  end

  def runner?
    side == :runner
  end

  def contributor_identity
    player.contributor_identity_for_side(side)
  end
end
