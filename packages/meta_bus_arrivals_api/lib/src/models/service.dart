//http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=

class NextBus {
  late DateTime estimatedArrival; //2017-04-29T07:20:24+08:00
  late String capacity; //SEA, SDA, LSD
  late String type; //SD, DD, BD

  NextBus();

  NextBus.fromJson(Map<String, dynamic> json) {
    this.estimatedArrival = DateTime.parse(json['EstimatedArrival']);
    this.capacity = json['Load'];
    this.type = json['Type'];
  }

  Map<String, dynamic> toJson() {
    return {
      'EstimatedArrival': estimatedArrival,
      'Load': capacity,
      'Type': type,
    };
  }
}

class Service {
  late String number;
  late String busOperator;
  NextBus? bus1;
  NextBus? bus2;
  NextBus? bus3;

  Service(
      {required this.number,
      required this.busOperator,
      this.bus1,
      this.bus2,
      this.bus3});

  String toString() {
    return "Service {number: $number, bus operator: $busOperator}";
  }

  Service.fromJson(Map<String, dynamic> json) {
    this.number = json["ServiceNo"];
    this.busOperator = json["Operator"];
    try {
      if (json.containsKey("NextBus") &&
          json["NextBus"].containsKey("EstimatedArrival"))
        this.bus1 = NextBus.fromJson(json["NextBus"]);
    } on FormatException catch (_) {
      //print(e);
    }
    try {
      if (json.containsKey("NextBus2") &&
          json["NextBus2"].containsKey("EstimatedArrival"))
        this.bus2 = NextBus.fromJson(json["NextBus2"]);
    } on FormatException catch (_) {
      //print(e);
    }
    try {
      if (json.containsKey("NextBus3") &&
          json["NextBus3"].containsKey("EstimatedArrival"))
        this.bus3 = NextBus.fromJson(json["NextBus3"]);
    } on FormatException catch (_) {
      //print(e);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'busOperator': busOperator,
      'bus1': bus1,
      'bus2': bus2,
      'bus3': bus3,
    };
  }
}
