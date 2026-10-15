# Features and acceptance criteria

## MVP (first pilot)

### 1. Campus sign-in and profile

Students sign in through Firebase Auth using a campus-approved method (for example, verified email from an allowed campus domain). The pilot team configures the domain; never assume every `.edu` address is valid. A profile stores display name, campus ID, and optional contact preference. The app requires sign-in to browse or act.

**Done when:** an unverified account cannot read campus requests; a verified student can create a profile; users cannot edit another student's profile.

### 2. Post and manage a request

A requester enters item name/category, short description, broad pickup zone, needed-by time, return-by time, and optional condition notes. Needed-by must be in the future and return-by after needed-by. The requester can cancel an open request or edit noncritical fields while it has no accepted offer.

**Done when:** valid requests appear in that campus's open feed; invalid dates or empty item names are rejected; a cancelled request cannot receive an offer.

### 3. Discover and offer

Signed-in students see open requests from their own campus, filter by category/zone, and submit a short offer with availability and optional item note. They cannot offer on their own request. More than one lender may offer. A lender can withdraw a pending offer.

**Done when:** the requester sees all pending offers for their request; other students cannot read the offer's private note; an offer cannot be made after the request is matched or cancelled.

### 4. Accept one offer and arrange a meeting

The requester accepts one pending offer. A server-side transaction accepts that offer, declines the others, marks the request matched, and creates exactly one loan. The matched pair can exchange a precise meeting point and approved contact preference. A broad zone may remain visible in the feed, but phone number, classroom details, and precise meeting point are restricted to the pair.

**Done when:** simultaneous taps cannot create two accepted offers or loans; neither side sees private meeting/contact data before acceptance; unrelated users cannot read it after acceptance.

### 5. Handoff, due date, and return

Each participant confirms the physical handoff. The loan becomes active only after both confirmations. Either may cancel before handoff, with the cancellation recorded. The accepted return-by time becomes the due date. Each participant confirms return; the loan becomes complete only after both confirmations. A mismatched confirmation can lead to a dispute. Do not automatically mark an item returned when the due date passes.

**Done when:** the timeline shows who confirmed and when; one-sided handoff or return remains pending; completed loans cannot be reopened by a normal client.

### 6. Notifications

Use FCM for new offers, offer acceptance/decline, handoff prompts, due-soon/overdue reminders, and return confirmation. Store an in-app notification record so the flow still works if push permission is denied. Give users a way to turn off nonessential push notifications.

**Done when:** the relevant participant gets an in-app event; push is attempted for opted-in devices; duplicate function retries do not create duplicate visible events.

### 7. Disputes and safety

Either participant can report a loan with a category and explanation. The record keeps the loan and relevant event timestamps for a pilot moderator. A moderator can mark the case resolved with a note, but cannot silently change the students' confirmation history. Provide a visible report action and campus-specific safety guidance.

**Done when:** only a participant can open a loan dispute; unrelated students cannot read it; moderators can review it through a protected process; both participants see that the loan is disputed.

## State rules

- Request: `open -> matched -> completed`; `open -> cancelled`; `matched -> cancelled` only before handoff; `matched -> disputed` when a dispute opens.
- Offer: `pending -> accepted | declined | withdrawn`. Exactly one offer can be accepted per request.
- Loan: `awaiting_handoff -> active -> return_pending -> completed`. Either pre-completion state may become `disputed`; pre-handoff cancellation is possible with a recorded reason.
- A moderator resolution records an outcome; it does not erase the original event timeline.

## Later, after the MVP

Optional lender inventory, item photos, richer search, campus map, trusted groups, reputation, multi-campus administration, and accessibility/localization improvements beyond the baseline. These are not prerequisites for the first pilot. Payments, deposits, automated penalties, and continuous location tracking are out of scope.

