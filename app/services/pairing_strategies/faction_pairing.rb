# frozen_string_literal: true

# Ports the faction-aware Swiss pairing logic from the reference TypeScript
# implementation (`pairPlayers`), used for single-sided Swiss rounds.
module PairingStrategies
  module FactionPairing
    Player = Struct.new(:id, :faction, :score, keyword_init: true)

    class Cost
      attr_accessor :same_faction, :repeats, :delta, :tie

      def initialize(same_faction:, repeats:, delta:, tie:)
        @same_faction = same_faction
        @repeats = repeats
        @delta = delta
        @tie = tie
      end

      def <=>(other)
        ((same_faction <=> other.same_faction).nonzero? ||
          (repeats <=> other.repeats).nonzero? ||
          (delta <=> other.delta).nonzero? ||
          (tie <=> other.tie))
      end
    end

    MAX_EXACT = 20

    module_function

    def pair_key_by_id(a_id, b_id)
      lo = a_id < b_id ? a_id : b_id
      hi = a_id < b_id ? b_id : a_id
      "#{lo}-#{hi}"
    end

    def pair_players(players, history_pair_ids, random: Random.new, ineligible_bye_ids: nil)
      validate_unique_ids!(players)
      return [] if players.length < 2

      history_set = build_history_set(history_pair_ids)
      bye_block = ineligible_bye_ids&.to_set || Set.new

      if players.length.even?
        return exact_optimal_pairing(players, history_set, random) if players.length <= MAX_EXACT

        return greedy_pairing(players, history_set, random)
      end

      best = nil # { cost:, pairs:, bye: }

      players.each do |bye_candidate|
        next if bye_block.include?(bye_candidate.id)

        rest = players.reject { |p| p.id == bye_candidate.id }
        pairs = if rest.length <= MAX_EXACT
                  exact_optimal_pairing(rest, history_set, random)
                else
                  greedy_pairing(rest, history_set, random)
                end
        cost = score_pairs_for_compare(pairs, rest, history_set, random, random_tie: false)

        if best.nil?
          best = { cost:, pairs:, bye: bye_candidate }
          next
        end

        cmp = (cost <=> best[:cost])
        if cmp.negative?
          best = { cost:, pairs:, bye: bye_candidate }
        elsif cmp.zero?
          # Among equal pairing cost, give the bye to the lowest-scoring player (Swiss norm).
          cur, prev = bye_candidate, best[:bye]
          if cur.score < prev.score || (cur.score == prev.score && cur.id < prev.id)
            best = { cost:, pairs:, bye: bye_candidate }
          end
        end
      end

      best&.[](:pairs) || []
    end

    def build_history_set(history_pair_ids)
      history_pair_ids.each_with_object(Set.new) do |(a_id, b_id), set|
        set.add(pair_key_by_id(a_id, b_id))
      end
    end

    def validate_unique_ids!(players)
      seen = Set.new
      players.each do |p|
        raise ArgumentError, "Duplicate player id in input: #{p.id}" if seen.include?(p.id)

        seen.add(p.id)
      end
    end

    def average_pair_sum(players)
      return 0 if players.empty?

      total = players.sum(&:score)
      (2.0 * total) / players.length
    end

    def greedy_pairing(players, history_set, random)
      target = average_pair_sum(players)
      remaining = players.sort_by { |p| [-p.score, p.id] }
      out = []

      while remaining.length >= 2
        p = remaining.shift
        best_idx = nil
        best_cost = nil

        remaining.each_with_index do |q, i|
          cost = Cost.new(
            same_faction: p.faction == q.faction ? 1 : 0,
            repeats: history_set.include?(pair_key_by_id(p.id, q.id)) ? 1 : 0,
            delta: (p.score + q.score - target).abs,
            tie: random.rand
          )
          if best_cost.nil? || (cost <=> best_cost).negative?
            best_cost = cost
            best_idx = i
          end
        end

        q = remaining.delete_at(best_idx)
        out << [p, q]
      end

      out
    end

    def exact_optimal_pairing(players, history_set, random)
      n = players.length
      target = average_pair_sum(players)
      memo = {}

      solve = lambda do |mask|
        return memo[mask] if memo.key?(mask)

        if mask.zero?
          result = {
            cost: Cost.new(same_faction: 0, repeats: 0, delta: 0, tie: random.rand),
            pairs: []
          }
          memo[mask] = result
          return result
        end

        i = (0...n).find { |bit| (mask & (1 << bit)).nonzero? }
        mask_without_i = mask & ~(1 << i)

        best = nil

        ((i + 1)...n).each do |j|
          bit_j = 1 << j
          next if mask_without_i & bit_j == 0

          next_mask = mask_without_i & ~bit_j
          sub = solve.call(next_mask)

          a = players[i]
          b = players[j]

          pair_cost = Cost.new(
            same_faction: a.faction == b.faction ? 1 : 0,
            repeats: history_set.include?(pair_key_by_id(a.id, b.id)) ? 1 : 0,
            delta: (a.score + b.score - target).abs,
            tie: 0
          )

          total = Cost.new(
            same_faction: pair_cost.same_faction + sub[:cost].same_faction,
            repeats: pair_cost.repeats + sub[:cost].repeats,
            delta: pair_cost.delta + sub[:cost].delta,
            tie: random.rand
          )

          candidate = {
            cost: total,
            pairs: [[i, j], *sub[:pairs]]
          }

          if best.nil? || (total <=> best[:cost]).negative?
            best = candidate
          end
        end

        best ||= {
          cost: Cost.new(same_faction: 0, repeats: 0, delta: 0, tie: random.rand),
          pairs: []
        }

        memo[mask] = best
        best
      end

      full_mask = (1 << n) - 1
      res = solve.call(full_mask)

      res[:pairs].map { |i, j| [players[i], players[j]] }
    end

    def score_pairs_for_compare(pairs, all_players, history_set, random, random_tie: true)
      target = average_pair_sum(all_players)
      same_faction = 0
      repeats = 0
      delta = 0

      pairs.each do |a, b|
        same_faction += 1 if a.faction == b.faction
        repeats += 1 if history_set.include?(pair_key_by_id(a.id, b.id))
        delta += (a.score + b.score - target).abs
      end

      Cost.new(same_faction:, repeats:, delta:, tie: random_tie ? random.rand : 0)
    end
  end
end
