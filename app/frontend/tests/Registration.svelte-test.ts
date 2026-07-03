import { beforeEach, describe, expect, it, vi } from "vitest";
import Registration from "../players/Registration.svelte";
import { MockTournament } from "./TournamentTestData";
import {
  MockPlayerBob,
  MockPlayerBobDecks,
  MockPlayerBobNrdbDecks,
} from "./PlayersTestData";
import userEvent from "@testing-library/user-event";
import {
  getByLabelText,
  getByRole,
  getByTestId,
  getByText,
  queryByDisplayValue,
  queryByText,
  render,
  screen,
  waitFor,
} from "@testing-library/svelte";
import { loadTournament } from "../tournaments/TournamentSettings";
import { loadDecks, loadPlayer, savePlayer } from "../players/PlayersData";
import { Identity } from "../identities/Identity";
import {
  getPrintings,
  transformCardLookup,
  type NrdbDeck,
} from "../utils/decks.svelte";
import type { Printing } from "../lib/api_types";

vi.mock("../tournaments/TournamentSettings", async (importOriginal) => ({
  ...(await importOriginal<typeof import("../pairings/PairingsData")>()),
  loadTournament: vi.fn(() => MockTournament),
}));

vi.mock("../players/PlayersData", async (importOriginal) => ({
  ...(await importOriginal<typeof import("../players/PlayersData")>()),
  loadPlayer: vi.fn(() => MockPlayerBob),
  loadDecks: vi.fn(() => []),
  savePlayer: vi.fn(() => true),
}));

vi.mock("../utils/decks.svelte", async (importOriginal) => {
  return {
    ...(await importOriginal<typeof import("../utils/decks.svelte")>()),
    getPrintings: vi.fn(() => MockPrintings),
    transformCardLookup: vi.fn(() => []),
  };
});

const MockBetaBuildPrinting: Printing = {
  id: "36019",
  type: "printings",
  attributes: {
    card_id: "beta_build",
    title: "Beta Build",
    card_type_id: "event",
    side_id: "runner",
    faction_id: "shaper",
    influence_cost: 3,
    influence_limit: null,
    minimum_deck_size: null,
  },
};
const MockSureGamblePrinting: Printing = {
  id: "30030",
  type: "printings",
  attributes: {
    card_id: "sure_gamble",
    title: "Sure Gamble",
    card_type_id: "event",
    side_id: "runner",
    faction_id: "neutral_runner",
    influence_cost: 0,
    influence_limit: null,
    minimum_deck_size: null,
  },
};
const MockBazPrinting: Printing = {
  id: "35012",
  type: "printings",
  attributes: {
    card_id: "barry_baz_wong_tri_maf_veteran",
    title: "Barry “Baz” Wong: Tri-Maf Veteran",
    card_type_id: "runner_identity",
    side_id: "runner",
    faction_id: "criminal",
    influence_cost: null,
    influence_limit: 15,
    minimum_deck_size: 45,
  },
};
const MockZahyaPrinting: Printing = {
  id: "30010",
  type: "printings",
  attributes: {
    card_id: "zahya_sadeghi_versatile_smuggler",
    title: "Zahya Sadeghi: Versatile Smuggler",
    card_type_id: "runner_identity",
    side_id: "runner",
    faction_id: "criminal",
    influence_cost: null,
    influence_limit: 15,
    minimum_deck_size: 40,
  },
};
const MockPrintings = new Map<string, Printing>([
  [
    "35068",
    {
      id: "35068",
      type: "printings",
      attributes: {
        card_id: "bangun_when_disaster_strikes",
        title: "BANGUN: When Disaster Strikes",
        card_type_id: "corp_identity",
        side_id: "corp",
        faction_id: "weyland_consortium",
        influence_cost: null,
        influence_limit: 15,
        minimum_deck_size: 45,
      },
    },
  ],
  [
    "30075",
    {
      id: "30075",
      type: "printings",
      attributes: {
        card_id: "hedge_fund",
        title: "Hedge Fund",
        card_type_id: "operation",
        side_id: "corp",
        faction_id: "neutral_corp",
        influence_cost: 0,
        influence_limit: null,
        minimum_deck_size: null,
      },
    },
  ],
  [MockBazPrinting.id, MockBazPrinting],
  [MockSureGamblePrinting.id, MockSureGamblePrinting],
  [MockBetaBuildPrinting.id, MockBetaBuildPrinting],
]);

