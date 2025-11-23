import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import '../models/vote_category.dart';
import '../models/region.dart';
import '../models/candidate.dart';
import '../models/voters_card.dart';
import '../models/voters_details.dart';

class AdminApiService {
  static const String baseUrl = 'https://vote.owellgraphics.com';
  // For testing, use your computer's IP address
  // static const String baseUrl = 'http://192.168.1.100:8484';

  // ========== Authentication ==========
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Users Management ==========
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['users'] != null) {
          return (data['users'] as List)
              .map((item) => User.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load users');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUser(int id, User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/users/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Vote Categories Management ==========
  static Future<List<VoteCategory>> getAllVoteCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/vote-categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['voteCategories'] != null) {
          return (data['voteCategories'] as List)
              .map((item) => VoteCategory.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load vote categories');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createVoteCategory(VoteCategory category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/vote-categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateVoteCategory(int id, VoteCategory category) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/vote-categories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteVoteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/vote-categories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Regions Management ==========
  static Future<List<Region>> getAllRegions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/regions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['regions'] != null) {
          return (data['regions'] as List)
              .map((item) => Region.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load regions');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createRegion(Region region) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/regions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(region.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final result = json.decode(response.body);
          throw Exception(result['message'] ?? 'Failed to create region: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to create region: ${response.statusCode} - ${response.body}');
        }
      }

      final result = json.decode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to create region');
      }

      return result;
    } catch (e) {
      throw Exception('Error creating region: $e');
    }
  }

  static Future<Map<String, dynamic>> updateRegion(int id, Region region) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/regions/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(region.toJson()),
      );

      if (response.statusCode != 200) {
        try {
          final result = json.decode(response.body);
          throw Exception(result['message'] ?? 'Failed to update region: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to update region: ${response.statusCode} - ${response.body}');
        }
      }

      final result = json.decode(response.body);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to update region');
      }

      return result;
    } catch (e) {
      throw Exception('Error updating region: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteRegion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/regions/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Voters Cards Management ==========
  static Future<List<VotersCard>> getAllVotersCards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/voters-cards'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['votersCards'] != null) {
          return (data['votersCards'] as List)
              .map((item) => VotersCard.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load voter cards');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createVotersCard(VotersCard card) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/voters-cards'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(card.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateVotersCard(int id, VotersCard card) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/voters-cards/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(card.toJson()),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteVotersCard(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/voters-cards/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Candidates Management ==========
  static Future<List<Candidate>> getAllCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/candidates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['candidates'] != null) {
          return (data['candidates'] as List)
              .map((item) => Candidate.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load candidates');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createCandidate({
    required String fullName,
    required String partyName,
    required String position,
    required int voteCategoryId,
    File? photo,
    File? partyLogo,
    Uint8List? photoBytes,
    String? photoName,
    Uint8List? partyLogoBytes,
    String? partyLogoName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/admin/candidates'),
      );

      request.fields['fullName'] = fullName;
      request.fields['partyName'] = partyName;
      request.fields['position'] = position;
      request.fields['voteCategoryId'] = voteCategoryId.toString();

      if (photoBytes != null && photoName != null) {
        // Web: use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: photoName,
          ),
        );
      } else if (photo != null) {
        // Non-web: use file path
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      }

      if (partyLogoBytes != null && partyLogoName != null) {
        // Web: use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'partyLogo',
            partyLogoBytes,
            filename: partyLogoName,
          ),
        );
      } else if (partyLogo != null) {
        // Non-web: use file path
        request.files.add(
          await http.MultipartFile.fromPath('partyLogo', partyLogo.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final result = json.decode(responseBody);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['message'] ?? 'Failed to create candidate');
      }

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to create candidate');
      }

      return result;
    } catch (e) {
      throw Exception('Error creating candidate: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCandidate({
    required int id,
    String? fullName,
    String? partyName,
    String? position,
    int? voteCategoryId,
    File? photo,
    File? partyLogo,
    Uint8List? photoBytes,
    String? photoName,
    Uint8List? partyLogoBytes,
    String? partyLogoName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/admin/candidates/$id'),
      );

      // Always send required fields (backend requires them even for updates)
      if (fullName != null && fullName.isNotEmpty) {
        request.fields['fullName'] = fullName;
      }
      if (partyName != null && partyName.isNotEmpty) {
        request.fields['partyName'] = partyName;
      }
      if (position != null && position.isNotEmpty) {
        request.fields['position'] = position;
      }
      // voteCategoryId is required - always send it
      if (voteCategoryId != null) {
        request.fields['voteCategoryId'] = voteCategoryId.toString();
      }

      // Only add files if they are actually provided (for updates, files are optional)
      if (photoBytes != null && photoName != null && photoBytes.isNotEmpty) {
        // Web: use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: photoName,
          ),
        );
      } else if (photo != null && await photo.exists()) {
        // Non-web: use file path
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      }

      if (partyLogoBytes != null && partyLogoName != null && partyLogoBytes.isNotEmpty) {
        // Web: use bytes directly
        request.files.add(
          http.MultipartFile.fromBytes(
            'partyLogo',
            partyLogoBytes,
            filename: partyLogoName,
          ),
        );
      } else if (partyLogo != null && await partyLogo.exists()) {
        // Non-web: use file path
        request.files.add(
          await http.MultipartFile.fromPath('partyLogo', partyLogo.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode != 200) {
        try {
          final result = json.decode(responseBody);
          throw Exception(result['message'] ?? 'Failed to update candidate: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to update candidate: ${response.statusCode} - $responseBody');
        }
      }

      final result = json.decode(responseBody);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to update candidate');
      }

      return result;
    } catch (e) {
      throw Exception('Error updating candidate: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteCandidate(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/candidates/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== Votes Management ==========
  static Future<List<VotersDetails>> getAllVotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/votes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['votes'] != null) {
          return (data['votes'] as List)
              .map((item) => VotersDetails.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load votes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<VotersDetails>> getVotesByCandidate(int candidateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/votes/candidate/$candidateId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['votes'] != null) {
          return (data['votes'] as List)
              .map((item) => VotersDetails.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load votes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<VotersDetails>> getVotesByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/votes/category/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['votes'] != null) {
          return (data['votes'] as List)
              .map((item) => VotersDetails.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load votes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

