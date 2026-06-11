import { describe, expect, it, vi, beforeEach } from "vitest";
import { fireEvent, render, waitFor } from "@testing-library/svelte";
import TournamentList from "../tournaments/TournamentList.svelte";

function toUrl(input: RequestInfo | URL): string {
  if (typeof input === "string") return input;
  if (input instanceof URL) return input.toString();
  return input.url;
}

describe("TournamentList", () => {
  beforeEach(() => {
    global.fetch = vi.fn((input: RequestInfo | URL) => {
      const url = toUrl(input);

      if (url.includes("/api/v1/public/tournament_types")) {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "11",
                  type: "tournament_types",
                  attributes: {
                    name: "Standard",
                  },
                },
              ],
            }),
        });
      }

      return Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve({
            data: [
              {
                id: "100",
                attributes: {
                  name: "First Tournament",
                  date: "2026-05-20",
                  active_player_count: 5,
                  tournament_organizer: "tester",
                  stream_url: "",
                  tournament_type_id: 11,
                  user_id: 10,
                },
              },
              {
                id: "101",
                attributes: {
                  name: "Second Tournament",
                  date: "2026-05-21",
                  active_player_count: 1,
                  tournament_organizer: "tester2",
                  stream_url: "https://twitch.tv/example",
                  tournament_type_id: 11,
                  user_id: 42,
                },
              },
            ],
            links: {
              prev: null,
              next: "/api/v1/public/tournaments?page[number]=2",
            },
          }),
      });
    }) as unknown as typeof fetch;
  });

  it("renders correctly for recent tournaments", async () => {
    const { getAllByText, getByText, queryByText } = render(TournamentList);

    expect(getByText("Recent Tournaments")).toBeTruthy();

    expect(getAllByText("Loading...").length).toBeGreaterThan(0);

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        "/api/v1/public/tournaments?page[size]=10&include=tournament_type&sort=-date,name",
        expect.any(Object),
      );
      expect(getByText("First Tournament")).toBeTruthy();
      expect(getByText("Second Tournament")).toBeTruthy();
    });

    // userId is null, so no delete options should render
    expect(queryByText("Delete")).toBeNull();
  });

  it("renders correctly with specific typeId and user info", async () => {
    const { getByText, getByRole } = render(TournamentList, {
      props: {
        typeId: "11",
        userId: 42,
      },
    });

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        "/api/v1/public/tournaments?page[size]=10&include=tournament_type&sort=-date,name&filter[tournament_type_id]=11",
        expect.any(Object),
      );
      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringMatching(/\/api\/v1\/public\/tournament_types/),
        expect.any(Object),
      );
      expect(getByText("Tournaments: Standard")).toBeTruthy();
      expect(getByText("Second Tournament")).toBeTruthy();
    });

    // userId evaluates to 42, which matches Second Tournament but not First Tournament
    const deleteButtons = getByRole("link", { name: /Delete/i });
    expect(deleteButtons).toBeTruthy();
  });

  it("loads next page when API provides a next link", async () => {
    global.fetch = vi.fn().mockImplementation((input: RequestInfo | URL) => {
      const url = toUrl(input);

      if (url.includes("/api/v1/public/tournament_types")) {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "11",
                  type: "tournament_types",
                  attributes: {
                    name: "Standard",
                  },
                },
              ],
            }),
        });
      }

      if (url === "/api/v1/public/tournaments?page[number]=2") {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "200",
                  attributes: {
                    name: "Third Tournament",
                    date: "2026-05-22",
                    active_player_count: 9,
                    tournament_organizer: "tester3",
                    stream_url: "",
                    tournament_type_id: 11,
                    user_id: 10,
                  },
                },
              ],
              links: {
                prev: "/api/v1/public/tournaments?page[number]=1",
                next: null,
              },
            }),
        });
      }

      return Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve({
            data: [
              {
                id: "100",
                attributes: {
                  name: "First Tournament",
                  date: "2026-05-20",
                  active_player_count: 5,
                  tournament_organizer: "tester",
                  stream_url: "",
                  tournament_type_id: 11,
                  user_id: 10,
                },
              },
            ],
            links: {
              prev: null,
              next: "/api/v1/public/tournaments?page[number]=2",
            },
          }),
      });
    });

    const { getAllByRole, getByText, queryByText } = render(TournamentList, {
      props: {
        typeId: "11",
        userId: null,
      },
    });

    await waitFor(() => {
      expect(getByText("First Tournament")).toBeTruthy();
    });

    const nextButtons = getAllByRole("button", { name: /Next/i });
    await fireEvent.click(nextButtons[0]);

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        "/api/v1/public/tournaments?page[number]=2",
        expect.any(Object),
      );
      expect(getByText("Third Tournament")).toBeTruthy();
      expect(queryByText("First Tournament")).toBeNull();
    });
  });

  it("shows generic tournaments title when typeId has no matching tournament type", async () => {
    global.fetch = vi.fn((input: RequestInfo | URL) => {
      const url = toUrl(input);

      if (url.includes("/api/v1/public/tournament_types")) {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "99",
                  type: "tournament_types",
                  attributes: {
                    name: "Other",
                  },
                },
              ],
            }),
        });
      }

      return Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve({
            data: [],
            links: {
              prev: null,
              next: null,
            },
          }),
      });
    }) as unknown as typeof fetch;

    const { getByText } = render(TournamentList, {
      props: {
        typeId: "11",
        userId: null,
      },
    });

    await waitFor(() => {
      expect(getByText("Tournaments")).toBeTruthy();
    });
  });

  it("keeps current results visible while next page is loading", async () => {
    let resolveSecondFetch:
      | ((value: { ok: boolean; json: () => Promise<unknown> }) => void)
      | undefined;

    const secondFetchPromise = new Promise<{
      ok: boolean;
      json: () => Promise<unknown>;
    }>((resolve) => {
      resolveSecondFetch = resolve;
    });

    global.fetch = vi.fn((input: RequestInfo | URL) => {
      const url = toUrl(input);

      if (url.includes("/api/v1/public/tournament_types")) {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "11",
                  type: "tournament_types",
                  attributes: {
                    name: "Standard",
                  },
                },
              ],
            }),
        });
      }

      if (url === "/api/v1/public/tournaments?page[number]=2") {
        return secondFetchPromise as unknown as ReturnType<typeof fetch>;
      }

      return Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve({
            data: [
              {
                id: "100",
                attributes: {
                  name: "First Tournament",
                  date: "2026-05-20",
                  active_player_count: 5,
                  tournament_organizer: "tester",
                  stream_url: "",
                  tournament_type_id: 11,
                  user_id: 10,
                },
              },
            ],
            links: {
              prev: null,
              next: "/api/v1/public/tournaments?page[number]=2",
            },
          }),
      });
    }) as unknown as typeof fetch;

    const { getAllByRole, getAllByText, getByText } = render(TournamentList, {
      props: {
        typeId: "11",
        userId: null,
      },
    });

    await waitFor(() => {
      expect(getByText("First Tournament")).toBeTruthy();
    });

    const backButtons = getAllByRole("button", { name: /Back/i });
    const nextButtons = getAllByRole("button", { name: /Next/i });
    await fireEvent.click(nextButtons[0]);

    await waitFor(() => {
      expect(getByText("First Tournament")).toBeTruthy();
      expect(getAllByText("Loading...").length).toBeGreaterThan(0);
      expect(backButtons[0]).toBeDisabled();
      expect(nextButtons[0]).toBeDisabled();
    });

    resolveSecondFetch?.({
      ok: true,
      json: () =>
        Promise.resolve({
          data: [
            {
              id: "200",
              attributes: {
                name: "Third Tournament",
                date: "2026-05-22",
                active_player_count: 9,
                tournament_organizer: "tester3",
                stream_url: "",
                tournament_type_id: 11,
                user_id: 10,
              },
            },
          ],
          links: {
            prev: "/api/v1/public/tournaments?page[number]=1",
            next: null,
          },
        }),
    });

    await waitFor(() => {
      expect(getByText("Third Tournament")).toBeTruthy();
      expect(backButtons[0]).toBeEnabled();
      expect(nextButtons[0]).toBeDisabled();
    });
  });
});
