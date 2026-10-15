# Two-person task division

Use **Contributor A** and **Contributor B** until real names are assigned. These are ownership areas, not isolated silos: each person reviews the other's pull requests and helps test the full borrowing flow.

| Milestone | Contributor A: Flutter experience | Contributor B: Firebase and data | Shared checkpoint |
| --- | --- | --- | --- |
| 0. Pilot rules | Wireframes, form copy, accessibility checklist | Data/privacy outline, campus access rules | Agree on flows, allowed items, moderator, and retention |
| 1. Foundation | Flutter scaffold, navigation, Riverpod setup, college email and roll/class profile UI | Firebase projects, Auth configuration, profile schema, baseline rules, CI | Verified test account completes profile before posting |
| 2. Requests/offers | Request form/feed/detail, duration and handoff inputs, “I've got this” offer UI | Request/offer repository, indexes, private handoff storage, rules, emulator fixtures | Two accounts can post and offer without exposing private details in the feed |
| 3. Match/loan | Match screen, matched-only identity view, return-point agreement, loan timeline and confirmations | Transactional accept-offer function, due-time calculation, loan state functions, permission tests | Run race, privacy, duration, and dual-confirmation tests together |
| 4. Alerts/disputes | In-app notices, due-time push handling, report UI | FCM triggers/scheduler, idempotency, missing-location prompt, dispute storage/moderator access | Test push denied, due reminder, and manual report handling |
| 5. Pilot | Device and accessibility fixes, release UI | Deployment scripts, monitoring, backup/retention checks | Both run release checklist and approve pilot |

## Working agreement

- Create one issue per small slice with owner, acceptance criteria, and any schema/rules changes. Keep pull requests small enough to review.
- Contributor B publishes the proposed document fields and callable function contract before Contributor A depends on them. Contributor A supplies UI validation and error states early so backend edge cases are visible.
- Any change to request, offer, or loan states needs both contributors' review. Neither merges a rule change without emulator permission tests.
- For each milestone, swap devices/accounts and test the other person's work. The owner fixes issues; the reviewer verifies the fix.
- If one contributor is unavailable, pause dependent work and pick an independent issue (copy, accessibility, test fixtures, or docs) rather than bypassing review.

The division is balanced by outcomes: A owns the experience students use; B owns secure, reliable state changes. Both own integration, testing, and pilot support.

