class VotersCard {
  final int? id;
  final String cardNumber;
  final String cardName;

  VotersCard({
    this.id,
    required this.cardNumber,
    required this.cardName,
  });

  factory VotersCard.fromJson(Map<String, dynamic> json) {
    return VotersCard(
      id: json['id'] as int?,
      cardNumber: json['cardNumber'] ?? '',
      cardName: json['cardName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardName': cardName,
    };
  }
}

