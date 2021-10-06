class Stop {
  String busStopCode;
  String roadName;
  String description;
  double latitude;
  double longitude;

  Stop(
      {required this.busStopCode,
      required this.roadName,
      required this.description,
      required this.latitude,
      required this.longitude});

  Stop.fromJson(Map<String, dynamic> json)
      : busStopCode = json['BusStopCode'] as String,
        roadName = json['RoadName'] as String,
        description = json['Description'] as String,
        latitude = (json['Latitude'] as double),
        longitude = (json['Longitude'] as double);

  Map<String, dynamic> toJson() {
    return {
      'BusStopCode': busStopCode,
      'RoadName': roadName,
      'Description': description,
      'Latitude': latitude,
      'Longitude': longitude
    };
  }
}
