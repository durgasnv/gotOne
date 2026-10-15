# Two-person task division

Use **Contributor A** and **Contributor B** until real names are assigned. These are ownership areas, not isolated silos: each person reviews the other's pull requests and helps test the full borrowing flow.

| Milestone | Contributor A: Flutter experience | Contributor B: Firebase and data | Shared checkpoint |
| --- | --- | --- | --- |
| 0. Pilot rules | Wireframes, form copy, accessibility checklist | Data/privacy outline, campus access rules | Agree on flows, allowed items, moderator, and retention |
| 1. Foundation | Flutter scaffold, navigation, Riverpod setup, sign-in/profile UI | Firebase projects, Auth configuration, user schema, baseline rules, CI | Sign in on a device with a verified test account |
| 2. Requests/offers | Request form/feed/detail, offer UI, filters and states | Request/offer repository, indexes, rules, emulator fixtures | Two accounts can post and offer safely |
| 3. Match/loan | Match screen, private meeting form, loan timeline and confirmations | Transactional accept-offer function, loan state functions, permission tests | Run race and dual-confirmation tests together |
| 4. Alerts/disputes | In-app notices, push handling, report UI | FCM triggers/scheduler, idempotency, dispute storage/moderator access | Test push denied and manual report handling |
| 5. Pilot | Device and accessibility fixes, release UI | Deployment scripts, monitoring, backup/retention checks | Both run release checklist and approve pilot |

## Working agreement

- Create one issue per small slice with owner, acceptance criteria, and any schema/rules changes. Keep pull requests small enough to review.
- Contributor B publishes the proposed document fields and callable function contract before Contributor A depends on them. Contributor A supplies UI validation and error states early so backend edge cases are visible.
- Any change to request, offer, or loan states needs both contributors' review. Neither merges a rule change without emulator permission tests.
- For each milestone, swap devices/accounts and test the other person's work. The owner fixes issues; the reviewer verifies the fix.
- If one contributor is unavailable, pause dependent work and pick an independent issue (copy, accessibility, test fixtures, or docs) rather than bypassing review.

The division is balanced by outcomes: A owns the experience students use; B owns secure, reliable state changes. Both own integration, testing, and pilot support.

