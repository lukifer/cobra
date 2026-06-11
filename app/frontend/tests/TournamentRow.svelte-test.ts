import { describe, expect, it } from "vitest";
import { render } from "@testing-library/svelte";
import TournamentRow from "../widgets/TournamentRow.svelte";

describe("TournamentRow", () => {
  const mockTournament = {
    id: "1",
    attributes: {
      name: "Test Tournament",
      date: "2024-05-23T00:00:00.000Z",
      active_player_count: 42,
      tournament_organizer: "Test Organizer",
      stream_url: "https://twitch.tv/test",
      tournament_type_id: 1,
      user_id: 10,
    },
  };

  it("renders tournament details", () => {
    const { getByText } = render(TournamentRow, {
      showDelete: true,
      tournament: mockTournament,
      userId: 10,
      tournamentTypeName: "Standard",
    });

    expect(getByText("Test Tournament")).toBeDefined();
    // active_player_count
    expect(getByText(/42 active players/)).toBeDefined();
    // tournamentTypeName
    expect(getByText("Standard")).toBeDefined();
    // tournament organizer
    expect(getByText(/- Test Organizer/)).toBeDefined();
    // delete action should be visible since showDelete=true and userId matches user_id
    expect(getByText("Delete")).toBeDefined();
  });

  it("does not render delete action if showDelete is false", () => {
    const { queryByText } = render(TournamentRow, {
      showDelete: false,
      tournament: mockTournament,
      userId: 10,
    });

    expect(queryByText("Delete")).toBeNull();
  });

  it("does not render delete action if userId does not match", () => {
    const { queryByText } = render(TournamentRow, {
      showDelete: true,
      tournament: mockTournament,
      userId: 20,
    });

    expect(queryByText("Delete")).toBeNull();
  });
});
