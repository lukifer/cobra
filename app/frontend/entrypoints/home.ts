import { mount } from "svelte";
import Home from "../home/Home.svelte";

document.addEventListener("turbolinks:load", function () {
  const anchor = document.getElementById("beta_home_anchor");
  if (anchor?.childNodes.length == 0) {
    mount(Home, {
      target: anchor,
    });
  }
});
