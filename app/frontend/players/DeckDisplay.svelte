<script lang="ts">
  import Identity from "../identities/Identity.svelte";
  import {
    deckCsv,
    type Card,
    type Deck,
    loadPrintings,
    sortCards,
  } from "../utils/decks.svelte";
  import { downloadBlob } from "../utils/files";
  import { getCardTypeImage } from "../utils/images";
  import FontAwesomeIcon from "../widgets/FontAwesomeIcon.svelte";

  let {
    deck = $bindable(),
    isCorp,
    editMode,
  }: {
    deck?: Deck;
    isCorp: boolean;
    editMode: boolean;
  } = $props();

  $effect(() => {
    if (deck) {
      sortCards(deck.cards);
    }
  });

  let cardTotal = $derived.by(() => {
    if (!deck) {
      return 0;
    }

    return deck.cards
      .filter((card: Card) => !card.card_type_id.endsWith("identity"))
      .reduce((total: number, card: Card) => total + card.quantity, 0);
  });
  let influenceTotal = $derived.by(() => {
    if (!deck) {
      return 0;
    }

    return deck.cards
      .filter((card: Card) => card.faction_id !== deck.details.faction_id)
      .reduce((total: number, card: Card) => total + card.influence, 0);
  });

  function adjustFactionId(factionId: string) {
    return factionId.replace("_", "-");
  }

  async function copyToClipboard() {
    if (!deck) {
      return;
    }

    await navigator.clipboard.writeText(
      deck.cards.reduce(
        (text: string, card: Card) => `${text}${card.quantity} ${card.title}\n`,
        "",
      ),
    );
    alert("Copied to clipboard");
  }

  function downloadCsv() {
    if (!deck) {
      return;
    }

    downloadBlob(
      `${deck.details.player_name} - ${deck.details.name}.csv`,
      new Blob([deckCsv([deck])], { type: "text/csv" }),
    );
  }

  async function searchCard(name: string, cardType?: string) {
    if (!deck || !name) {
      return null;
    }

    let queryString = `filter[side_id]=${deck.details.side_id}&filter[search]=${name}&filter[distinct_cards]=true&page[size]=1`;
    if (cardType) {
      queryString += `filter[card_type_id]=${cardType}`;
    }

    const printings = await loadPrintings(queryString);
    return !printings ||
      (printings.meta?.stats?.total?.count &&
        printings.meta.stats.total.count !== 1)
      ? null
      : printings;
  }

  async function identityNameChanged(event: {
    currentTarget: HTMLInputElement;
  }) {
    const currentTarget = event.currentTarget;

    if (!deck) {
      setInputValidity(currentTarget, false);
      return;
    }

    const printings = await searchCard(
      currentTarget.value,
      `${deck.details.side_id}_identity`,
    );
    if (!printings) {
      setInputValidity(currentTarget, false);
      return;
    }

    deck.details.identity_nrdb_printing_id = printings.data[0].id;
    deck.details.identity_nrdb_card_id = printings.data[0].attributes.card_id;
    deck.details.identity_title = printings.data[0].attributes.title;
    deck.details.faction_id = printings.data[0].attributes.faction_id;
    deck.details.min_deck_size = printings.data[0].attributes.minimum_deck_size;
    deck.details.max_influence = printings.data[0].attributes.influence_limit;
    setInputValidity(currentTarget, true);
  }

  async function cardNameChanged(
    event: { currentTarget: HTMLInputElement },
    card: Card,
  ) {
    const currentTarget = event.currentTarget;
    const printings = await searchCard(currentTarget.value);
    if (!deck || !printings) {
      setInputValidity(currentTarget, false);
      return;
    }

    const i = deck.cards.indexOf(card);
    if (i === -1) {
      setInputValidity(currentTarget, false);
      return;
    }

    deck.cards.splice(i, 1, {
      id: card.id,
      deck_id: card.deck_id,
      title: printings.data[0].attributes.title,
      quantity: card.quantity,
      influence: printings.data[0].attributes.influence_cost * card.quantity,
      nrdb_card_id: printings.data[0].attributes.card_id,
      created_at: "",
      updated_at: "",
      nrdb_printing_id: card.id,
      card_type_id: printings.data[0].attributes.card_type_id,
      faction_id: printings.data[0].attributes.faction_id,
      influence_cost: printings.data[0].attributes.influence_cost,
    });
    setInputValidity(currentTarget, true);
  }

  async function addCard(event: { currentTarget: HTMLInputElement }) {
    const currentTarget = event.currentTarget;
    const printings = await searchCard(currentTarget.value);
    if (!deck || !printings) {
      setInputValidity(currentTarget, false);
      return;
    }

    deck.cards.push({
      id: "",
      deck_id: deck.details.id,
      title: printings.data[0].attributes.title,
      quantity: 1,
      influence: printings.data[0].attributes.influence_cost,
      nrdb_card_id: printings.data[0].attributes.card_id,
      created_at: "",
      updated_at: "",
      nrdb_printing_id: printings.data[0].id,
      card_type_id: printings.data[0].attributes.card_type_id,
      faction_id: printings.data[0].attributes.faction_id,
      influence_cost: printings.data[0].attributes.influence_cost,
    });
    currentTarget.classList.remove("is-valid", "is-invalid");
    currentTarget.value = "";
  }

  function changeQuantity(card: Card, delta: number) {
    if (!deck) {
      return;
    }

    card.quantity += delta;
    if (card.quantity === 0) {
      const i = deck.cards.indexOf(card);
      if (i !== -1) {
        deck.cards.splice(i, 1);
      }
    }
  }

  function setInputValidity(input: HTMLInputElement, valid: boolean) {
    input.classList.remove("is-valid", "is-invalid");
    input.classList.add(valid ? "is-valid" : "is-invalid");
  }
