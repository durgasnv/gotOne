# gotOne Flutter frontend

A Flutter/Dart implementation of `../gotOne prototype (Swipe).html`, with Riverpod state and go_router navigation. The original HTML remains the design reference.

## Run

Use Flutter 3.44.1 or newer (validated with Flutter 3.44.1 / Dart 3.12.1).

```sh
cd gotone_app
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device and use `flutter run`. iOS requires macOS and Xcode. Android and iOS runners are included; native builds have not been device-tested.

```sh
flutter analyze
flutter test
flutter build web
```

## Implemented

- Animated welcome, demo campus email validation, and editable profile onboarding.
- Campus feed and draggable swipe deck, category/search/zone filters, and empty/loading states.
- Request creation with borrowing duration, needed-by selection, and a private handoff point stored separately from public request data.
- Request details, availability/note offers, withdrawal, and accepting a seeded offer.
- Borrowing/lending activity, notifications with unread indicators, and profile.
- Loan timeline, separate handoff confirmations, countdown starting at the second confirmation, return-point agreement, separate return confirmations, completed history, and local issue reporting.
- Responsive centered mobile layout for web and bundled Inter Tight typography.

## Demo behavior and backend boundary

All state is in memory and resets when the app restarts. Sign-in validates only the demo domain `bvrithyderabad.edu.in`; no email is sent and no account is authenticated. Use any local part, for example `student@bvrithyderabad.edu.in`.

To exercise borrowing: open Activity → Requests → Scientific calculator → accept an offer. Confirm handoff, then use the clearly labeled demo partner confirmation. Propose and agree a return point, confirm return, and simulate the partner's confirmation to complete the loan.

To exercise lending: open a campus request, send an offer, then use its demo acceptance button. The same loan flow runs with you as the lender. The demo supports one unfinished loan at a time.

New requests appear in Activity. No automatic offers are fabricated for them; the seeded calculator request has two sample offers. Notifications are local records, and issue reports do not contact a moderator.

Public cards and offer lists hide class/section details, following the repository specification where it differs from the HTML. Local providers are not an authorization boundary. Firebase authentication, Firestore repositories/rules, atomic matching, trusted loan transitions, push notifications, moderation, and persistence still need backend implementation before a real campus pilot.

The Inter Tight font and its OFL license are bundled under `assets/fonts/`.
