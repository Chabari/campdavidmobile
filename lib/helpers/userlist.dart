// To parse this JSON data, do
//
//     final ridersList = ridersListFromJson(jsonString);

import 'dart:convert';

List<RidersList> ridersListFromJson(String str) => List<RidersList>.from(json.decode(str).map((x) => RidersList.fromJson(x)));

String ridersListToJson(List<RidersList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RidersList {
    RidersList({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        required this.createdAt,
        required this.photo,
        required this.name,
    });

    int id;
    String firstName;
    String lastName;
    String email;
    String phone;
    DateTime createdAt;
    String photo;
    String name;

    factory RidersList.fromJson(Map<String, dynamic> json) => RidersList(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        createdAt: DateTime.parse(json["created_at"]),
        photo: json["photo"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "created_at": createdAt.toIso8601String(),
        "photo": photo,
        "name": name,
    };
}