</script>

<!-- Deck summary -->
<table class="table table-bordered table-striped">
  <thead class="thead-dark">
    <tr>
      <th class="text-center deck-name-header">
        {isCorp ? "Corp Deck" : "Runner Deck"}
      </th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        {#if deck && deck.details.id !== 0}
          {#if deck.details.name}
            {deck.details.name}
            <div class="float-right dontprint">
              <span class="dropdown">
                <button
                  type="button"
                  title="Export deck"
                  class="btn btn-link p-0"
                  data-toggle="dropdown"
                  aria-haspopup="true"
                  aria-expanded="false"
                >
                  <FontAwesomeIcon icon="download" />
                </button>
                <div class="dropdown-menu">
                  <button
                    type="button"
                    class="dropdown-item"
                    onclick={copyToClipboard}
                  >
                    Copy to clipboard in NetrunnerDB format
                  </button>
                  <button
                    type="button"
                    class="dropdown-item"
                    onclick={downloadCsv}
                  >
                    Download as a CSV spreadsheet
                  </button>
                </div>
              </span>
              {#if deck.details.mine}
                <a
                  href="https://netrunnerdb.com/en/deck/edit/{deck.details
                    .nrdb_uuid}"
                  target="_blank"
                  title="Edit Deck"
                  class="ml-2"
                >
                  <FontAwesomeIcon icon="external-link" />
                </a>
              {/if}
            </div>
          {:else}
            Unnamed deck
          {/if}
        {:else}
          No deck selected
        {/if}
      </td>
    </tr>
  </tbody>
</table>

{#if deck && deck.details.id !== 0}
  <!-- Identity -->
  <table class="table table-bordered table-striped">
    <thead class="thead-dark">
      <tr>
        <th class="text-center deck-side-column">Min</th>
        <th class="text-center">Identity</th>
        <th class="text-center deck-side-column">Max</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="text-center align-middle">{deck.details.min_deck_size}</td>
        <td>
          {#if editMode}
            <input
              id="name"
              type="text"
              placeholder="Enter identity name"
              class="form-control"
              value={deck.details.identity_title}
              onchange={async (e) => {
                await identityNameChanged(e);
              }}
            />
          {:else}
            <Identity
              identity={{
                name: deck.details.identity_title ?? "",
                faction: adjustFactionId(deck.details.faction_id ?? ""),
              }}
            />
          {/if}
        </td>
        <td class="text-center align-middle">{deck.details.max_influence}</td>
      </tr>
    </tbody>
  </table>

  <!-- Deck list -->
  <table class="table table-bordered table-striped">
    <thead class="thead-dark">
      <tr>
        <th class="text-center deck-side-column">Qty</th>
        <th class="text-center">Card Name</th>
        <th class="text-center deck-side-column">Inf</th>
      </tr>
    </thead>
    <tbody>
      <!-- Cards -->
      {#each deck.cards as card (card.id)}
        <tr>
          <td class="text-center align-middle">
            {#if editMode}
              <button
                type="button"
                title="Remove"
                class="btn btn-link p-0"
                onclick={() => {
                  changeQuantity(card, -1);
                }}
              >
                <FontAwesomeIcon icon="minus" />
              </button>
            {/if}
            {card.quantity}
            {#if editMode}
              <button
                type="button"
                title="Add"
                class="btn btn-link p-0"
                onclick={() => {
                  changeQuantity(card, 1);
                }}
              >
                <FontAwesomeIcon icon="plus" />
              </button>
            {/if}
          </td>
          <td>
            {#if editMode}
              <input
                id="name"
                type="text"
                placeholder="Enter card name"
                class="form-control"
                value={card.title}
                onchange={async (e) => {
                  await cardNameChanged(e, card);
                }}
              />
            {:else}
              <img
                src={getCardTypeImage(card.card_type_id)}
                alt={card.card_type_id}
              />
              <i
                class="fa icon icon-{adjustFactionId(
                  card.faction_id,
                )} {adjustFactionId(card.faction_id)}"
              ></i>
              {card.title}
            {/if}
          </td>
          <td class="text-center align-middle">
            {#if card.influence_cost && card.faction_id != deck.details.faction_id}
              {card.influence_cost * card.quantity}
            {/if}
          </td>
        </tr>
      {/each}
      {#if editMode}
        <tr>
          <td></td>
          <td>
            <input
              id="name"
              type="text"
              placeholder="Enter card name"
              class="form-control"
              onchange={async (e) => {
                await addCard(e);
              }}
            />
          </td>
          <td></td>
        </tr>
      {/if}

      <!-- Totals -->
      <tr>
        <td class="text-center deck-side-column">{cardTotal}</td>
        <td
          class="text-center"
          style="color: #FFFFFF; background-color: #343A40;"
        >
          Totals
        </td>
        <td class="text-center deck-side-column">{influenceTotal}</td>
      </tr>
    </tbody>
  </table>
{/if}
