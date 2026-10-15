# Technical stack and data design

## Recommended stack

| Part | Choice | Why |
| --- | --- | --- |
| Mobile app | Flutter and Dart | One codebase for Android and iOS; quick iteration for a two-person team |
| State and dependencies | Riverpod | Clear async state and testable repositories |
| Identity | Firebase Authentication | Sign-in and verified-account handling; configure an approved campus domain or provider |
| Data | Cloud Firestore | Live request/offer/loan updates and queryable campus feeds |
| Trusted operations | Cloud Functions for Firebase | Atomic matching, controlled state transitions, notifications, reminders |
| Push | Firebase Cloud Messaging | Device alerts; pair with an in-app notification record |
| Local testing | Firebase Emulator Suite, Flutter test | Validate rules and multi-account flows without touching production |
| CI | GitHub Actions | Run formatting, analysis, Flutter tests, and emulator tests |

Use current stable releases when implementation begins and pin package versions in the lockfile. Firebase service credentials belong in project secrets, never in Git.

## Suggested app structure

`lib/features/auth`, `requests`, `offers`, `loans`, `notifications`, and `disputes` each contain UI, state providers, and repository interfaces. Put shared models and Firebase adapters under `lib/core`. Cloud Functions and Firestore rules live in version-controlled `functions/` and `firestore.rules` when code is added. This is a proposal, not a claim that these folders already exist.

## Initial Firestore model

| Collection | Main fields | Access |
| --- | --- | --- |
| `users/{uid}` | displayName, campusId, verifiedAt, contactPreference, createdAt | Owner reads/edits allowed profile fields; moderator gets limited access |
| `requests/{requestId}` | requesterId, campusId, itemName, category, description, zone, neededBy, returnBy, status, createdAt, matchedOfferId | Signed-in verified campus members read public fields; owner creates/edits allowed fields |
| `requests/{requestId}/offers/{offerId}` | lenderId, availability, note, status, createdAt | Lender and requester read; lender creates/withdraws pending offer |
| `loans/{loanId}` | requestId, offerId, requesterId, lenderId, campusId, dueAt, status, handoff confirmations, return confirmations, createdAt | Matched pair read; critical updates only through functions |
| `loans/{loanId}/events/{eventId}` | type, actorId, timestamp, metadata | Matched pair read; server appends an audit trail |
| `loans/{loanId}/private/meeting` | exact location, approved contact details | Matched pair only, after match |
| `disputes/{disputeId}` | loanId, reporterId, category, explanation, status, moderatorNote, timestamps | Pair and authorized moderator only |
| `users/{uid}/notifications/{id}` | type, relatedId, createdAt, readAt | Owner only |

Keep public request documents free of phone numbers, exact classroom locations, and private contact data. Store server timestamps in UTC and format them in the device's local timezone. Decide retention and deletion rules before pilot.

## Operations and security

- Firestore rules require authentication, verified campus membership, matching campus ID, and field-level ownership. A profile cannot self-assign moderator privileges or another campus.
- A callable Cloud Function accepts one pending offer in a Firestore transaction: verify requester and statuses, write the accepted offer and loan, decline competing offers, and mark the request matched. Retries must return the existing loan or fail safely, never create a second one.
- Handoff and return confirmation functions verify the caller is one of the two participants, record their timestamp once, and advance the loan only when both have confirmed. Cancel/dispute paths must preserve the event trail.
- Notification triggers use stable event IDs so retries do not duplicate messages. Scheduled reminders check current loan status before sending.
- Indexes support open requests by campus, zone/category, and creation time. Add only indexes required by actual queries.
- Admin access uses custom claims assigned outside the client app. Keep moderator actions auditable.

## Practical caveats

Verified email alone may not prove current enrollment; agree on a campus-approved identity method for the pilot. Firestore offline persistence can display stale requests, so acceptance and other critical actions must be confirmed by the server and show a clear failure/retry state. FCM delivery is best effort; the in-app record and loan screen remain the source of truth.

