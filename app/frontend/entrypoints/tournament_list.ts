import { mount } from "svelte";
import TournamentList from "../tournaments/TournamentList.svelte";

document.addEventListener("turbolinks:load", function () {
  const anchor = document.getElementById("tournament_list_anchor");
  if (anchor?.childNodes.length == 0) {
    const userIdAttr = anchor.getAttribute("data-user-id");

    mount(TournamentList, {
      target: anchor,
      props: {
        typeId: anchor.getAttribute("data-type-id") ?? "",
        userId: userIdAttr && userIdAttr.length > 0 ? Number(userIdAttr) : null,
      },
    });
  }
});
