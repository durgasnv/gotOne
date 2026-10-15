# Delivery plan

This is a two-contributor plan for a small campus pilot, not a fixed calendar promise. Keep each milestone reviewable and merge it before starting work that depends on it. See [team_division.md](team_division.md) for ownership.

| Milestone | Focus | Exit condition |
| --- | --- | --- |
| 0. Agree on pilot rules | Campus/domain, allowed items, moderator, retention, safety copy, wireframes | Both contributors sign off on flows and privacy rules |
| 1. Foundation | Flutter scaffold, navigation, Firebase dev project, verified college email, roll/class profile, CI | Both can run the app; incomplete profiles cannot post or offer; analysis/tests pass |
| 2. Requests and offers | Create/feed/detail, borrowing duration, private handoff point, “I've got this” offers, Firestore rules and indexes | Two test accounts can post and offer; campus feed hides roll/class and exact point |
| 3. Match and loan | Atomic acceptance, matched-only identity, dual handoff/return confirmation, return-point agreement | Multiple-offer race test passes; due time starts after confirmed handoff; loan reaches completed state |
| 4. Notifications and disputes | In-app records, FCM due reminders, missing return-point prompt, report and moderator process | Push-denied flow still works; dispute is visible and reviewable |
| 5. Pilot release | Accessibility pass, device testing, privacy review, seed cleanup, release builds | Checklist below passes and a small test group can use the app |

## Suggested build sequence

1. Draw five screens: sign-in/profile (including roll number and class/section), request feed, create request, request/offers detail, and loan timeline with return-point agreement. Agree on empty, loading, error, and expired states.
2. Define Firestore documents and security rules before wiring screens to live data. Use the Firebase Emulator Suite with seeded test accounts.
3. Implement vertical slices: create a request with a duration, tap “I've got this,” accept exactly one offer, confirm handoff, agree on a return point, and confirm return. Add reminders and reports after the main flow works.
4. Review each pull request together; keep UI and backend contract changes in the same milestone.

## Testing checklist

- Unit tests: roll/class profile completeness, duration and date rules, due-time calculation from handoff, state transitions, and notification idempotency helpers.
- Widget tests: key forms, disabled actions, private-detail visibility, and error states.
- Emulator integration tests: campus isolation, matched-only roll/class and meeting details, simultaneous offer acceptance, declined/withdrawn offers, dual confirmations, return-point agreement/changes, and dispute permissions.
- Manual device checks: Android and iOS if both are supported, poor connectivity, push denied, app resumed from notification, large text, screen reader labels, and timezone/date display.
- Negative checks: an unauthenticated user and an unrelated campus user cannot read requests or private loan details.

## Pilot and deployment

Use separate Firebase development and production projects. Add platform app IDs and generate FlutterFire configuration for each environment. Deploy Firestore rules/indexes and Cloud Functions from reviewed code, then register FCM credentials for supported platforms. Limit the pilot to one configured campus and invited testers. Build signed Android/iOS packages only after the core flow and permission tests pass; follow the target store's current submission requirements at release time.

Before inviting students, publish a short privacy notice and campus-specific allowed-items/safety guidance, name a moderator, set a data-retention period, test account deletion, and verify backups/export needs. Seed test data must be removed from production. Monitor function errors, failed notifications, stuck loans, and disputes during the pilot. Roll back by disabling new requests and deploying the last known-good rules/functions if needed; do not delete active loan records.

## Definition of done

A milestone is complete when the agreed acceptance criteria in [features.md](features.md) pass, security rules and indexes are included, relevant tests run in CI, the other contributor reviews the pull request, and any user-facing behavior is documented.

