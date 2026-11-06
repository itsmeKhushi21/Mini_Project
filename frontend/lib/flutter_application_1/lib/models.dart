part of 'main.dart';

enum UserRole { citizen, driver, manager, admin }

class ManagerAccount {
  ManagerAccount({
    required this.name,
    required this.email,
    required this.password,
    this.managerId = '',
    this.phone = '',
    this.zone = 'Unassigned',
    this.isActive = true,
    this.registeredAt,
    this.activityHistory = const [],
  });

  String managerId;
  String name;
  String email;
  String password;
  String phone;
  String zone;
  bool isActive;
  final DateTime? registeredAt;
  List<String> activityHistory;
}

class CustomerRecord {
  CustomerRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.addresses,
    required this.complaints,
    required this.collections,
    this.isActive = true,
    this.registeredAt,
    this.activityHistory = const [],
  });

  final String id;
  String name;
  String phone;
  String email;
  final List<String> addresses;
  final List<String> complaints;
  final List<String> collections;
  bool isActive;
  final DateTime? registeredAt;
  List<String> activityHistory;
}

class DriverRecord {
  DriverRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.employeeId,
    required this.vehicleRegistration,
    required this.availability,
    required this.assignedJobs,
    required this.completedCollections,
    this.isActive = true,
    this.registeredAt,
    this.activityHistory = const [],
  });

  final String id;
  String name;
  String phone;
  String email;
  String password;
  String employeeId;
  String vehicleRegistration;
  String availability;
  int assignedJobs;
  int completedCollections;
  bool isActive;
  final DateTime? registeredAt;
  List<String> activityHistory;
}

class RequestRecord {
  RequestRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.customer,
    required this.location,
    required this.createdAt,
    required this.priority,
    required this.status,
    this.photoName,
    this.notes = '',
    this.forwardedForReview = false,
    this.assignedDriver,
    this.scheduledAt,
    this.assignedManager,
    this.resolutionHistory = const [],
  });

  final String id;
  final String type;
  final String title;
  final String customer;
  final String location;
  final DateTime createdAt;
  String priority;
  String status;
  final String? photoName;
  String notes;
  bool forwardedForReview;
  String? assignedDriver;
  DateTime? scheduledAt;
  String? assignedManager;
  List<String> resolutionHistory;
}

class GarbageBinRecord {
  GarbageBinRecord({
    required this.id,
    required this.location,
    required this.type,
    required this.capacity,
    required this.condition,
    required this.lastCollection,
    required this.collectionHistory,
    this.requiresCollection = false,
    this.isDamaged = false,
    this.fillLevel = 50,
    this.gpsCoordinates = '',
    this.maintenanceHistory = const [],
  });

  final String id;
  String location;
  String type;
  String capacity;
  String condition;
  DateTime lastCollection;
  final List<String> collectionHistory;
  bool requiresCollection;
  bool isDamaged;
  int fillLevel;
  String gpsCoordinates;
  List<String> maintenanceHistory;
}

class CollectionSchedule {
  CollectionSchedule({
    required this.id,
    required this.wasteType,
    required this.area,
    required this.driverId,
    required this.vehicle,
    required this.startsAt,
    required this.timeSlot,
    this.status = 'Scheduled',
  });

  final String id;
  String wasteType;
  String area;
  String driverId;
  String vehicle;
  DateTime startsAt;
  String timeSlot;
  String status;
}

ManagerAccount? findManagerAccount(
  List<ManagerAccount> accounts,
  String email,
  String password,
) {
  final normalizedEmail = email.trim().toLowerCase();
  for (final account in accounts) {
    if (account.isActive &&
        account.email.toLowerCase() == normalizedEmail &&
        account.password == password) {
      return account;
    }
  }
  return null;
}

class WasteReport {
  WasteReport({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.severity,
    required this.createdAt,
    this.status = 'Submitted',
    this.customer = 'Registered customer',
    this.driverName,
    this.photoName,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final String severity;
  final DateTime createdAt;
  String status;
  final String customer;
  final String? driverName;
  final String? photoName;
}
