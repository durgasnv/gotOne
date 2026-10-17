// Core domain models for gotOne.
// These mirror the Firestore schema in tech_stack.md.
// All IDs are Firestore document IDs (String).

enum RequestStatus { open, matched, completed, cancelled, disputed }

enum OfferStatus { pending, accepted, declined, withdrawn }

enum LoanStatus {
  awaitingHandoff,
  active,
  returnPending,
  completed,
  disputed,
  cancelled,
}

enum ItemCategory { chargers, study, lab, rain, tech }

extension ItemCategoryX on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.chargers:
        return 'Chargers';
      case ItemCategory.study:
        return 'Study';
      case ItemCategory.lab:
        return 'Lab';
      case ItemCategory.rain:
        return 'Rain';
      case ItemCategory.tech:
        return 'Tech';
    }
  }

  String get emoji {
    switch (this) {
      case ItemCategory.chargers:
        return '🔌';
      case ItemCategory.study:
        return '📚';
      case ItemCategory.lab:
        return '🥼';
      case ItemCategory.rain:
        return '☂️';
      case ItemCategory.tech:
        return '🧮';
    }
  }
}

/// Public-facing request document.
class ItemRequest {
  const ItemRequest({
    required this.id,
    required this.requesterId,
    required this.campusId,
    required this.itemName,
    required this.category,
    required this.description,
    required this.zone,
    required this.neededBy,
    required this.borrowDurationMinutes,
    required this.status,
    required this.createdAt,
    this.matchedOfferId,
    // Populated from the requester's profile for display only:
    this.requesterDisplayName = '',
    this.requesterSection = '',
  });

  final String id;
  final String requesterId;
  final String campusId;
  final String itemName;
  final ItemCategory category;
  final String description;
  final String zone;
  final DateTime neededBy;
  final int borrowDurationMinutes;
  final RequestStatus status;
  final DateTime createdAt;
  final String? matchedOfferId;
  final String requesterDisplayName;
  final String requesterSection;

  bool get isUrgent =>
      neededBy.difference(DateTime.now()).inMinutes < 60 &&
      status == RequestStatus.open;

  ItemRequest copyWith({
    String? id,
    String? requesterId,
    String? campusId,
    String? itemName,
    ItemCategory? category,
    String? description,
    String? zone,
    DateTime? neededBy,
    int? borrowDurationMinutes,
    RequestStatus? status,
    DateTime? createdAt,
    String? matchedOfferId,
    String? requesterDisplayName,
    String? requesterSection,
  }) {
    return ItemRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      campusId: campusId ?? this.campusId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      description: description ?? this.description,
      zone: zone ?? this.zone,
      neededBy: neededBy ?? this.neededBy,
      borrowDurationMinutes:
          borrowDurationMinutes ?? this.borrowDurationMinutes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      matchedOfferId: matchedOfferId ?? this.matchedOfferId,
      requesterDisplayName: requesterDisplayName ?? this.requesterDisplayName,
      requesterSection: requesterSection ?? this.requesterSection,
    );
  }
}

/// An offer from a potential lender.
class LendOffer {
  const LendOffer({
    required this.id,
    required this.requestId,
    required this.lenderId,
    required this.availability,
    required this.status,
    required this.createdAt,
    this.note = '',
    this.proposedReturnPoint,
    this.lenderDisplayName = '',
    this.lenderSection = '',
    this.lenderTrustScore = 0,
  });

  final String id;
  final String requestId;
  final String lenderId;
  final String availability;
  final String note;
  final String? proposedReturnPoint;
  final OfferStatus status;
  final DateTime createdAt;
  final String lenderDisplayName;
  final String lenderSection;
  final int lenderTrustScore;
}

/// Active or completed loan.
class Loan {
  const Loan({
    required this.id,
    required this.requestId,
    required this.offerId,
    required this.requesterId,
    required this.lenderId,
    required this.campusId,
    required this.itemName,
    required this.category,
    required this.borrowDurationMinutes,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.dueAt,
    this.borrowerConfirmedHandoff = false,
    this.lenderConfirmedHandoff = false,
    this.borrowerConfirmedReturn = false,
    this.lenderConfirmedReturn = false,
    // Matched-pair private details (populated only for the matched pair):
    this.lenderDisplayName = '',
    this.lenderSection = '',
    this.borrowerDisplayName = '',
    this.borrowerSection = '',
    this.exactHandoffPoint = '',
    this.agreedReturnPoint,
    this.returnPointAcknowledged = false,
  });

