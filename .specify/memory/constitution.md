# vtex.js Constitution

## Core Principles

### I. Browser-Only Runtime
All code must run in a browser environment. Do not use Node.js APIs (`fs`, `path`, `process`, etc.). The `window` and `document` globals are always available. Modules are loaded as browser scripts, not via CommonJS or ES modules.

### II. CoffeeScript Source
Source files and test files are written in CoffeeScript (`.coffee`). Do not introduce plain `.js` source files unless they are tooling artifacts (e.g., Jest preprocessor). Maintain CoffeeScript idioms: arrow functions with `=>`, class syntax, existential operator `?`.

### III. jQuery Promises — No Native Promises
All async API methods return jQuery deferred promises (`.done()`, `.fail()`, `.then()`). Do not introduce native `Promise`, `async/await`, or other async primitives. This maintains compatibility with the jQuery-based host environments this library targets.

### IV. Stable Public API — No Breaking Changes Without Approval
The public methods of `vtexjs.checkout` and `vtexjs.catalog` are used by external consumers. Renaming, removing, or changing the signature of any public method requires human approval and a major version bump. Internal utility functions (e.g., `trim`, `mapize`, `readCookie`) may be refactored freely.

### V. No New Runtime Dependencies
This library has zero runtime dependencies (only `devDependencies`). jQuery is provided by the host page, not bundled. Do not add entries to `"dependencies"` in `package.json`. New `devDependencies` require human approval.

## Quality Gates

- All public API methods must have Jest test coverage in `spec/checkout-spec.coffee` or an equivalent spec file.
- Tests must pass with `yarn test` before implementation is complete.
- Build must succeed with `yarn build` before opening a PR.
- The `deploy/` directory (build output) must not be committed.

## Governance

This constitution supersedes informal practices. Amendments require a PR with justification. Agents must not promote temporary decisions to permanent rules here.

**Version**: 1.0 | **Ratified**: 2026-05-15 | **Last Amended**: 2026-05-15
