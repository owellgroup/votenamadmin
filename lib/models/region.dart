class Region {
  final int? id;
  final String regionName;

  Region({
    this.id,
    required this.regionName,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    // Try multiple possible field names for region name
    String name = '';
    
    // Handle null or empty json
    if (json.isEmpty) {
      name = 'Unknown Region';
    } else {
      // The Java API returns RegionName (capital R, capital N)
      // Try the exact API field name first
      if (json['RegionName'] != null) {
        final value = json['RegionName'].toString().trim();
        if (value.isNotEmpty && value != 'null') {
          name = value;
        }
      }
      
      // Try other variations if still empty
      if (name.isEmpty && json['regionName'] != null) {
        final value = json['regionName'].toString().trim();
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
      
      if (name.isEmpty && json['region_name'] != null) {
        final value = json['region_name'].toString().trim();
        if (value.isNotEmpty && value != 'null') {
          name = value;
        }
      }
      
      // If still empty, try to get from any key that might contain "name" or "region"
      if (name.isEmpty) {
        for (var key in json.keys) {
          if ((key.toLowerCase().contains('name') || key.toLowerCase().contains('region')) &&
              json[key] != null) {
            final value = json[key].toString().trim();
            if (value.isNotEmpty && value != 'null') {
              name = value;
              break;
            }
          }
        }
      }
      
      // Final fallback - use a more user-friendly name
      if (name.isEmpty) {
        final regionId = json['id']?.toString() ?? 'Unknown';
        name = 'Region $regionId';
      }
    }
    
    return Region(
      id: json['id'] as int?,
      regionName: name,
    );
  }

  Map<String, dynamic> toJson() {
    // API expects lowercase 'regionName' for POST/PUT requests
    // Only send regionName (not id) when creating
    return {
      'regionName': regionName,
    };
  }

  // Add equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Region && other.id == id && other.regionName == regionName;
  }

  @override
  int get hashCode => id.hashCode ^ regionName.hashCode;
}

