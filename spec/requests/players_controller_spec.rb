# frozen_string_literal: true

RSpec.describe PlayersController do
  describe 'self registration' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:tournament) { create(:tournament, name: 'My Tournament', self_registration: true) }

    describe '#create' do
      it 'prevents self-registration without logging in' do
        sign_in nil
        post tournament_players_path(tournament), params: { player: { name: 'Unauthorized user' } }

        expect(tournament.players).to be_empty
        expect_unauthorized
      end

      it 'prevents self-registration when closed' do
        sign_in user1
        tournament.close_registration!
        post tournament_players_path(tournament), params: { player: { name: 'New player' } }

        expect(tournament.players).to be_empty
        expect_unauthorized
      end

      it 'infers your user ID if you register as yourself' do
        sign_in user1
        post tournament_players_path(tournament), params: { player: { name: 'Player 1' } }

        expect(tournament.players.last.user_id).to be(user1.id)
      end

      it 'infers user ID when TO registers themselves' do
        sign_in tournament.user
        post tournament_players_path(tournament), params: { player: { name: 'Tournament organizer' } }

        expect(tournament.players.last.user_id).to be(tournament.user.id)
      end

      it 'does not set user ID when TO registers another player' do
        sign_in tournament.user
        post tournament_players_path(tournament), params: { player: { name: 'Other player', organiser_view: true } }

        expect(tournament.players.last.user_id).to be_nil
      end
    end

    describe '#update' do
      let(:player1) { create(:player, name: 'Player 1', tournament:, user_id: user1.id) }

      it 'prevents updating a player without logging in' do
        sign_in nil
        put tournament_player_path(tournament, player1), params: { player: { name: 'Changed Name' } }

        player1.reload
        expect(player1.name).not_to eq('Changed Name')
        expect_unauthorized
      end

      it 'stops you updating another user' do
        sign_in user2
        put tournament_player_path(tournament, player1), params: { player: { name: 'Changed Name' } }

        player1.reload
        expect(player1.name).not_to eq('Changed Name')
        expect_unauthorized
      end

      it 'ignores submitting decks when deck registration is not turned on' do
        sign_in user1
        put tournament_player_path(tournament, player1), params: { player: {
          runner_identity: 'Some Runner',
          corp_identity: 'Some Corp',
          runner_deck: '{"details": {"name": "Runner Deck"}, "cards": []}',
          corp_deck: '{"details": {"name": "Corp Deck"}, "cards": []}'
        } }

        player1.reload
        expect(player1.runner_identity).to eq('Some Runner')
        expect(player1.corp_identity).to eq('Some Corp')
        expect(player1.runner_deck).to be_nil
        expect(player1.corp_deck).to be_nil
      end

      it 'ignores player details change when player is locked' do
        sign_in tournament.user
        patch lock_registration_tournament_player_path(tournament, player1)
        sign_in user1
        put tournament_player_path(tournament, player1), params: { player: {
          name: 'Updated name',
          pronouns: 'they/them',
          corp_identity: 'Some corp',
          runner_identity: 'Some runner'
        } }

        player1.reload
        expect(player1.name).to eq('Player 1')
        expect(player1.pronouns).to be_nil
        expect(player1.corp_identity).to be_nil
        expect(player1.runner_identity).to be_nil
      end

      it 'allows TO updating another user' do
        sign_in tournament.user
        put tournament_player_path(tournament, player1),
            params: { player: { name: 'Changed Name', organiser_view: true } }

        player1.reload
        expect(player1.name).to eq('Changed Name')
      end

      it 'allows TO updating another user when locked' do
        sign_in tournament.user
        player1.update(registration_locked: true)
        put tournament_player_path(tournament, player1),
            params: { player: { name: 'Changed Name', organiser_view: true } }

        player1.reload
        expect(player1.name).to eq('Changed Name')
      end

      it 'allows TO updating themselves' do
        sign_in tournament.user
        post tournament_players_path(tournament), params: { player: { name: 'Tournament organiser' } }
        put tournament_player_path(tournament, Player.last), params: { player: { name: 'Mr. Organiser' } }

        expect(Player.last.user_id).to be(tournament.user.id)
        expect(Player.last.name).to eq('Mr. Organiser')
      end

      it 'allows TO updating themselves in the organiser view' do
        sign_in tournament.user
        post tournament_players_path(tournament), params: { player: { name: 'Tournament organiser' } }
        put tournament_player_path(tournament, Player.last),
            params: { player: { name: 'Mr. Organiser', organiser_view: true } }

        expect(Player.last.user_id).to be(tournament.user.id)
        expect(Player.last.name).to eq('Mr. Organiser')
      end
    end
  end

  describe 'deck submission' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }
    let(:tournament) { create(:tournament, self_registration: true, nrdb_deck_registration: true) }
    let(:player1) { Player.find_by! user_id: user1.id }
    let(:player2) { Player.find_by! user_id: user2.id }

    before do
      sign_in user1
      post tournament_players_path(tournament), params: { player: { name: 'Player 1' } }
      sign_in user2
      post tournament_players_path(tournament), params: { player: { name: 'Player 2' } }
    end

    it 'stores decks' do
      sign_in user1
      put tournament_player_path(tournament, player1), params: { player: {
        corp_deck: '{"details": {"name": "Corp Deck"}, "cards": []}',
        runner_deck: '{"details": {"name": "Runner Deck"}, "cards": []}'
      } }

      player1.reload
      expect(player1.corp_deck.name).to eq('Corp Deck')
      expect(player1.runner_deck.name).to eq('Runner Deck')
    end

    it 'stores cards' do
      sign_in user1
      put tournament_player_path(tournament, player1), params: { player: {
        corp_deck: '{"details": {}, "cards": [{"title": "Corp Card", "quantity": 3}]}',
        runner_deck: '{"details": {}, "cards": [{"title": "Runner Card", "quantity": 3}]}'
      } }

      player1.reload
      expect(player1.corp_deck.cards.map { |card| [card.title, card.quantity] }).to eq([['Corp Card', 3]])
      expect(player1.runner_deck.cards.map { |card| [card.title, card.quantity] }).to eq([['Runner Card', 3]])
    end

    it 'deletes decks' do
      sign_in user1
      put tournament_player_path(tournament, player1), params: { player: {
        corp_deck: '{"details": {"name": "Corp Deck"}, "cards": []}',
        runner_deck: '{"details": {"name": "Runner Deck"}, "cards": []}'
      } }
      put tournament_player_path(tournament, player1), params: { player: {
        corp_deck: '',
        runner_deck: ''
      } }

      player1.reload
      expect(player1.corp_deck).to be_nil
      expect(player1.runner_deck).to be_nil
    end

    it 'ignores decks when player is locked' do
      sign_in tournament.user
      patch lock_registration_tournament_player_path(tournament, player1)
      sign_in user1
      put tournament_player_path(tournament, player1), params: { player: {
        corp_deck: '{"details": {"name": "Corp Deck"}, "cards": []}',
        runner_deck: '{"details": {"name": "Runner Deck"}, "cards": []}'
      } }

      player1.reload
      expect(player1.corp_deck).to be_nil
      expect(player1.runner_deck).to be_nil
    end

    it 'has all decks unlocked to begin with' do
      expect(player1.reload.registration_locked?).to be(false)
      expect(player2.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(true)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'locks decks for the whole tournament when registration closes' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)

      expect(player1.reload.registration_locked?).to be(true)
      expect(player2.reload.registration_locked?).to be(true)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(false)
    end

    it 'locks decks for one player but not the other' do
      sign_in tournament.user
      patch lock_registration_tournament_player_path(tournament, player1)

      expect(player1.reload.registration_locked?).to be(true)
      expect(player2.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'unlocks decks for one player' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)
      patch unlock_registration_tournament_player_path(tournament, player1)

      expect(player1.reload.registration_locked?).to be(false)
      expect(player2.reload.registration_locked?).to be(true)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'unlocks decks for all players' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)
      patch unlock_player_registrations_tournament_path(tournament)

      expect(player1.reload.registration_locked?).to be(false)
      expect(player2.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(true)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'does not unlock decks when reopening registration' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)
      patch open_registration_tournament_path(tournament)

      expect(player1.reload.registration_locked?).to be(true)
      expect(player2.reload.registration_locked?).to be(true)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(false)
    end

    it 'locks decks for all players individually' do
      sign_in tournament.user
      patch lock_registration_tournament_player_path(tournament, player1)
      patch lock_registration_tournament_player_path(tournament, player2)

      expect(player1.reload.registration_locked?).to be(true)
      expect(player2.reload.registration_locked?).to be(true)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(false)
    end

    it 'unlocks decks for all players individually' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)
      patch unlock_registration_tournament_player_path(tournament, player1)
      patch unlock_registration_tournament_player_path(tournament, player2)

      expect(player1.reload.registration_locked?).to be(false)
      expect(player2.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(true)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'unlocks decks for all but one player' do
      sign_in tournament.user
      patch close_registration_tournament_path(tournament)
      patch unlock_player_registrations_tournament_path(tournament)
      patch lock_registration_tournament_player_path(tournament, player1)

      expect(player1.reload.registration_locked?).to be(true)
      expect(player2.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'does not lock decks for a new player even when all other players are locked' do
      sign_in tournament.user
      patch lock_player_registrations_tournament_path(tournament)
      sign_in user3
      post tournament_players_path(tournament), params: { player: { name: 'Player 3' } }
      player3 = Player.find_by! user_id: user3.id
      sign_in tournament.user

      expect(player3.reload.registration_locked?).to be(false)
      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(true)
    end

    it 'shows all players locked when only unlocked player is deleted' do
      sign_in tournament.user
      patch lock_player_registrations_tournament_path(tournament)
      patch unlock_registration_tournament_player_path(tournament, player2)
      delete tournament_player_path(tournament, player2)

      expect(tournament.reload.all_players_unlocked?).to be(false)
      expect(tournament.any_player_unlocked?).to be(false)
    end

    it 'shows all players unlocked when only locked player is deleted' do
      sign_in tournament.user
      patch lock_player_registrations_tournament_path(tournament)
      patch unlock_registration_tournament_player_path(tournament, player1)
      delete tournament_player_path(tournament, player2)

      expect(tournament.reload.all_players_unlocked?).to be(true)
      expect(tournament.any_player_unlocked?).to be(true)
    end
  end

  describe 'standings data' do
    let(:organiser) { create(:user) }
    let(:tournament) { create(:tournament, name: 'My Tournament', user: organiser) }
    let!(:alice) { create(:player, tournament:, name: 'Alice', pronouns: 'she/her') }

    before do
      create(:player, tournament:, name: 'Bob', pronouns: 'he/him')
      create(:player, tournament:, name: 'Charlie', pronouns: 'she/her')
    end

    describe 'during player meeting' do
      it 'displays without logging in' do
        sign_in nil
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => true,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 0,
                'standings' => [
                  standing_with_no_score(1, player_with_hidden_ids('Alice (she/her)')),
                  standing_with_no_score(2, player_with_hidden_ids('Bob (he/him)')),
                  standing_with_no_score(3, player_with_hidden_ids('Charlie (she/her)'))
                ] }
            ]
            )
          )
      end

      it 'displays as player' do
        sign_in alice
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => true,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 0,
                'standings' => [
                  standing_with_no_score(1, player_with_hidden_ids('Alice (she/her)')),
                  standing_with_no_score(2, player_with_hidden_ids('Bob (he/him)')),
                  standing_with_no_score(3, player_with_hidden_ids('Charlie (she/her)'))
                ] }
            ]
            )
          )
      end

      it 'displays as organiser' do
        sign_in organiser
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => true,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 0,
                'standings' => [
                  standing_with_no_score(1, player_with_hidden_ids('Alice (she/her)')),
                  standing_with_no_score(2, player_with_hidden_ids('Bob (he/him)')),
                  standing_with_no_score(3, player_with_hidden_ids('Charlie (she/her)'))
                ] }
            ]
            )
          )
      end
    end

    describe 'after first swiss round' do
      before do
        Pairer.new(tournament.new_round!, Random.new(0)).pair!
        round = tournament.current_stage.rounds.last
        round.pairings.each do |pairing|
          pairing.update!(score1: 6, score2: 0)
        end
        round.update!(completed: true)
      end

      it 'displays without logging in' do
        sign_in nil
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => false,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 1,
                'standings' => [
                  standing_with_custom_score(1, points: 6, sos: '0.0', extended_sos: '6.0',
                                                player: player_with_no_ids('Charlie (she/her)')),
                  standing_with_custom_score(2, points: 6, bye_points: 6, sos: '0.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Alice (she/her)')),
                  standing_with_custom_score(3, points: 0, sos: '6.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Bob (he/him)'))
                ] }
            ]
            )
          )
      end
    end

    describe 'at start of cut' do
      before do
        Pairer.new(tournament.new_round!, Random.new(0)).pair!
        round = tournament.current_stage.rounds.last
        round.pairings.each do |pairing|
          pairing.update!(score1: 6, score2: 0)
        end
        round.update!(completed: true)
        tournament.cut_to!(:single_elim, 3)
        Pairer.new(tournament.new_round!, Random.new(0)).pair!
      end

      it 'displays without logging in' do
        sign_in nil
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => false,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'single_elim',
                'any_decks_viewable' => false,
                'rounds_complete' => 0,
                'standings' => [
                  standing_at_cut_position(1, player: nil, seed: nil),
                  standing_at_cut_position(2, player: nil, seed: nil),
                  standing_at_cut_position(3, player: nil, seed: nil)
                ] },
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 1,
                'standings' => [
                  standing_with_custom_score(1, points: 6, sos: '0.0', extended_sos: '6.0',
                                                player: player_with_no_ids('Charlie (she/her)')),
                  standing_with_custom_score(2, points: 6, bye_points: 6, sos: '0.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Alice (she/her)')),
                  standing_with_custom_score(3, points: 0, sos: '6.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Bob (he/him)'))
                ] }
            ]
            )
          )
      end
    end

    describe 'after first round of cut' do
      before do
        Pairer.new(tournament.new_round!, Random.new(0)).pair!
        swiss_round = tournament.current_stage.rounds.last
        swiss_round.pairings.each do |pairing|
          pairing.update!(score1: 6, score2: 0)
        end
        swiss_round.update!(completed: true)
        tournament.cut_to!(:single_elim, 3)
        Pairer.new(tournament.new_round!, Random.new(0)).pair!
        cut_round = tournament.current_stage.rounds.last
        cut_round.pairings.each do |pairing|
          pairing.update!(score1: 3, score2: 0)
        end
        cut_round.update!(completed: true)
      end

      it 'displays without logging in' do
        sign_in nil
        get standings_data_tournament_players_path(tournament)

        expect(compare_body(response))
          .to eq(
            standings_expectation(
              'is_player_meeting' => false,
              'manual_seed' => false,
              'stages' => [
              { 'format' => 'single_elim',
                'any_decks_viewable' => false,
                'rounds_complete' => 1,
                'standings' => [
                  standing_at_cut_position(1, player: nil, seed: nil),
                  standing_at_cut_position(2, player: nil, seed: nil),
                  standing_at_cut_position(3, seed: 3,
                                              player: player_with_no_ids('Bob (he/him)'))
                ] },
              { 'format' => 'swiss',
                'any_decks_viewable' => false,
                'rounds_complete' => 1,
                'standings' => [
                  standing_with_custom_score(1, points: 6, sos: '0.0', extended_sos: '6.0',
                                                player: player_with_no_ids('Charlie (she/her)')),
                  standing_with_custom_score(2, points: 6, bye_points: 6, sos: '0.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Alice (she/her)')),
                  standing_with_custom_score(3, points: 0, sos: '6.0', extended_sos: '0.0',
                                                player: player_with_no_ids('Bob (he/him)'))
                ] }
            ]
            )
          )
      end
    end

    describe 'smashup half-deck standings' do
      let(:smashup_format) { Format.find_or_create_by!(name: 'Smashup') { |f| f.position = 98 } }
      let(:tournament) do
        create(:tournament, name: 'Smashup', user: organiser, format: smashup_format, swiss_format: :single_sided)
      end
      let!(:corp_contrib_a) do
        create(:player, tournament:, name: 'Corp Contrib A',
                        corp_identity_ref: create(:id_etf), runner_identity_ref: create(:id_az))
      end
      let!(:corp_contrib_b) do
        create(:player, tournament:, name: 'Corp Contrib B',
                        corp_identity_ref: create(:id_pd), runner_identity_ref: create(:id_sable))
      end
      let!(:runner_contrib_c) do
        create(:player, tournament:, name: 'Runner Contrib C',
                        corp_identity_ref: create(:id_ampere), runner_identity_ref: create(:id_esa))
      end
      let!(:runner_contrib_d) do
        create(:player, tournament:, name: 'Runner Contrib D',
                        corp_identity_ref: create(:id_ob), runner_identity_ref: create(:id_ari))
      end
      let!(:seated1) { create(:player, tournament:, name: 'Seated 1') }
      let!(:seated2) { create(:player, tournament:, name: 'Seated 2') }

      before do
        round = tournament.current_stage.rounds.create!(number: 1, tournament_id: tournament.id, completed: true)
        create(:pairing, round:, player1: seated1, player2: seated2, side: :player1_is_corp,
                         score1: 6, score2: 0,
                         player1_deck1_player_id: corp_contrib_a.id,
                         player1_deck2_player_id: corp_contrib_b.id,
                         player2_deck1_player_id: runner_contrib_c.id,
                         player2_deck2_player_id: runner_contrib_d.id)
      end

      it 'includes half-deck standings in the response' do
        get standings_data_tournament_players_path(tournament)

        body = compare_body(response)
        expect(body['smashup']).to be(true)
        expect(body['half_deck_standings'].length).to eq(4)

        deck_a_corp = body['half_deck_standings'].find do |standing|
          standing['player']['name_with_pronouns'] == corp_contrib_a.name_with_pronouns &&
            standing['side'] == 'corp'
        end
        expect(deck_a_corp).to include(
          'points' => 6,
          'sos' => '0.0',
          'extended_sos' => '6.0'
        )
      end

      it 'matches each standing identity to the contributor identity ref for that side' do
        get standings_data_tournament_players_path(tournament)

        expect_half_deck_standing_identities(
          compare_body(response)['half_deck_standings'],
          contributors: [corp_contrib_a, corp_contrib_b, runner_contrib_c, runner_contrib_d]
        )
      end

      it 'never exposes a runner identity on a corp half-deck standing' do
        get standings_data_tournament_players_path(tournament)

        corp_standings = compare_body(response)['half_deck_standings'].select { |standing| standing['side'] == 'corp' }
        expect(corp_standings).not_to be_empty
        corp_standings.each do |standing|
          expect(standing['identity']['side']).to eq('corp')
        end
      end

      it 'never exposes a corp identity on a runner half-deck standing' do
        get standings_data_tournament_players_path(tournament)

        runner_standings = compare_body(response)['half_deck_standings'].select { |standing| standing['side'] == 'runner' }
        expect(runner_standings).not_to be_empty
        runner_standings.each do |standing|
          expect(standing['identity']['side']).to eq('runner')
        end
      end

      context 'when a contributor has a corp identity stored in runner_identity_ref' do
        let!(:misassigned_contrib) do
          create(:player, tournament:, name: 'Misassigned Contrib',
                          corp_identity_ref: create(:id_etf),
                          runner_identity_ref: create(:id_au_co))
        end

        before do
          round = tournament.current_stage.rounds.last
          create(:pairing, round:, player1: seated1, player2: seated2, side: :player1_is_runner,
                           score1: 3, score2: 3,
                           player1_deck1_player_id: misassigned_contrib.id,
                           player1_deck2_player_id: corp_contrib_a.id,
                           player2_deck1_player_id: runner_contrib_c.id,
                           player2_deck2_player_id: runner_contrib_d.id)
        end

        it 'still resolves runner standings from runner_identity_ref_id' do
          get standings_data_tournament_players_path(tournament)

          standing = find_half_deck_standing(
            compare_body(response)['half_deck_standings'],
            contributor: misassigned_contrib,
            side: 'runner'
          )

          expect(standing['identity']).to eq(expected_standings_identity(misassigned_contrib.runner_identity_ref))
        end

        it 'surfaces invalid registration data when the runner ref points at a corp identity' do
          expect(misassigned_contrib.runner_identity_ref.side).to eq('corp')

          get standings_data_tournament_players_path(tournament)

          standing = find_half_deck_standing(
            compare_body(response)['half_deck_standings'],
            contributor: misassigned_contrib,
            side: 'runner'
          )

          expect(standing['identity']['side']).not_to eq('runner')
        end
      end
    end
  end

  def compare_body(response)
    normalize_standings_body(JSON.parse(response.body))
  end

  def normalize_standings_body(body)
    body['stages'].each do |stage|
      stage['standings'].each do |standing|
        standing['player']&.delete 'id'
      end
    end
    body.fetch('half_deck_standings', []).each do |standing|
      standing['player']&.delete 'id'
    end
    body.merge(
      'smashup' => body.fetch('smashup', false),
      'half_deck_standings' => body.fetch('half_deck_standings', [])
    )
  end

  def standings_expectation(attrs)
    attrs.merge(
      'smashup' => attrs.fetch('smashup', false),
      'half_deck_standings' => attrs.fetch('half_deck_standings', [])
    )
  end

  def standing_with_no_score(position, player)
    {
      'position' => position,
      'player' => player,
      'policy' => { 'view_decks' => false },
      'points' => 0,
      'sos' => 0,
      'extended_sos' => 0,
      'bye_points' => 0,
      'corp_points' => 0,
      'runner_points' => 0,
      'manual_seed' => nil,
      'side_bias' => nil
    }
  end

  def standing_with_custom_score(position, points:, sos:, extended_sos:, player:, bye_points: 0) # rubocop:disable Metrics/ParameterLists
    {
      'position' => position,
      'player' => player,
      'policy' => { 'view_decks' => false },
      'points' => points,
      'sos' => sos,
      'extended_sos' => extended_sos,
      'bye_points' => bye_points,
      'corp_points' => 0,
      'runner_points' => 0,
      'manual_seed' => nil,
      'side_bias' => nil
    }
  end

  def standing_at_cut_position(position, seed:, player:)
    {
      'position' => position,
      'player' => player,
      'policy' => { 'view_decks' => false },
      'seed' => seed
    }
  end

  def player_with_hidden_ids(name_with_pronouns)
    {
      'name_with_pronouns' => name_with_pronouns,
      'corp_id' => { 'faction' => nil, 'name' => nil },
      'runner_id' => { 'faction' => nil, 'name' => nil },
      'active' => true
    }
  end

  def player_with_no_ids(name_with_pronouns)
    {
      'name_with_pronouns' => name_with_pronouns,
      'corp_id' => { 'faction' => nil, 'name' => nil },
      'runner_id' => { 'faction' => nil, 'name' => nil },
      'active' => true
    }
  end

  def expect_unauthorized
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("🔒 Sorry, you can't do that")
  end
end
