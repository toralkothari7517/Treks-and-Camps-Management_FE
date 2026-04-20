# Backend Integration Handoff (UI Complete)

This document is for the teammate who will connect the database/backend to the updated UI.

## 1) Current Status

- UI is now fully connected page-to-page in `templates/`.
- Admin can add/edit/delete trek data from UI.
- Data currently persists in browser `localStorage` via `templates/shared.js`.
- Design system (colors, fonts, spacing, cards, carousel style) is intentionally finalized and should be kept unchanged.

## 2) Frontend Source of Truth (Current)

- Shared data + CRUD + auth helpers live in:
  - `templates/shared.js`
- Main UI pages consuming that data:
  - `templates/index.html`
  - `templates/treks.html`
  - `templates/trek_detail.html`
  - `templates/book_trek.html`
  - `templates/my_bookings.html`
  - `templates/booking_detail.html`
  - `templates/admin_dashboard.html`
  - `templates/login.html`

Important: Frontend trek object shape is already stable. Backend responses should match this shape as closely as possible to minimize UI rewrites.

## 3) Database Mapping Guidance

Use existing SQL schema/files:

- `treks_camps_schema.sql`
- `sample_data.sql`

Map UI model to DB model:

- Trek core fields -> `Trek`
- Batch/date/slots -> `TrekInstance`
- Camp details/sequence -> `Camp` + `Includes`
- Booking flow -> `Booking`, `Participant`, `ParticipatesIn`, `Payment`

For images:

- Recommended now: keep image URL/path fields in DB and return them in API.
- Current UI supports base64 too, but URL/path is cleaner for production.

## 4) API Endpoints to Implement First

Minimum set to make UI database-driven:

- `GET /api/treks`
- `GET /api/treks/<trek_id>`
- `POST /api/treks`
- `PUT /api/treks/<trek_id>`
- `DELETE /api/treks/<trek_id>`
- `GET /api/bookings`
- `GET /api/bookings/<booking_id>`
- `POST /api/bookings`

Optional but useful:

- `GET /api/trek-instances/<instance_id>`
- `PATCH /api/bookings/<booking_id>/cancel`

## 5) API Response Contract (Suggested)

Keep response close to current frontend object:

```json
{
  "id": "T001",
  "name": "Harishchandragad",
  "region": "Ahmednagar",
  "difficulty": "Moderate",
  "days": 2,
  "price": 2200,
  "altitude": "1,424 m",
  "maxGroup": 20,
  "rating": 4.9,
  "img": "https://...",
  "thumb": "https://...",
  "avail": "6 spots left",
  "availClass": "avail-yellow",
  "desc": "...",
  "tags": ["Sahyadri", "Fort Trek"],
  "itinerary": [{ "title": "Day 1", "desc": "..." }],
  "camps": [{ "name": "Base Camp", "alt": "900 m", "cap": 20, "fac": "..." }],
  "guide": { "name": "Guide Name", "exp": "5 yrs", "spec": "...", "cert": "..." },
  "transport": "Pune",
  "instances": [{ "id": "INS001", "start": "Jun 14", "end": "Jun 15", "slots": 6 }]
}
```

## 6) Recommended Integration Order (Low-Risk)

1. Implement read-only API (`GET /api/treks`, `GET /api/treks/<id>`).
2. Replace frontend initial load in `shared.js` from localStorage to API fetch (keep local fallback temporarily).
3. Connect admin create/update/delete to API endpoints.
4. Connect booking create + booking detail/list to API.
5. Remove localStorage as primary source after API stability.

## 7) Frontend Edits Needed by Backend Teammate

Primary place to refactor:

- `templates/shared.js`

What to change:

- Replace `loadTreks()` localStorage logic with API service calls.
- Keep public function signatures same where possible (`getTrekById`, `addTrek`, `updateTrek`, `deleteTrek`) so existing pages keep working.
- Keep `renderNav()`/`renderFooter()` and UI class names untouched.

## 8) Data Integrity Notes

- Use transactions for create/update/delete across related tables.
- Validate numeric/date fields on API layer.
- Return structured errors:
  - `{ "error": "Validation failed", "details": {...} }`
- Add/update timestamp fields if possible for future conflict handling.

## 9) What Not To Change

- Do not change CSS tokens/theme in `templates/shared.css`.
- Do not restructure HTML markup unless required for API hookup.
- Do not rename existing frontend keys unless absolutely required.

## 10) Quick Test Checklist After Integration

- Home and Treks page show DB data.
- Trek detail page uses DB trek + instance + camp data.
- Admin add/edit/delete updates DB and reflects immediately on treks pages.
- Booking created from UI appears in DB and booking detail view.
- Reload browser: data still present (proves no local-only persistence).