  final String id;
  final String requestId;
  final String offerId;
  final String requesterId;
  final String lenderId;
  final String campusId;
  final String itemName;
  final ItemCategory category;
  final int borrowDurationMinutes;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? dueAt;

  // Handoff confirmations
  final bool borrowerConfirmedHandoff;
  final bool lenderConfirmedHandoff;

  // Return confirmations
  final bool borrowerConfirmedReturn;
  final bool lenderConfirmedReturn;

  // Private matched-pair fields
  final String lenderDisplayName;
  final String lenderSection;
  final String borrowerDisplayName;
  final String borrowerSection;
  final String exactHandoffPoint;
  final String? agreedReturnPoint;
  final bool returnPointAcknowledged;

  bool get bothConfirmedHandoff =>
      borrowerConfirmedHandoff && lenderConfirmedHandoff;
  bool get bothConfirmedReturn =>
      borrowerConfirmedReturn && lenderConfirmedReturn;

  Loan copyWith({
    String? id,
    String? requestId,
    String? offerId,
    String? requesterId,
    String? lenderId,
    String? campusId,
    String? itemName,
    ItemCategory? category,
    int? borrowDurationMinutes,
    LoanStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? dueAt,
    bool? borrowerConfirmedHandoff,
    bool? lenderConfirmedHandoff,
    bool? borrowerConfirmedReturn,
    bool? lenderConfirmedReturn,
    String? lenderDisplayName,
    String? lenderSection,
    String? borrowerDisplayName,
    String? borrowerSection,
    String? exactHandoffPoint,
    String? agreedReturnPoint,
    bool? returnPointAcknowledged,
  }) {
    return Loan(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      offerId: offerId ?? this.offerId,
      requesterId: requesterId ?? this.requesterId,
      lenderId: lenderId ?? this.lenderId,
      campusId: campusId ?? this.campusId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      borrowDurationMinutes:
          borrowDurationMinutes ?? this.borrowDurationMinutes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      dueAt: dueAt ?? this.dueAt,
      borrowerConfirmedHandoff:
          borrowerConfirmedHandoff ?? this.borrowerConfirmedHandoff,
      lenderConfirmedHandoff:
          lenderConfirmedHandoff ?? this.lenderConfirmedHandoff,
      borrowerConfirmedReturn:
          borrowerConfirmedReturn ?? this.borrowerConfirmedReturn,
      lenderConfirmedReturn:
          lenderConfirmedReturn ?? this.lenderConfirmedReturn,
      lenderDisplayName: lenderDisplayName ?? this.lenderDisplayName,
      lenderSection: lenderSection ?? this.lenderSection,
      borrowerDisplayName: borrowerDisplayName ?? this.borrowerDisplayName,
      borrowerSection: borrowerSection ?? this.borrowerSection,
      exactHandoffPoint: exactHandoffPoint ?? this.exactHandoffPoint,
      agreedReturnPoint: agreedReturnPoint ?? this.agreedReturnPoint,
      returnPointAcknowledged:
          returnPointAcknowledged ?? this.returnPointAcknowledged,
    );
  }
}

/// App user profile.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.campusId,
    required this.verifiedAt,
    required this.createdAt,
    this.rollNumber = '',
    this.classSection = '',
    this.contactPreference = '',
    this.lentCount = 0,
    this.borrowedCount = 0,
  });

  final String uid;
  final String email;
  final String displayName;
  final String campusId;
  final DateTime verifiedAt;
  final DateTime createdAt;
  final String rollNumber;
  final String classSection;
  final String contactPreference;
  final int lentCount;
  final int borrowedCount;

  bool get isProfileComplete =>
      rollNumber.isNotEmpty && classSection.isNotEmpty;
}

/// In-app notification record.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    this.relatedId,
    this.readAt,
    this.emoji = '🔔',
  });

  final String id;
  final String type;
  final String title;
  final String emoji;
  final String? relatedId;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
}
