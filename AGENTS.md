<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->

# vtex.js — Agent Context

## Project Purpose

`vtex.js` is a legacy JavaScript/CoffeeScript browser SDK that exposes methods to interact with VTEX's Checkout and Catalog APIs. It provides the global `vtexjs.checkout` and `vtexjs.catalog` objects used in VTEX store themes and customizations.

Sources of truth:
- [README.md](./README.md) — overview and development instructions
- [docs/](./docs/) — full module documentation (Checkout, Catalog)
- [CHANGELOG.md](./CHANGELOG.md) — version history

## Stack

- **Language**: CoffeeScript (`.coffee`) → compiled to JavaScript
- **Build**: Grunt (`grunt dist`)
- **Tests**: Jest with `coffeescript` transform (test files: `*-spec.coffee`)
- **Package manager**: Yarn (lockfile committed)
- **Runtime**: Browser only — depends on jQuery and `window`/`document`

## Verified Commands

```sh
yarn install          # Install dependencies
yarn test             # Run test suite (Jest)
yarn test-watch       # Run tests in watch mode
yarn build            # Build production artifacts (grunt dist)
```

## Architecture

```
src/
  checkout.coffee       # vtexjs.checkout — Checkout API client
  catalog.coffee        # vtexjs.catalog — Catalog API client
  extended-ajax.coffee  # AjaxQueue: queues/aborts concurrent requests
  retry-ajax.coffee     # Retry plugin for jQuery AJAX
  preprocessor.js       # Jest transform for .coffee files

spec/
  checkout-spec.coffee  # Checkout module tests
  lib/                  # Test helpers
  mock/                 # HTTP mocks for tests
```

The library is built as independent browser-loadable scripts. Each module (checkout, catalog, extended-ajax) is concatenated and minified separately by Grunt. Modules are exposed via the `vtexjs` global object.

## Architectural Limits

- This is a **browser-only** library. Do not introduce Node.js-specific APIs.
- All modules depend on jQuery (`$`) and assume `window`/`document` availability.
- Public API is stable — do not rename or remove existing methods without a major version bump and CHANGELOG entry.
- No ES modules or CommonJS — the build output must be browser-includable via `<script>` tags.

## Project-Specific Patterns

- Source files are CoffeeScript. Write tests and source changes in CoffeeScript.
- Classes use CoffeeScript class syntax (not ES6 classes).
- API methods return jQuery promises (`.done()`, `.fail()`), not native Promises.
- Cookie/URL utilities use custom helpers at the top of `checkout.coffee` — reuse them, do not introduce external dependencies.
- The build output goes to `deploy/` — do not commit build artifacts.

## Testing Expectations

- Tests live in `spec/checkout-spec.coffee` (and `spec/lib/`, `spec/mock/`).
- Run with `yarn test` (Jest with `--env=jsdom`).
- Use the existing jQuery-mockjax setup in `spec/mock/` for HTTP mocking.
- Every API method in checkout/catalog must have corresponding test coverage.

## Expected Skills

- `/specification` — create a spec for a feature or bug fix (SDD Lite)
- `/implementing` — implement from an approved spec (SDD Lite)
- `/speckit-specify` — create spec in SDD Full flow
- `/speckit-plan` — create implementation plan in SDD Full flow
- `/speckit-implement` — implement in SDD Full flow

## Expected MCPs

No VTEX-specific MCPs are required for this SDK — it is a standalone frontend library without Admin UI or AI Workspace dependencies.

## Autonomy Limits

Agents may freely:
- Read and run `yarn test`, `yarn build`
- Write or update `.coffee` source files and test files
- Update documentation in `docs/`

Agents must NOT without human approval:
- Change the public API signatures of `vtexjs.checkout` or `vtexjs.catalog`
- Modify `Gruntfile.coffee` build configuration
- Bump the version in `package.json` or write to `CHANGELOG.md`
- Add new npm/yarn dependencies
- Modify `.github/` CI/CD workflows
