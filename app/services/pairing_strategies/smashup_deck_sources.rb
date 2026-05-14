# frozen_string_literal: true

module PairingStrategies
  # Picks two other players in the round to supply deck identities for each seated
  # competitor, preferring distinct factions on the side that player is assigned.
  module SmashupDeckSources
    module_function

    def attributes_for_plain_pairing(plain_pairing, round_plain_ids, players_by_id, random: Random.new)
      return {} if plain_pairing.bye?

      p1 = plain_pairing.player1
      p2 = plain_pairing.player2
      side1 = plain_pairing.player1_side
      return {} if side1.blank?

      side1_sym = side1.to_sym
      side2_sym = side1_sym == :corp ? :runner : :corp

      pool_ids = round_plain_ids - [p1.id, p2.id]
      d1 = pick_two(pool_ids, side1_sym, players_by_id, random)
      d2 = pick_two(pool_ids, side2_sym, players_by_id, random)

      {
        player1_deck1_player_id: d1[0],
        player1_deck2_player_id: d1[1],
        player2_deck1_player_id: d2[0],
        player2_deck2_player_id: d2[1]
      }
    end

    def pick_two(pool_ids, side, players_by_id, random)
      return [nil, nil] if pool_ids.length < 2

      ids = pool_ids.sort
      best = nil
      best_rank = nil

      ids.combination(2).each do |id_a, id_b|
        fa = faction_for_side(players_by_id[id_a], side)
        fb = faction_for_side(players_by_id[id_b], side)
        tier = deck_pair_tier(fa, fb)
        rank = [tier, random.rand]
        if best_rank.nil? || (rank <=> best_rank).negative?
          best_rank = rank
          best = [id_a, id_b].sort
        end
      end

      best
    end

    def deck_pair_tier(fa, fb)
      return 0 if fa.present? && fb.present? && fa != fb
      return 1 if fa != fb

      2
    end

    def faction_for_side(player_ar, side)
      case side
      when :corp
        player_ar&.corp_identity_ref&.faction&.to_s.presence || player_ar&.corp_identity.to_s.presence
      when :runner
        player_ar&.runner_identity_ref&.faction&.to_s.presence || player_ar&.runner_identity.to_s.presence
      end
    end
  end
end
