class Guardian {
  final String id;
  final String name;
  final String relation;
  final String phonePrimary;
  final String phoneSecondary;
  final String address;
  final String occupation;
  final String notes;

  Guardian({
    required this.id,
    required this.name,
    this.relation = 'أب',
    this.phonePrimary = '',
    this.phoneSecondary = '',
    this.address = '',
    this.occupation = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
        'phonePrimary': phonePrimary,
        'phoneSecondary': phoneSecondary,
        'address': address,
        'occupation': occupation,
        'notes': notes,
      };

  factory Guardian.fromJson(Map<String, dynamic> j) => Guardian(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        relation: j['relation'] ?? 'أب',
        phonePrimary: j['phonePrimary'] ?? '',
        phoneSecondary: j['phoneSecondary'] ?? '',
        address: j['address'] ?? '',
        occupation: j['occupation'] ?? '',
        notes: j['notes'] ?? '',
      );
}
