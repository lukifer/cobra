import type { Player, PlayersData } from "../players/PlayersData";
import type { Deck, NrdbDeck } from "../utils/decks.svelte";
import { MockTournament } from "./TournamentTestData";

export const MockPlayerAlice: Player = {
  id: 1,
  name: "Alice",
  pronouns: "she/her",
  name_with_pronouns: "",
  user_id: 1,
  corp_id: {
    name: "A Teia: IP Recovery",
    faction: null,
  },
  runner_id: {
    name: "Arissana Rocha Nahu: Street Artist",
    faction: null,
  },
  registration_locked: false,
  include_in_stream: true,
  active: null,
  first_round_bye: false,
  manual_seed: null,
  fixed_table_number: null,
  side: "corp",
  side_label: null,
};

export const MockPlayerBob: Player = {
  id: 2,
  name: "Bob",
  pronouns: "he/him",
  name_with_pronouns: "",
  user_id: 2,
  corp_deck: undefined,
  corp_id: {
    name: "BANGUN: When Disaster Strikes",
    faction: "weyland-consortium",
  },
  runner_deck: undefined,
  runner_id: {
    name: "Barry “Baz” Wong: Tri-Maf Veteran",
    faction: "criminal",
  },
  registration_locked: true,
  include_in_stream: false,
  active: null,
  first_round_bye: true,
  manual_seed: null,
  fixed_table_number: 1,
  side: "runner",
  side_label: null,
};

export const MockPlayerBobNrdbDecks: NrdbDeck[] = [
  {
    id: 1,
    uuid: "11111111-1111-1111-1111-111111111111",
    date_creation: "2026-06-13T00:00:00+00:00",
    date_update: "2026-06-13T00:00:00+00:00",
    name: "Bob's BANGUN",
    description: "Bob's Bangun deck",
    mwl_code: "",
    tags: "",
    cards: [
      { id: "35068", count: 1 },
      { id: "30075", count: 3 },
    ],
  },
  {
    id: 2,
    uuid: "22222222-2222-2222-2222-222222222222",
    date_creation: "2026-06-13T00:00:00+00:00",
    date_update: "2026-06-13T00:00:00+00:00",
    name: "Bob's Baz",
    description: "Bob's Baz deck",
    mwl_code: "",
    tags: "",
    cards: [
      { id: "35012", count: 1 },
      { id: "30030", count: 3 },
    ],
  },
];

export const MockPlayerBobDecks: Deck[] = [
  {
    details: {
      id: 1,
      player_id: MockPlayerBob.id,
      side_id: "corp",
      name: "Bob's BANGUN",
      identity_title: "BANGUN: When Disaster Strikes",
      min_deck_size: 45,
      max_influence: 15,
      nrdb_uuid: "11111111-1111-1111-1111-111111111111",
      identity_nrdb_card_id: "bangun_when_disaster_strikes",
      created_at: "2026-06-13T00:00:00.000Z",
      updated_at: "2026-06-13T00:00:00.000Z",
      identity_nrdb_printing_id: "35068",
      user_id: MockPlayerBob.user_id,
      faction_id: "weyland_consortium",
      mine: true,
      player_name: null,
    },
    cards: [
      {
        id: 1,
        deck_id: 1,
        title: "Hedge Fund",
        quantity: 3,
        influence: 0,
        nrdb_card_id: "hedge_fund",
        created_at: "2026-06-13T00:00:00.000Z",
        updated_at: "2026-06-13T00:00:00.000Z",
        nrdb_printing_id: "30075",
        card_type_id: "operation",
        faction_id: "neutral_corp",
        influence_cost: 0,
      },
    ],
  },
  {
    details: {
      id: 2,
      player_id: MockPlayerBob.id,
      side_id: "runner",
      name: "Bob's Baz",
      identity_title: "Barry “Baz” Wong: Tri-Maf Veteran",
      min_deck_size: 45,
      max_influence: 15,
      nrdb_uuid: "22222222-2222-2222-2222-222222222222",
      identity_nrdb_card_id: "barry_baz_wong_tri_maf_veteran",
      created_at: "2026-06-13T00:00:00.000Z",
      updated_at: "2026-06-13T00:00:00.000Z",
      identity_nrdb_printing_id: "35012",
      user_id: MockPlayerBob.user_id,
      faction_id: "criminal",
      mine: true,
      player_name: null,
    },
    cards: [
      {
        id: 2,
        deck_id: 2,
        title: "Sure Gamble",
        quantity: 3,
        influence: 0,
        nrdb_card_id: "sure_gamble",
        created_at: "2026-06-13T00:00:00.000Z",
        updated_at: "2026-06-13T00:00:00.000Z",
        nrdb_printing_id: "30030",
        card_type_id: "event",
        faction_id: "neutral_runner",
        influence_cost: 0,
      },
    ],
  },
];

export const MockPlayersData: PlayersData = {
  tournament: MockTournament,
  tournamentPolicies: {
    update: true,
    custom_table_numbering: false,
  },
  activePlayers: [MockPlayerAlice, MockPlayerBob],
  droppedPlayers: [],
};
