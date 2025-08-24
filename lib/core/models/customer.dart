class Customer {
  final String id;
  final String name;
  final String companyIcon;
  final String flag;
  final String description;
  final String status;
  final String? avatar;

  Customer({
    required this.id,
    required this.name,
    required this.companyIcon,
    required this.flag,
    required this.description,
    required this.status,
    this.avatar,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      companyIcon: json['companyIcon'] ?? '',
      flag: json['flag'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyIcon': companyIcon,
      'flag': flag,
      'description': description,
      'status': status,
      'avatar': avatar,
    };
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, companyIcon: $companyIcon, flag: $flag, description: $description, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
