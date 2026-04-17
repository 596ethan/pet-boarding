# AGENTS.md

## Mission

Build and iterate the **Pet Boarding Management System MVP** defined in
`pet_boarding_prd.md`.

This is a **small, demonstrable HarmonyOS-native project**.
The priority is:

1. keep scope tight
2. finish vertical MVP flows
3. make the HarmonyOS UI clean and easy to demo
4. implement stable CRUD and a complete boarding workflow

Do **not** turn this into a large product platform.

---

## Source of Truth

Use `pet_boarding_prd.md` as the product source of truth unless the user
explicitly overrides it.

If code, mock data, or generated UI conflicts with the PRD, prefer the PRD.

If the user changes scope in chat, follow the user's newer instruction and
reflect that change in implementation choices.

---

## MVP Scope (Strict)

The MVP must support this boarding workflow end to end:

1. login
2. owner profile CRUD
3. pet profile CRUD
4. boarding order CRUD
5. check-in with room assignment
6. care record CRUD
7. checkout
8. completed order history

The MVP should be easy to demonstrate in one continuous flow.

---

## Explicit Non-Goals

Unless the user explicitly expands scope, do **not** add:

- payment
- invoice systems
- chat or messaging
- customer-side mini app / owner app
- SaaS or multi-store support
- marketing systems
- points / membership growth systems
- complex reports / BI dashboards
- complex RBAC / multi-role permission trees
- advanced sync centers
- object storage integrations
- notification systems
- recommendation systems

Prefer omission over speculative expansion.

---

## Current Workspace Facts

Current workspace contains:

- `pet_boarding_prd.md`: PRD and product scope reference
- `pet_boarding/`: HarmonyOS native app project
- `pet_boarding/entry/src/main/ets/pages/`: page code
- `pet_boarding/entry/src/main/resources/`: resources and page profile

Not present yet:

- Java backend
- management admin UI

Do **not** assume backend or admin code exists.
Only scaffold or implement backend/admin when the user explicitly asks for it.

---

## Delivery Strategy

Always complete **vertical slices** before broad feature surfaces.

Preferred implementation order:

1. login page
2. owner list + add/edit
3. pet list + add/edit
4. order list + add/edit
5. check-in page with room assignment
6. care record page
7. checkout page
8. completed order history page
9. demo polish and validation

Do not build 10 half-finished screens.
Prefer 3 finished screens over 10 incomplete ones.

---

## HarmonyOS App Expectations

The HarmonyOS app is the primary implementation target in this workspace.

### UI Principles

The UI should feel:

- clean
- simple
- native
- easy to demo
- easy to understand quickly

Prefer:

- card-based summaries on home pages
- searchable lists
- lightweight forms
- clear primary actions
- visible status labels
- delete confirmations
- consistent spacing and typography

Avoid:

- cluttered layouts
- oversized settings pages
- deeply nested navigation
- decorative complexity
- speculative enterprise-style UI

### HarmonyOS Native Component Direction

Prefer HarmonyOS native components and ArkTS patterns already produced by
DevEco Studio.

Use simple, demonstrable UI patterns:

- list pages
- detail or form pages
- dialogs
- search inputs
- tabs only when clearly useful
- status tags / badges
- clear button hierarchy

---

## Code Organization Rules

As the app grows, prefer this structure under `ets/`:

- `pages/` for routed pages only
- `components/` for reusable UI pieces
- `model/` or `types/` for explicit interfaces, enums, and type definitions
- `data/` for mock data before backend integration
- `repository/` for local data access and future API access
- `utils/` only for shared helpers that are actually reused

Keep page files focused on page behavior and layout.
Do not let `pages/` become a dumping ground for mock data, types, and reusable widgets.

---

## Data Modeling Rules

Use explicit ArkTS interfaces and enums for core entities.

At minimum, model these concepts clearly:

- `User`
- `Owner`
- `Pet`
- `Room`
- `BoardingOrder`
- `CareRecord`

Typical order status progression should stay simple, for example:

- `PENDING`
- `CHECKED_IN`
- `COMPLETED`
- `CANCELLED`

Only add more states if the user explicitly asks or the existing codebase requires it.

Avoid untyped nested object literals in fixtures, mocks, or tests.
Declare local interfaces first, then construct the data.

---

## CRUD Expectations

Each CRUD screen should stay simple and demo-friendly.

A good MVP CRUD page usually includes:

- list display
- search or filter input
- add action
- edit action
- delete confirmation
- clear status display

Do not overbuild bulk actions, advanced filtering, import/export, or batch workflows.

---

## Workflow Expectations

The most important workflow is:

owner -> pet -> boarding order -> check-in -> care records -> checkout -> history

Implementation should preserve this flow clearly in both data and navigation.

When choosing between isolated CRUD completeness and workflow continuity,
prefer **workflow continuity**.

---

## Mock Data and Local Data Rules

Before backend integration, use local mock data or local repository abstractions.

Keep mock data realistic but minimal.

Do not hardcode random large datasets just to make the UI feel busy.

Structure code so future backend integration is easy:

- page calls repository
- repository returns typed models
- mock implementation can later be replaced by API implementation

---

## Backend and Admin Boundaries

The PRD requires a Java backend and a management admin UI,
but they are **not part of the current workspace yet**.

Therefore:

- do not reference nonexistent backend files as if they already exist
- do not invent admin modules in reports unless scaffolding was explicitly requested
- do not block HarmonyOS progress waiting for backend work
- do leave clean seams for future integration

If backend is requested later, scaffold it separately and keep interfaces narrow.
If admin UI is requested later, implement only the minimum admin functionality needed by the PRD.

---

## Files and Paths to Avoid Touching

Do not hand-edit generated or machine-local state unless specifically required:

- `.hvigor/`
- `oh_modules/`
- `.idea/`
- `local.properties`
- `build/`
- `.test/`

Only modify generated files when there is a specific and justified need.

---

## Build and Verification

Preferred local HarmonyOS build command from `pet_boarding/`:

```powershell
$env:DEVECO_SDK_HOME='D:\Program Files\Huawei\DevEco Studio\sdk'
& 'D:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'D:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module `
  -p module=entry@default `
  -p product=default `
  assembleHap `
  --analyze=normal
```
