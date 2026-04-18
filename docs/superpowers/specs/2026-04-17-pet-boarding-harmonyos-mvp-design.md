# Pet Boarding HarmonyOS MVP Design

Date: 2026-04-17

## Goal

Build the HarmonyOS-native MVP for the Pet Boarding Management System as a
small, demonstrable phone app. The app must support one continuous boarding
workflow:

login -> owner profile -> pet profile -> boarding order -> check-in with room
assignment -> care records -> checkout -> completed order history.

This design covers only the current workspace: `pet_boarding/`. Java backend
and management admin UI work is deferred until explicitly requested.

## Source Of Truth

Use `pet_boarding_prd.md` and `AGENTS.md` as the product and workspace source
of truth. If implementation detail conflicts with those files, prefer the PRD
unless the user gives a newer instruction in chat.

## Scope

### In Scope

- HarmonyOS native phone app.
- Local typed models for users, owners, pets, rooms, boarding orders, and care
  records.
- Local mock data and repository layer.
- Login screen with a simple demo account.
- Home screen with demo metrics and quick workflow entry points.
- Owner CRUD.
- Pet CRUD linked to owners.
- Boarding order CRUD linked to owners and pets.
- Room assignment during check-in.
- Care record CRUD for checked-in orders.
- Checkout flow that completes the order and releases the room.
- Completed order history.
- Clean native UI suitable for a short live demo.

### Out Of Scope

- Java backend implementation.
- Management admin UI implementation.
- Payment, invoices, owner mini app, chat, SaaS, marketing, BI reports,
  notification systems, object storage, complex RBAC, and advanced sync.
- Large generated datasets.

## Recommended Approach

Use a local repository-backed HarmonyOS MVP before backend integration.

Pages should call repository methods instead of reading mock arrays directly.
The repository should own state transitions and validation rules. This keeps the
phone demo fast to build now while leaving a narrow place to replace local mock
logic with API calls later.

## Architecture

The app should use the following structure under
`pet_boarding/entry/src/main/ets/`:

- `pages/`: routed pages only.
- `components/`: reusable visual pieces such as status tags, summary cards,
  action rows, and empty-state views.
- `model/`: explicit ArkTS interfaces and enums.
- `data/`: minimal seed data for the demo.
- `repository/`: local data access and workflow rules.
- `utils/`: shared helpers only when reused by multiple files.

Page files should stay focused on layout, input state, and navigation. Mock data
and workflow rules must not be buried inside pages.

## Data Model

Use explicit interfaces for all core entities:

- `User`: demo login identity.
- `Owner`: name, phone, remark.
- `Pet`: owner id, name, type, breed, age, weight, temperament.
- `Room`: room number and occupancy status.
- `BoardingOrder`: owner id, pet id, room id, status, check-in time, checkout
  time, remark.
- `CareRecord`: order id, type, content, record time.

Use a simple order status enum:

- `PENDING`
- `CHECKED_IN`
- `COMPLETED`
- `CANCELLED`

Fixtures and tests should avoid untyped nested object literals. Define
interfaces first, then construct typed data.

## Workflow Rules

- Login succeeds only for a known demo account.
- Owner deletion is blocked when the owner has active or pending orders.
- Pet deletion is blocked when the pet has active or pending orders.
- Room deletion is blocked when the room is occupied or referenced by an active
  order.
- Creating an order produces a `PENDING` order.
- Check-in only accepts `PENDING` orders.
- Check-in requires an available room.
- Successful check-in sets the order to `CHECKED_IN` and marks the room
  occupied.
- Care records can be added, edited, viewed, and deleted for checked-in orders.
- Completed orders cannot receive new ordinary care records.
- Checkout only accepts `CHECKED_IN` orders.
- Successful checkout sets the order to `COMPLETED`, records checkout time, and
  releases the room.
- Completed order history shows completed orders with owner, pet, room, and
  care record context.

## Page Design

### Login Page

The first screen asks for username and password and signs in to the demo app.
It should be simple and direct: title, two inputs, one primary button, and a
short demo-account hint.

### Home Page

The home screen summarizes the demo state:

- boarding now
- today check-ins
- today checkouts
- available rooms

It also provides clear entry points for owner, pet, order, check-in, care,
checkout, and history flows.

### Owner Pages

Owner list includes search, add, edit, and delete confirmation. Owner form uses
only MVP fields: name, phone, and remark.

### Pet Pages

Pet list includes search and owner context. Pet form requires owner selection
and uses the minimal PRD fields.

### Order Pages

Order list shows owner, pet, date/status, and available actions. Order form
selects owner and pet, then creates or edits pending order information.

### Check-In Page

The page lists pending orders and available rooms. Confirming check-in updates
both order and room state.

### Care Record Page

The page focuses on checked-in orders. It supports adding and viewing care
records, plus editing and deleting existing records.

### Checkout Page

The page lists checked-in orders and provides a clear checkout action. Checkout
must update order status and room availability together.

### History Page

The page lists completed orders with enough detail to demonstrate the full
boarding trail.

## Navigation

Use simple HarmonyOS routing through `main_pages.json`. `Index.ets` can become
the app entry shell or be replaced by a login page route, depending on what
matches the existing DevEco template best during implementation.

Avoid deep navigation. Prefer list -> form/detail and workflow pages reachable
from the home screen.

## UI Direction

The UI should be clean, native, and easy to demo:

- card-based summaries on the home page
- searchable lists
- lightweight forms
- visible status tags
- clear primary actions
- delete confirmations
- consistent spacing and typography
- no decorative complexity

The app should favor workflow clarity over feature density.

## Verification

Primary build check from `pet_boarding/`:

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

Manual demo verification must cover:

1. Login.
2. Create owner.
3. Create pet linked to owner.
4. Create pending boarding order.
5. Check in order with available room.
6. Add care record.
7. Checkout order.
8. Confirm completed order appears in history and room becomes available.

If repository tests are added later, prioritize state-transition rules:
check-in, checkout, care-record restrictions, and delete blocking.

## Implementation Order

1. Create model, mock data, repository, and shared UI primitives.
2. Implement login and home shell.
3. Implement owner CRUD.
4. Implement pet CRUD.
5. Implement order CRUD.
6. Implement check-in.
7. Implement care records.
8. Implement checkout and completed history.
9. Polish UI and run build plus manual demo verification.

## Acceptance Criteria

- The HarmonyOS app can demonstrate the full boarding workflow in one run.
- CRUD flows exist for owners, pets, orders, and care records.
- Room assignment and release rules work correctly.
- Completed order history is visible.
- Page code is not used as a dumping ground for models, mock data, or workflow
  rules.
- The build command succeeds, or any blocker is reported with exact error text.

