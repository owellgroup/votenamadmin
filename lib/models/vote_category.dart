class VoteCategory {
  final int? id;
  final String categoryName;

  VoteCategory({
    this.id,
    required this.categoryName,
  });

  factory VoteCategory.fromJson(Map<String, dynamic> json) {
    // The Java API returns CategoryName (capital C, capital N)
    // Try multiple possible field names for category name
    String name = '';
    
    // First try the exact API field name
    if (json['CategoryName'] != null) {
      final value = json['CategoryName'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    // Try other variations if still empty
    if (name.isEmpty && json['categoryName'] != null) {
      final value = json['categoryName'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty && json['name'] != null) {
      final value = json['name'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    if (name.isEmpty && json['category_name'] != null) {
      final value = json['category_name'].toString().trim();
      if (value.isNotEmpty && value != 'null') {
        name = value;
      }
    }
    
    // Final fallback - try to get any non-null string value from any field
    if (name.isEmpty) {
      for (var key in json.keys) {
        if (key.toLowerCase().contains('name') || key.toLowerCase().contains('category')) {
          final value = json[key]?.toString().trim();
          if (value != null && value.isNotEmpty && value != 'null') {
            name = value;
            break;
          }
        }
      }
    }
    
    // If still empty, use fallback
    if (name.isEmpty) {
      final catId = json['id']?.toString() ?? 'Unknown';
      name = 'Category $catId';
    }
    
    return VoteCategory(
      id: json['id'] as int?,
      categoryName: name,
    );
  }

  Map<String, dynamic> toJson() {
    // API expects lowercase 'categoryName' for POST/PUT requests
    // Only send categoryName (not id) when creating
    return {
      'categoryName': categoryName,
    };
  }

  // Add equality operators for DropdownButton
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteCategory && other.id == id && other.categoryName == categoryName;
  }

  @override
  int get hashCode => id.hashCode ^ categoryName.hashCode;
}

