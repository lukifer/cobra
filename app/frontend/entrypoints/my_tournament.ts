import { mount } from "svelte";
import MyTournamentPage from "../tournaments/MyTournamentPage.svelte";

document.addEventListener("turbolinks:load", function () {
  const anchor = document.getElementById("my_tournament_anchor");
  if (anchor?.childNodes.length == 0) {
    mount(MyTournamentPage, {
      target: anchor,
      props: {
        tournamentId:
          Number(anchor.getAttribute("data-tournament-id") ?? "") || -1,
        userId: Number(anchor.getAttribute("data-user-id") ?? "") || -1,
      },
    });
  }
});
