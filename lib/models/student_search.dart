class StudentSearchModel {
  final String id;
  String name;
  final String email;
  String profileUrl;

  StudentSearchModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileUrl,
  });

  // Method to convert from JSON to the model
  factory StudentSearchModel.fromJson(Map<String, dynamic> json) {
    return StudentSearchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileUrl: json['profileUrl'] as String,
    );
  }

  
  // Method to convert from JSON to the model
  factory StudentSearchModel.fromFirestore(Map<String, dynamic> json, String id) {
    return StudentSearchModel(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      profileUrl: json['profileUrl'] as String,
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileUrl': profileUrl,
    };
  }
}
