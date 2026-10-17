# gotOne

gotOne is a planned Flutter app for students who need to borrow an everyday item on campus for a short time. A student posts a request for a charger, calculator, lab coat, umbrella, notes, or similar essential. Other students can offer one, agree on a handoff, and record when the item is returned.

**Project status:** Flutter frontend demo implemented in [`gotone_app/`](gotone_app/README.md), based on the local HTML design prototype. Backend integration and pilot deployment remain planned.

## How the MVP works

1. A student signs in with a verified college email and completes a profile with their roll number and class/section. They request an item, enter how long they need it, and provide a broad pickup area plus a private exact handoff point.
2. Nearby students browse requests for their campus and tap **I've got this** to offer the item. Several people may offer on the same request.
3. The requester accepts one offer. The other offers are declined. Only the matched pair can see each other's roll number, class/section, contact preference, and exact handoff details.
4. The lender brings the item to the agreed point. Both students confirm the handoff; the borrowing timer starts then. The lender can set a return pickup location with the offer or agree on one later.
5. The app reminds both students when the item is due. The borrower returns it at the agreed location, and both confirm the return. If plans fail, the pair can use their shared class details to coordinate or open a dispute.

“Nearby” in the MVP means the same campus and an optional building/zone filter. It does **not** require continuous location tracking. No payment or delivery is involved.

## Core boundaries

- Request-first: students need not maintain a list of items they own.
- One accepted lender and one loan per request; multiple offers are allowed until acceptance.
- Campus members sign in before viewing requests. Contact details are never shown in the public request list.
- Roll numbers, class/section, and exact meeting points are visible only to the matched pair and authorized moderators, never in the campus feed.
- The app records confirmations; students still arrange and perform the handoff themselves.
- Disputes are recorded and reviewed manually; the MVP does not decide liability or process payments.

## Documentation

- [Idea and user journey](idea.md)
- [Feature scope and acceptance criteria](features.md)
- [Milestones and delivery plan](plan.md)
- [Two-person ownership](team_division.md)
- [Technical choices and data model](tech_stack.md)

## Getting started

Install Flutter 3.44.1 or newer, then run:

```sh
cd gotone_app
flutter pub get
flutter run -d chrome
```

See the [frontend README](gotone_app/README.md) for implemented flows, demo controls, native platform requirements, and backend boundaries. Run `flutter analyze`, `flutter test`, and `flutter build web` to validate the frontend. The app uses local sample data and needs no Firebase credentials.

## Contributing

Use a short-lived branch per task, open a pull request, and have the other contributor review it. Keep the request/offer/loan state rules in sync with [features.md](features.md) and [tech_stack.md](tech_stack.md). A feature is done only when its acceptance criteria and relevant tests pass.

## Planned release

Start with a small, invitation-only pilot on one campus, test with consenting students and sample items, review privacy and dispute handling, and then prepare Android/iOS builds. See [plan.md](plan.md) for the release checklist. This repository currently has no released app or store listing.

