# CLAUDE.md

## Project: Podcast / YouTube Tracker (Haskell CRUD app, learning project)

## READ THIS FIRST: working mode

This is a **learning project**. The user (Ananda Prem) wants to write the code themselves but with extensive help from you.
- Act as a **mentor**. Explain concepts, review the user's code, and help decode GHC errors.
- Give **hints before answers**. Escalate in this order: hint, then small example, then worked solution. Only write full modules when the user explicitly asks.
- The user attempts each milestone first, then pastes code or errors for review.
- After each milestone, review for idiomatic Haskell and point out improvements.
- Do not scaffold the whole project unprompted.

## What the app does

Log podcast episodes and YouTube videos the user has consumed, each with a short summary and the user's initial thoughts. Entries are stored in the app and mirrored to a Notion database.

## Current status (as of 2026-10-21)

**Planning only. No code has been written yet.** No repo, cabal project, or flake exists.
Done so far:
- Researched Namma Yatri's open-source stack as a reference.
- Chose the learning-first milestone plan below.
- A plan doc exists in Claude Docs: "Haskell Podcast Tracker: Learning Plan".

Next step: the user installs GHCup (GHC, cabal, HLS), creates a fresh cabal project, and does the first exercise (see Milestone 1).

## Open questions (unanswered)

1. The user's current Haskell level (none, some exercises, or comfortable with monads) has not been stated. Ask before pitching explanations.
2. Whether summaries are written by hand or eventually drafted by an LLM. This only affects Milestone 6 and can wait.
3. Whether to use Postgres or SQLite first at Milestone 4 is undecided.

## Architectural decisions

1. **Postgres is the source of truth; Notion is a mirror.** The app owns the data and pushes each entry to Notion. This was recommended over "Notion as the only store" because it gives real CRUD and a database layer to learn. (The user has not explicitly confirmed this, so treat it as the working assumption.)
2. **Learn plain Haskell first, add the Namma Yatri-style stack later.** Nix, Beam and services-flake add heavy tooling, so each is introduced only after there is a working app to apply it to.
3. **Raw SQL before Beam.** Use `postgresql-simple` (or `sqlite-simple`) first, then refactor the storage layer to Beam, so the user sees what Beam abstracts.
4. **Skip Juspay's in-house frameworks** (euler-hs, namma-dsl, shared-kernel). They are built for a city-scale platform and are thinly documented outside that codebase.
5. **Keep pure logic free of `IO`.** Domain functions are pure; effects live in the API, storage and external-client layers.

## Tech stack

Planned (nothing installed yet):

| Layer | Choice |
|---|---|
| Language / toolchain | Haskell, GHCup, GHC, cabal, HLS |
| JSON | aeson |
| Web API | Servant |
| Database | Postgres (SQLite acceptable to start); `postgresql-simple` or `sqlite-simple`, later Beam |
| HTTP client for Notion | `req` or `http-client` (optionally `servant-client`) |
| Config / state | `ReaderT` with an `AppEnv`; `IORef` or `STM` for shared state |
| Dev environment (late) | Nix flakes, direnv, `haskell-flake`, `services-flake` |
| Tests (stretch) | hspec, plus property tests |

## Namma Yatri reference (what was verified)

Repo: https://github.com/nammayatri/nammayatri (Backend README: `Backend/README.md`).
- Backend is Haskell with **Servant**; API modules under `API.*`, business logic under `Domain.Action.*`.
- Built and developed with **Nix + direnv**; the README recommends **cabal** over `nix build` for local iteration.
- Local infrastructure (Postgres, Redis, Kafka, etc.) is run via **services-flake**.
- The org also publishes `euler-hs`, `namma-dsl` and a Haskell Redis client.
- **Not verified from sources:** that they use Beam for DB access. It was stated from general knowledge; confirm in their code before relying on it.

## Planned code layout (mirrors their layering, scaled down)

```
src/
  API/Entries.hs          -- Servant types + handlers
  Domain/Action/Entry.hs  -- create/update logic; calls storage + Notion
  Domain/Types/Entry.hs   -- pure types
  Storage/Beam/Entry.hs   -- table + queries (initially raw SQL, later Beam)
  External/Notion.hs      -- Notion API client
flake.nix                 -- added at Milestone 7
```

## Data model (design sketch, not yet implemented)

```haskell
data MediaType = Podcast | YouTube

data Entry = Entry
  { entryId         :: Id Entry
  , title           :: Text
  , mediaType       :: MediaType
  , source          :: Text         -- show or channel name
  , url             :: Maybe Text
  , consumedOn      :: Day
  , summary         :: Text
  , initialThoughts :: Text
  , tags            :: [Text]
  , notionPageId    :: Maybe Text   -- set after Notion sync
  }
```

## Planned API (Servant)

- `POST /entries` creates an entry and syncs it to Notion
- `GET /entries` lists entries, filterable by `?type=` and `?tag=`
- `GET /entries/:id`
- `PUT /entries/:id` updates the entry and the Notion page
- `DELETE /entries/:id` deletes the entry and archives the Notion page
- `POST /entries/:id/resync`

## Notion integration notes

- No well-maintained Haskell SDK is assumed; call Notion's REST API directly.
- Create an internal Notion integration, share the target database with it, and keep the token in an environment variable (never commit it).
- Notion's rich-text JSON is deeply nested, so expect hand-written `ToJSON` instances; this is a deliberate aeson learning exercise.

## Milestones (all not started)

1. **Pure core in a CLI.** Write `Entry` and `MediaType`, pure add/update/delete/filter functions, and a small `main` with in-memory state. Concepts: records, sum types, `Maybe`/`Either`, pattern matching, `Show`/`Eq`, `Data.Text`, basic `IO`. Done when add, list, edit and delete work in a running CLI and the logic has no `IO`.
   - **First exercise:** design `Entry` and `MediaType` in a fresh cabal project, then write `addEntry :: Entry -> [Entry] -> [Entry]`.
2. **JSON file persistence** with aeson. Concepts: `Functor`/`Applicative`/`Monad` through use, decode errors, `IORef`. Done when data survives restarts.
3. **Servant API on an in-memory store.** Concepts: type-level API description, `Handler`, `ReaderT`, `STM`/`IORef`. Done when all five endpoints work via curl.
4. **Real database.** Raw SQL first, then refactor to Beam. Done when the API runs on a database with storage in its own module.
5. **Layered refactor** into `API/`, `Domain/`, `Storage/`, `External/` with an `AppEnv` via `ReaderT`.
6. **Notion sync** on create, update and delete, storing `notionPageId`. Concepts: HTTP errors, `Either`/`ExceptT`, secrets from env vars.
7. **Nix, direnv, services-flake.** Done when `direnv allow` gives the toolchain and a local Postgres.
8. **Stretch:** hspec and property tests; then read Namma Yatri's `Backend/` and see how much is now readable.

## Conventions

- Keep domain functions pure; push `IO` to the edges.
- Prefer `Data.Text` over `String` for user-facing text.
- Use cabal for builds; do not introduce Nix before Milestone 7.
- Never commit secrets (Notion token, DB passwords); read them from environment variables.

## Suggested references

- *Learn You a Haskell* (gentle start), *Haskell Programming from First Principles* (deeper), and the official Servant tutorial (Milestone 3).