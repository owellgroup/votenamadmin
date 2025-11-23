import 'vote_category.dart';

class Candidate {
  final int? id;
  final String fullName;
  final String partyName;
  final String position;
  final String? photoUrl;
  final String? partyLogoUrl;
  final VoteCategory? voteCategory;

  Candidate({
    this.id,
    required this.fullName,
    required this.partyName,
    required this.position,
    this.photoUrl,
    this.partyLogoUrl,
    this.voteCategory,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    // Construct full URLs for photos and logos
    // Convert any localhost URLs to production URL
    String? photoUrl;
    if (json['photoUrl'] != null && json['photoUrl'].toString().isNotEmpty) {
      final photo = json['photoUrl'].toString();
      
      // If it's already a full URL, replace localhost with production URL
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        // Replace localhost:8080 with production URL
        photoUrl = photo.replaceAll('http://localhost:8080', 'https://vote.owellgraphics.com')
                        .replaceAll('https://localhost:8080', 'https://vote.owellgraphics.com');
      } else if (photo.startsWith('/')) {
        // Relative path starting with /
        photoUrl = 'https://vote.owellgraphics.com$photo';
      } else {
        // Just filename, construct full URL
        photoUrl = 'https://vote.owellgraphics.com/api/photos/view/$photo';
      }
    }
    
    String? partyLogoUrl;
    if (json['partyLogoUrl'] != null && json['partyLogoUrl'].toString().isNotEmpty) {
      final logo = json['partyLogoUrl'].toString();
      
      // If it's already a full URL, replace localhost with production URL
      if (logo.startsWith('http://') || logo.startsWith('https://')) {
        // Replace localhost:8080 with production URL
        partyLogoUrl = logo.replaceAll('http://localhost:8080', 'https://vote.owellgraphics.com')
                           .replaceAll('https://localhost:8080', 'https://vote.owellgraphics.com');
      } else if (logo.startsWith('/')) {
        // Relative path starting with /
        partyLogoUrl = 'https://vote.owellgraphics.com$logo';
      } else {
        // Just filename, construct full URL
        partyLogoUrl = 'https://vote.owellgraphics.com/api/logos/view/$logo';
      }
    }
    
    return Candidate(
      id: json['id'] as int?,
      fullName: json['fullName'] ?? '',
      partyName: json['partyName'] ?? '',
      position: json['position'] ?? '',
      photoUrl: photoUrl,
      partyLogoUrl: partyLogoUrl,
      voteCategory: json['voteCategory'] != null
          ? VoteCategory.fromJson(json['voteCategory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'partyName': partyName,
      'position': position,
      'photoUrl': photoUrl,
      'partyLogoUrl': partyLogoUrl,
      'voteCategory': voteCategory?.toJson(),
    };
  }
}

