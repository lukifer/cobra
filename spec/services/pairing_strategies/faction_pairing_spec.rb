# frozen_string_literal: true

RSpec.describe PairingStrategies::FactionPairing do
  let(:seed) { 12_345 }
  let(:random) { Random.new(seed) }

  def p(id, faction, score)
    described_class::Player.new(id:, faction:, score:)
  end

  describe '.pair_players' do
    it 'raises on duplicate ids' do
      players = [p(1, 'A', 0), p(1, 'B', 0)]
      expect { described_class.pair_players(players, [], random:) }
        .to raise_error(ArgumentError, /Duplicate player id/)
    end

    it 'returns empty for fewer than two players' do
      expect(described_class.pair_players([p(1, 'A', 0)], [], random:)).to eq([])
      expect(described_class.pair_players([], [], random:)).to eq([])
    end

    it 'minimizes pair-sum delta for the known six-player example (matches TS test)' do
      players = [
        p(1, 'A', 100),
        p(2, 'A', 80),
        p(3, 'B', 95),
        p(4, 'B', 20),
        p(5, 'C', 50),
        p(6, 'C', 60)
      ]

      pairs = described_class.pair_players(players, [], random:)

      used = Set.new
      pairs.each do |a, b|
        expect(a.id).not_to eq(b.id)
        expect(used).not_to include(a.id, b.id)
        used.merge([a.id, b.id])
        expect(a.faction).not_to eq(b.faction)
      end
      expect(used.size).to eq(6)

      target = (2 * players.sum(&:score)) / players.size.to_f
      delta = pairs.sum { |a, b| ((a.score + b.score) - target).abs }
      expect(delta).to eq(30)
    end

    it 'with an odd field, gives the bye to the lowest-scoring player when pairing costs tie' do
      players = [
        p(1, 'X', 3),
        p(2, 'X', 3),
        p(3, 'X', 0)
      ]
      pairs = described_class.pair_players(players, [], random: Random.new(1))
      expect(pairs.size).to eq(1)
      expect(Set[pairs.first[0].id, pairs.first[1].id]).to eq(Set[1, 2])
    end

    it 'does not choose a bye for players listed in ineligible_bye_ids' do
      players = [
        p(1, 'X', 3),
        p(2, 'X', 3),
        p(3, 'X', 0)
      ]
      pairs = described_class.pair_players(players, [], random: Random.new(1), ineligible_bye_ids: [3])
      # Bye cannot be 3; among 1 and 2 (same score), lower id 1 receives bye → pair {2, 3}
      expect(Set[pairs.first[0].id, pairs.first[1].id]).to eq(Set[2, 3])
    end

    it 'avoids repeating the same opponent pair across rounds (history keys)' do
      players = (1..6).map { |i| p(i, "F#{i}", 0) }
      first = described_class.pair_players(players, [], random: Random.new(seed))
      history = first.map { |a, b| [a.id, b.id] }

      second = described_class.pair_players(players, history, random: Random.new(seed + 1))

      keys = (first + second).map { |a, b| described_class.pair_key_by_id(a.id, b.id) }
      expect(keys.uniq.size).to eq(keys.size)
    end
  end
end
