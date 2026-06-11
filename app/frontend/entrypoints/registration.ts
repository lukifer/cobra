import { mount } from "svelte";
import Registration from "../players/Registration.svelte";
import { type NrdbDeck } from "../utils/decks.svelte";

document.addEventListener("turbolinks:load", function () {
  const anchor = document.getElementById("registration_anchor");
  if (anchor?.childNodes.length == 0) {
    let decks: NrdbDeck[] = [];
    if (anchor.getAttribute("data-user-decks")) {
      try {
        decks = JSON.parse(
          anchor.getAttribute("data-user-decks") ?? "",
        ) as NrdbDeck[];
      } catch {
        decks = [];
      }
    }

    mount(Registration, {
      target: anchor,
      props: {
        tournamentId:
          Number(anchor.getAttribute("data-tournament-id") ?? "") || -1,
        playerId: Number(anchor.getAttribute("data-player-id") ?? "") || -1,
        nrdbDecks: decks,
      },
    });
  }
});
