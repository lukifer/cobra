import { Identity } from "../identities/Identity";
import type { TournamentPolicies } from "../pairings/PairingsData";
import type { Tournament } from "../tournaments/TournamentSettings";
import type { Card, Deck } from "../utils/decks.svelte";
import { globalMessages } from "../utils/GlobalMessageState.svelte";
import { csrfToken } from "../utils/network";

declare const Routes: {
  players_data_beta_tournament_players_path: (tournamentId: number) => string;
  beta_tournament_players_path: (tournamentId: number) => string;
  beta_tournament_player_path: (
    tournamentId: number,
    playerId: number,
  ) => string;
  drop_beta_tournament_player_path: (
    tournamentId: number,
    playerId: number,
  ) => string;
  reinstate_beta_tournament_player_path: (
    tournamentId: number,
    playerId: number,
  ) => string;
  lock_registration_beta_tournament_player_path: (
    tournamentId: number,
    playerId: number,
  ) => string;
  unlock_registration_beta_tournament_player_path: (
    tournamentId: number,
    playerId: number,
  ) => string;
};

export async function loadPlayer(tournamentId: number, playerId: number) {
  try {
    const response = await fetch(
      `/beta/tournaments/${tournamentId}/players/${playerId}`,
      {
        method: "GET",
      },
    );

    const player = new Player();
    Object.assign(player, await response.json());
    return player;
  } catch {
    globalMessages.errors.push(
      `Error loading player data for player ${playerId}.`,
    );
    return null;
  }
}

export async function loadPlayerByUserId(tournamentId: number, userId: number) {
  try {
    const response = await fetch(
      `/beta/tournaments/${tournamentId}/players/by_user_id/${userId}`,
      {
        method: "GET",
      },
    );

    return (await response.json()) as Player;
  } catch {
    globalMessages.errors.push(`Error loading player data for user ${userId}.`);
    return null;
  }
}

export async function loadPlayers(tournamentId: number) {
  const response = await fetch(
    Routes.players_data_beta_tournament_players_path(tournamentId),
    {
      method: "GET",
    },
  );

  return (await response.json()) as PlayersData;
}

export async function savePlayer(
  tournamentId: number,
  player: Player,
  organizerView = false,
) {
  const route =
    player.id === 0
      ? Routes.beta_tournament_players_path(tournamentId)
      : Routes.beta_tournament_player_path(tournamentId, player.id);
  const response = await fetch(route, {
    method: player.id === 0 ? "POST" : "PATCH",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    body: JSON.stringify({
      player: playerRequestObject(player),
      organiser_view: organizerView,
    }),
  });

  const result = (await response.json()) as {
    player: Player;
    errors?: string[];
  };
  globalMessages.errors = result.errors ?? [];

  return result.player;
}

export async function togglePlayerLock(tournamentId: number, player: Player) {
  const route = player.registration_locked
    ? Routes.unlock_registration_beta_tournament_player_path(
        tournamentId,
        player.id,
      )
    : Routes.lock_registration_beta_tournament_player_path(
        tournamentId,
        player.id,
      );
  const response = await fetch(route, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    body: JSON.stringify({ player: playerRequestObject(player) }),
  });

  return response.status === 200;
}

export async function dropPlayer(tournamentId: number, player: Player) {
  const response = await fetch(
    Routes.drop_beta_tournament_player_path(tournamentId, player.id),
    {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ player: playerRequestObject(player) }),
    },
  );

  return response.status === 200;
}

export async function deletePlayer(tournamentId: number, player: Player) {
  const response = await fetch(
    Routes.beta_tournament_player_path(tournamentId, player.id),
    {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ player: playerRequestObject(player) }),
    },
  );

  return response.status === 200;
}

export async function reinstatePlayer(tournamentId: number, player: Player) {
  const response = await fetch(
    Routes.reinstate_beta_tournament_player_path(tournamentId, player.id),
    {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ player: playerRequestObject(player) }),
    },
  );

  return response.status === 200;
}

export async function loadDecks(tournamentId: number, playerId?: number) {
  const response = await fetch(
    playerId === undefined
      ? `/beta/tournaments/${tournamentId}/players/decks`
      : `/beta/tournaments/${tournamentId}/players/${playerId}/decks`,
    {
      method: "GET",
    },
  );

  return (await response.json()) as Deck[];
}

function playerRequestObject(player: Player) {
  return {
    name: player.name,
    pronouns: player.pronouns,
    corp_identity: player.corp_id.name,
    runner_identity: player.runner_id.name,
    include_in_stream: player.include_in_stream,
    first_round_bye: player.first_round_bye,
    manual_seed: player.manual_seed,
    fixed_table_number: player.fixed_table_number,
    corp_deck: player.corp_deck
      ? deckRequestObject(player.corp_deck)
      : undefined,
    runner_deck: player.runner_deck
      ? deckRequestObject(player.runner_deck)
      : undefined,
  };
}

function deckRequestObject(deck: Deck) {
  const {
    id,
    user_id,
    player_id,
    player_name,
    created_at,
    updated_at,
    ...details
  } = deck.details;

  return {
    details: details,
    cards: deck.cards.map((c) => cardRequestObject(c)),
  };
}

function cardRequestObject(card: Card) {
  const { id, deck_id, created_at, updated_at, ...newCard } = card;

  return newCard;
}

export interface PlayersData {
  tournament: Tournament;
  tournamentPolicies: TournamentPolicies;
  activePlayers: Player[];
  droppedPlayers: Player[];
}

export class Player {
  id = 0;
  name = "";
  pronouns = "";
  name_with_pronouns = "";
  user_id = 0;
  corp_id = new Identity();
  runner_id = new Identity();
  registration_locked = false;
  include_in_stream = false;
  active: boolean | null = null;
  first_round_bye = false;
  manual_seed: number | null = null;
  fixed_table_number: number | null = null;
  side: string | null = null;
  side_label: string | null = null;
  corp_deck?: Deck;
  runner_deck?: Deck;
}
