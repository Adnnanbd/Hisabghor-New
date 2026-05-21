class Customer {
  String id;
  String nameBangla;
  String nameEnglish;
  String phone;
  String? address;
  String? email;
  double dueAmount;
  double totalPurchase;
  int totalVisits;
  DateTime? lastPurchase;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.nameBangla,
    required this.nameEnglish,
    required this.phone,
    this.address,
    this.email,
    this.dueAmount = 0.0,
    this.totalPurchase = 0.0,
    this.totalVisits = 0,
    this.lastPurchase,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => nameBangla.isNotEmpty ? nameBangla : nameEnglish;
  
  bool get hasDue => dueAmount > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameBangla': nameBangla,
      'nameEnglish': nameEnglish,
      'phone': phone,
      'address': address,
      'email': email,
      'dueAmount': dueAmount,
      'totalPurchase': totalPurchase,
      'totalVisits': totalVisits,
      'lastPurchase': lastPurchase?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      nameBangla: map['nameBangla'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      email: map['email'],
      dueAmount: (map['dueAmount'] ?? 0.0).toDouble(),
      totalPurchase: (map['totalPurchase'] ?? 0.0).toDouble(),
      totalVisits: map['totalVisits'] ?? 0,
      lastPurchase: map['lastPurchase'] != null 
          ? DateTime.parse(map['lastPurchase']) 
          : null,
      notes: map['notes'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  Customer copyWith({
    String? id,
    String? nameBangla,
    String? nameEnglish,
    String? phone,
    String? address,
    String? email,
    double? dueAmount,
    double? totalPurchase,
    int? totalVisits,
    DateTime? lastPurchase,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      nameBangla: nameBangla ?? this.nameBangla,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      dueAmount: dueAmount ?? this.dueAmount,
      totalPurchase: totalPurchase ?? this.totalPurchase,
      totalVisits: totalVisits ?? this.totalVisits,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
