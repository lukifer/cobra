import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, waitFor } from "@testing-library/svelte";
import Home from "../home/Home.svelte";

function toUrl(input: RequestInfo | URL): string {
  if (typeof input === "string") return input;
  if (input instanceof URL) return input.toString();
  return input.url;
}

describe("Home", () => {
  beforeEach(() => {
    global.fetch = vi.fn((input: RequestInfo | URL) => {
      const url = toUrl(input);

      if (url.includes("/api/v1/public/tournaments")) {
        return Promise.resolve({
          ok: true,
          json: () =>
            Promise.resolve({
              data: [
                {
                  id: "1",
                  type: "tournaments",
                  attributes: {
                    name: "Test Today Tournament",
                    date: new Date().toISOString(),
                    active_player_count: 10,
                    tournament_organizer: "Test Organizer",
                    stream_url: "",
                    tournament_type_id: 1,
                    user_id: 1,
                  },
                },
              ],
              included: [
                {
                  id: "1",
                  type: "tournament_types",
                  attributes: { name: "Standard" },
                },
              ],
            }),
        });
      }

      return Promise.reject(new Error(`Unhandled request: ${url}`));
    }) as unknown as typeof fetch;
  });

  it("displays the home page content and fetches tournaments", async () => {
    const { getByText, getByPlaceholderText } = render(Home);

    expect(getByText("Today's tournaments").tagName).toBe("H4");
    expect(getByText("Got a shortcode?").tagName).toBe("LABEL");
    expect(getByPlaceholderText("SHRT")).toBeDefined();
    expect(getByText("More tournaments")).toBeDefined();

    await waitFor(() => {
      expect(getByText("Test Today Tournament")).toBeDefined();
    });
  });
});
