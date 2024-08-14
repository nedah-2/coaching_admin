import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/utils/calculate_minutes.dart';

class Task {
  String? id;
  String title;
  String description;
  String deadline;
  bool isDone;
  List<Resource>? resources;
  String? duration;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.deadline,
      required this.isDone,
      this.resources,
      this.duration});

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    var resourcesFromFirestore = data['resources'] as List<dynamic>?;
    List<Resource>? resourceList;

    if (resourcesFromFirestore != null) {
      resourceList = resourcesFromFirestore
          .map((resourceData) => Resource.fromFirestore(resourceData))
          .toList();
    }

    return Task(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        deadline: data['deadline'] ?? '',
        isDone: data['isDone'] ?? false,
        resources: resourceList,
        duration: data['duration'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>>? resourcesToFirestore;

    if (resources != null) {
      resourcesToFirestore =
          resources!.map((resource) => resource.toFirestore()).toList();
    }

    calculateTotalDuration();

    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'isDone': isDone,
      'resources': resourcesToFirestore,
      'duration': duration
    };
  }

  // Method to calculate the total duration of resources
  void calculateTotalDuration() {
    if (resources != null) {
      int total =
          resources!.fold(0, (total, resource) => total + resource.duration);
      duration = formatDurationFromTotalMinutes(total);
    }
  }
}

class Resource {
  String? id;
  String type;
  String title;
  int duration;
  String resource;

  Resource(
      {this.id,
      required this.type,
      required this.title,
      required this.duration,
      required this.resource});

  factory Resource.fromFirestore(Map<String, dynamic> data) {
    return Resource(
        id: data['id'] ?? '',
        type: data['type'] ?? '',
        title: data['title'] ?? '',
        duration: data['duration'] ?? 0,
        resource: data['resource'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'duration': duration,
      'resource': resource
    };
  }
}