const user = userEvent.setup();

describe("Registration", () => {
  async function renderRegistration(nrdbDecks: NrdbDeck[], editMode: boolean) {
    render(Registration, {
      tournamentId: MockTournament.id,
      playerId: MockPlayerBob.id,
      nrdbDecks: nrdbDecks,
      editMode: editMode,
    });

    await waitFor(() => {
      expect(loadTournament).toHaveBeenCalledOnce();
    });
    await waitFor(() => {
      expect(loadPlayer).toHaveBeenCalledOnce();
    });
    await waitFor(() => {
      expect(loadDecks).toHaveBeenCalledOnce();
    });
    if (nrdbDecks.length > 0) {
      await waitFor(() => {
        expect(getPrintings).toHaveBeenCalledOnce();
      });
    }
  }

  beforeEach(() => {
    vi.restoreAllMocks();

    Object.defineProperty(window, "matchMedia", {
      writable: true,
      value: vi.fn().mockImplementation((query: string) => ({
        matches: false,
        media: query,
        onchange: null,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })),
    });
  });

  describe("no existing decks", () => {
    it("displays new player information correctly", async () => {
      await renderRegistration([], false);

      const registrationCard = screen.getByLabelText(
        "registration information",
      );
      expect(getByLabelText(registrationCard, "Name")).toHaveValue("Bob");
      expect(getByLabelText(registrationCard, "Pronouns")).toHaveValue(
        "he/him",
      );
      expect(
        getByLabelText(registrationCard, "Video coverage allowed"),
      ).not.toBeChecked();

      expect(
        screen.queryByText("You have no decks saved in NRDB.", {
          exact: false,
        }),
      ).not.toBeNull();
      expect(screen.getByLabelText("corp deck")).toHaveTextContent(
        "No deck selected",
      );
      expect(screen.getByLabelText("runner deck")).toHaveTextContent(
        "No deck selected",
      );
    });

    it("allows standard player info to be edited", async () => {
      await renderRegistration([], false);

      const registrationCard = screen.getByLabelText(
        "registration information",
      );
      await user.clear(getByLabelText(registrationCard, "Name"));
      await user.type(getByLabelText(registrationCard, "Name"), "Bob Again");
      await user.clear(getByLabelText(registrationCard, "Pronouns"));
      await user.type(
        getByLabelText(registrationCard, "Pronouns"),
        "they/them",
      );
      await user.click(
        getByLabelText(registrationCard, "Video coverage allowed"),
      );

      await user.click(getByRole(registrationCard, "button", { name: "Save" }));

      const bobEdit = structuredClone(MockPlayerBob);
      bobEdit.name = "Bob Again";
      bobEdit.pronouns = "they/them";
      bobEdit.include_in_stream = true;
      bobEdit.corp_id = new Identity();
      bobEdit.runner_id = new Identity();

      expect(savePlayer).toHaveBeenCalledExactlyOnceWith(
        MockTournament.id,
        bobEdit,
        true,
      );
    });

    it("allows deck selection", async () => {
      await renderRegistration(MockPlayerBobNrdbDecks, false);

      const corpDeckHeaderTable = screen.getByLabelText("corp deck");
      const runnerDeckHeaderTable = screen.getByLabelText("runner deck");

      expect(corpDeckHeaderTable).toHaveTextContent("No deck selected");
      expect(runnerDeckHeaderTable).toHaveTextContent("No deck selected");

      const corpDeckButton = getByRole(
        screen.getByLabelText("NRDB corp decks"),
        "button",
        { name: /bob's bangun.*/i },
      );
      expect(corpDeckButton).not.toHaveClass("active");
      await user.click(corpDeckButton);
      expect(corpDeckButton).toHaveClass("active");
      expect(screen.getByLabelText("corp deck")).toHaveTextContent(
        "Bob's BANGUN",
      );
      expect(screen.getByLabelText("corp deck ID")).toHaveTextContent(
        "BANGUN: When Disaster Strikes",
      );
      expect(screen.getByLabelText("corp deck list")).toHaveTextContent(
        "3 Hedge Fund",
      );

      const runnerDeckButton = getByRole(
        screen.getByLabelText("NRDB runner decks"),
        "button",
        { name: /bob's baz.*/i },
      );
      expect(runnerDeckButton).not.toHaveClass("active");
      await user.click(runnerDeckButton);
      expect(runnerDeckButton).toHaveClass("active");
      expect(runnerDeckHeaderTable).toHaveTextContent("Bob's Baz");
      expect(screen.getByLabelText("runner deck ID")).toHaveTextContent(
        "Barry “Baz” Wong: Tri-Maf Veteran",
      );
      expect(screen.getByLabelText("runner deck list")).toHaveTextContent(
        "3 Sure Gamble",
      );
    });
  });

  describe("existing decks", () => {
    beforeEach(() => {
      vi.mocked(loadDecks).mockImplementation(() =>
        Promise.resolve(MockPlayerBobDecks),
      );
    });

    it("displays existing decks correctly", async () => {
      await renderRegistration(MockPlayerBobNrdbDecks, false);

      expect(
        getByRole(screen.getByLabelText("NRDB corp decks"), "button", {
          name: /bob's bangun.*/i,
        }),
      ).toHaveClass("active");
      expect(screen.getByLabelText("corp deck")).toHaveTextContent(
        "Bob's BANGUN",
      );
      expect(screen.getByLabelText("corp deck ID")).toHaveTextContent(
        "BANGUN: When Disaster Strikes",
      );
      expect(screen.getByLabelText("corp deck list")).toHaveTextContent(
        "3 Hedge Fund",
      );

      expect(
        getByRole(screen.getByLabelText("NRDB runner decks"), "button", {
          name: /bob's baz.*/i,
        }),
      ).toHaveClass("active");
      expect(screen.getByLabelText("runner deck")).toHaveTextContent(
        "Bob's Baz",
      );
      expect(screen.getByLabelText("runner deck ID")).toHaveTextContent(
        "Barry “Baz” Wong: Tri-Maf Veteran",
      );
      expect(screen.getByLabelText("runner deck list")).toHaveTextContent(
        "3 Sure Gamble",
      );
    });

    describe("editing decks", () => {
      beforeEach(async () => {
        await renderRegistration([], true);
      });

      it("add a card", async () => {
        await user.click(
          getByRole(
            screen.getByLabelText("registration information"),
            "button",
            { name: "Edit decks in place" },
          ),
        );

        vi.mocked(transformCardLookup).mockImplementation(() => [
          {
            label: MockBetaBuildPrinting.attributes.title,
            value: MockBetaBuildPrinting,
          },
        ]);

        const runnerDeckTable = screen.getByLabelText("runner deck list");

        // Add card
        const newCardRow = getByTestId(runnerDeckTable, "new_card_row");
        await user.type(getByRole(newCardRow, "textbox"), "beta");
        await waitFor(() => {
          expect(getByText(newCardRow, "Build")).toBeInTheDocument();
        });
        await user.keyboard("{Enter}");

        // Validate new card
        expect(
          getByText(runnerDeckTable, MockBetaBuildPrinting.attributes.title),
        ).toBeInTheDocument();
        expect((newCardRow as HTMLInputElement).value).toBeUndefined();

        // Validate diff
        expect(screen.getByLabelText("runner deck changes")).toHaveTextContent(
          `ChangesQty${MockBetaBuildPrinting.attributes.title}+1`,
        );
      });

      it("change a card", async () => {
        await user.click(
          getByRole(
            screen.getByLabelText("registration information"),
            "button",
            { name: "Edit decks in place" },
          ),
        );

        vi.mocked(transformCardLookup).mockImplementation(() => [
          {
            label: MockBetaBuildPrinting.attributes.title,
            value: MockBetaBuildPrinting,
          },
        ]);

        let cardRow = getByTestId(
          screen.getByLabelText("runner deck list"),
          `card_${MockSureGamblePrinting.attributes.card_id}_row`,
        );

        // Change card
        await user.click(getByRole(cardRow, "button", { name: "Edit" }));
        expect(
          getByRole(cardRow, "button", { name: "Cancel" }),
        ).toBeInTheDocument();
        await user.type(getByRole(cardRow, "textbox"), "beta");
        await waitFor(() => {
          expect(getByText(cardRow, "Build")).toBeInTheDocument();
        });
        await user.keyboard("{Enter}");
        cardRow = getByTestId(
          screen.getByLabelText("runner deck list"),
          `card_${MockBetaBuildPrinting.attributes.card_id}_row`,
        );
        await waitFor(() =>
          expect(
            getByRole(cardRow, "button", { name: "Edit" }),
          ).toBeInTheDocument(),
        );

        // Validate change
        expect(
          queryByText(cardRow, MockBetaBuildPrinting.attributes.title),
        ).toBeInTheDocument();
        expect(
          queryByText(cardRow, MockSureGamblePrinting.attributes.title),
        ).not.toBeInTheDocument();

        // Validate diff
        expect(screen.getByLabelText("runner deck changes")).toHaveTextContent(
          `ChangesQty${MockSureGamblePrinting.attributes.title}-3${MockBetaBuildPrinting.attributes.title}+3`,
        );
      });

      it("change a card's quantity", async () => {
        await user.click(
          getByRole(
            screen.getByLabelText("registration information"),
            "button",
            { name: "Edit decks in place" },
          ),
        );

        const runnerDeckTable = screen.getByLabelText("runner deck list");
        const cardRow = getByTestId(
          runnerDeckTable,
          `card_${MockSureGamblePrinting.attributes.card_id}_row`,
        );
        const runnerDiffsTable = screen.getByLabelText("runner deck changes");

        // -1 quantity
        await user.click(getByRole(cardRow, "button", { name: "Remove" }));
        expect(cardRow).toHaveTextContent("2");
        expect(runnerDiffsTable).toHaveTextContent(
          `ChangesQty${MockSureGamblePrinting.attributes.title}-1`,
        );

        // +1 quantity
        await user.click(getByRole(cardRow, "button", { name: "Add" }));
        expect(cardRow).toHaveTextContent("3");
        expect(runnerDiffsTable).toHaveTextContent("ChangesQtyNo changes");
      });

      it("remove a card", async () => {
        await user.click(
          getByRole(
            screen.getByLabelText("registration information"),
            "button",
            { name: "Edit decks in place" },
          ),
        );

        const runnerDeckTable = screen.getByLabelText("runner deck list");

        // Remove card
        const cardRow = getByTestId(
          runnerDeckTable,
          `card_${MockSureGamblePrinting.attributes.card_id}_row`,
        );
        const removeButton = getByRole(cardRow, "button", { name: "Remove" });
        await user.click(removeButton);
        await user.click(removeButton);
        await user.click(removeButton);

        // Validate removal
        expect(
          queryByDisplayValue(
            runnerDeckTable,
            MockSureGamblePrinting.attributes.title,
          ),
        ).not.toBeInTheDocument();

        // Validate diffs
        expect(screen.getByLabelText("runner deck changes")).toHaveTextContent(
          `ChangesQty${MockSureGamblePrinting.attributes.title}-3`,
        );
      });

      it("change an identity", async () => {
        await user.click(
          getByRole(
            screen.getByLabelText("registration information"),
            "button",
            { name: "Edit decks in place" },
          ),
        );

        vi.mocked(transformCardLookup).mockImplementation(() => [
          {
            label: MockZahyaPrinting.attributes.title,
            value: MockZahyaPrinting,
          },
        ]);

        const cardRow = getByTestId(
          screen.getByLabelText("runner deck ID"),
          `identity_row`,
        );

        // Change identity
        await user.click(getByRole(cardRow, "button", { name: "Edit" }));
        expect(
          getByRole(cardRow, "button", { name: "Cancel" }),
        ).toBeInTheDocument();
        await user.type(getByRole(cardRow, "textbox"), "zahya");
        await waitFor(() => {
          expect(
            getByText(cardRow, "Sadeghi: Versatile Smuggler"),
          ).toBeInTheDocument();
        });
        await user.keyboard("{Enter}");
        await waitFor(() =>
          expect(
            getByRole(cardRow, "button", { name: "Edit" }),
          ).toBeInTheDocument(),
        );

        // Validate change
        expect(
          queryByText(cardRow, MockZahyaPrinting.attributes.title),
        ).toBeInTheDocument();
        expect(
          queryByText(cardRow, MockBazPrinting.attributes.title),
        ).not.toBeInTheDocument();

        // Validate diffs
        expect(screen.getByLabelText("runner deck changes")).toHaveTextContent(
          `ChangesQty${MockBazPrinting.attributes.title}-1${MockZahyaPrinting.attributes.title}+1`,
        );
      });
    });
  });
});
