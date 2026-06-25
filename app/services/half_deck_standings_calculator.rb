# frozen_string_literal: true

class HalfDeckStandingsCalculator # rubocop:disable Style/Documentation
  def self.calculate!(tournament)
    new(tournament).calculate!
  end

  def initialize(tournament)
    @tournament = tournament
  end

  def calculate!
    players = tournament.players.index_by(&:id)
    points = {}
    games_played = {}
    opponents = {}
    points_for_sos = {}

    tournament.eligible_pairings.each do |pairing|
      record_pairing!(pairing, points:, games_played:, opponents:, points_for_sos:)
    end

    sos, extended_sos = SosCalculator.compute_sos_and_extended_sos(opponents, points_for_sos, games_played)

    points.keys.filter_map do |key|
      player_id, side = key
      player = players[player_id]
      next unless player

      HalfDeckStanding.new(
        player,
        side:,
        points: points[key],
        sos: sos[key],
        extended_sos: extended_sos[key]
      )
    end.sort
  end

  private

  attr_reader :tournament

  def record_pairing!(pairing, points:, games_played:, opponents:, points_for_sos:)
    return unless pairing.side

    weight = pairing.round.weight
    player1_side = pairing.player1_side
    player2_side = pairing.player2_side
    player1_opponents = [
      half_deck_key(pairing.player2_deck1_player_id, player2_side),
      half_deck_key(pairing.player2_deck2_player_id, player2_side)
    ]
    player2_opponents = [
      half_deck_key(pairing.player1_deck1_player_id, player1_side),
      half_deck_key(pairing.player1_deck2_player_id, player1_side)
    ]

    record_contribution!(
      key: half_deck_key(pairing.player1_deck1_player_id, player1_side),
      score: pairing.score1,
      weight:,
      opponent_ids: player1_opponents,
      points:, games_played:, opponents:, points_for_sos:
    )
    record_contribution!(
      key: half_deck_key(pairing.player1_deck2_player_id, player1_side),
      score: pairing.score1,
      weight:,
      opponent_ids: player1_opponents,
      points:, games_played:, opponents:, points_for_sos:
    )
    record_contribution!(
      key: half_deck_key(pairing.player2_deck1_player_id, player2_side),
      score: pairing.score2,
      weight:,
      opponent_ids: player2_opponents,
      points:, games_played:, opponents:, points_for_sos:
    )
    record_contribution!(
      key: half_deck_key(pairing.player2_deck2_player_id, player2_side),
      score: pairing.score2,
      weight:,
      opponent_ids: player2_opponents,
      points:, games_played:, opponents:, points_for_sos:
    )
  end

  def half_deck_key(player_id, side)
    return unless player_id && side

    [player_id, side.to_sym]
  end

  def record_contribution!(key:, score:, weight:, opponent_ids:, points:, games_played:, opponents:, points_for_sos:)
    return unless key

    points[key] ||= 0
    points[key] += score || 0
    games_played[key] ||= 0
    games_played[key] += weight
    points_for_sos[key] ||= 0
    points_for_sos[key] += score || 0
    opponents[key] ||= []
    opponent_ids.compact.each do |opponent_id|
      next if opponent_id == key

      opponents[key] << { id: opponent_id, weight: }
    end
  end
end
