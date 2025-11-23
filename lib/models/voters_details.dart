import 'candidate.dart';
import 'region.dart';
import 'vote_category.dart';

class VotersDetails {
  final int? id;
  final String fullName;
  final String nationalIdNumber;
  final DateTime dateOfBirth;
  final String address;
  final Region region;
  final String phoneNumber;
  final String email;
  final String votersIdNumber;
  final Candidate candidate;
  final VoteCategory voteCategory;
  final DateTime? voteDate;

  VotersDetails({
    this.id,
    required this.fullName,
    required this.nationalIdNumber,
    required this.dateOfBirth,
    required this.address,
    required this.region,
    required this.phoneNumber,
    required this.email,
    required this.votersIdNumber,
    required this.candidate,
    required this.voteCategory,
    this.voteDate,
  });

  factory VotersDetails.fromJson(Map<String, dynamic> json) {
    return VotersDetails(
      id: json['id'] as int?,
      fullName: json['fullName'] ?? '',
      nationalIdNumber: json['nationalIdNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      address: json['address'] ?? '',
      region: Region.fromJson(json['region']),
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      votersIdNumber: json['votersIdNumber'] ?? '',
      candidate: Candidate.fromJson(json['candidate']),
      voteCategory: VoteCategory.fromJson(json['voteCategory']),
      voteDate: json['voteDate'] != null
          ? DateTime.parse(json['voteDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'nationalIdNumber': nationalIdNumber,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
      'address': address,
      'region': {'id': region.id},
      'phoneNumber': phoneNumber,
      'email': email,
      'votersIdNumber': votersIdNumber,
      'candidate': {'id': candidate.id},
      'voteCategory': {'id': voteCategory.id},
    };
  }
}

