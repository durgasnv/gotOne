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
| `users/{uid}` | displayName, campusId, verifiedAt, rollNumber, classSection, contactPreference, createdAt | Owner reads/edits allowed profile fields; roll/class remain private until match |
| `requests/{requestId}` | requesterId, campusId, itemName, category, description, zone, neededBy, borrowDurationMinutes, status, createdAt, matchedOfferId | Signed-in verified campus members read public fields; owner creates/edits allowed fields |
| `requests/{requestId}/private/handoff` | exactLocation, optional contact instructions | Requester before match; matched pair afterward |
| `requests/{requestId}/offers/{offerId}` | lenderId, availability, note, proposedReturnPoint, status, createdAt | Lender and requester read; lender creates/withdraws pending offer |
| `loans/{loanId}` | requestId, offerId, requesterId, lenderId, campusId, borrowDurationMinutes, startedAt, dueAt, status, handoff confirmations, return confirmations, createdAt | Matched pair read; critical updates only through functions |
| `loans/{loanId}/events/{eventId}` | type, actorId, timestamp, metadata | Matched pair read; server appends an audit trail |
| `loans/{loanId}/private/participants` | matched profile snapshot: roll numbers, class/sections, approved contact details | Matched pair and authorized moderator only |
| `loans/{loanId}/private/return` | proposedPoint, agreedPoint, proposedBy, acknowledgedBy, timestamps | Matched pair only; agreement recorded through functions |
| `disputes/{disputeId}` | loanId, reporterId, category, explanation, status, moderatorNote, timestamps | Pair and authorized moderator only |
| `users/{uid}/notifications/{id}` | type, relatedId, createdAt, readAt | Owner only |

Keep public request documents free of roll numbers, class/sections, phone numbers, exact meeting locations, and private contact data. Copy the two participants' roll/class details into a matched-only loan snapshot at acceptance so the contact record remains clear during that loan. The roll number is self-reported unless checked against a campus directory. Store server timestamps in UTC and format them in the device's local timezone. Decide retention and deletion rules before pilot.

## Operations and security

- Firestore rules require authentication, verified campus membership, matching campus ID, profile completeness before posting/offering, and field-level ownership. A profile cannot self-assign moderator privileges or another campus. Ordinary students cannot list other users' private profile records.
- A callable Cloud Function accepts one pending offer in a Firestore transaction: verify requester and statuses, write the accepted offer and loan, decline competing offers, and mark the request matched. Retries must return the existing loan or fail safely, never create a second one.
- Handoff and return confirmation functions verify the caller is one of the two participants, record their timestamp once, and advance the loan only when both have confirmed. On the second handoff confirmation, set `startedAt` and calculate `dueAt = startedAt + borrowDurationMinutes` on the server. Cancel/dispute paths preserve the event trail.
- A return-point function lets the lender propose a point during the offer or later; the borrower acknowledges it. Changes after agreement require both sides to acknowledge the new point. Keep this separate from the public request document.
- Notification triggers use stable event IDs so retries do not duplicate messages. Scheduled due-soon, due-now, overdue, and missing-return-point reminders check current loan status before sending.
- Indexes support open requests by campus, zone/category, and creation time. Add only indexes required by actual queries.
- Admin access uses custom claims assigned outside the client app. Keep moderator actions auditable.

## Practical caveats

Verified college email alone may not prove current enrollment or validate a self-entered roll number; agree on a campus-approved identity method for the pilot. Class/section is a fallback for coordination, not a live classroom or schedule tracker. Firestore offline persistence can display stale requests, so acceptance and other critical actions must be confirmed by the server and show a clear failure/retry state. FCM delivery is best effort; the in-app record and loan screen remain the source of truth, and the app should not promise an exact-time audible alarm.

