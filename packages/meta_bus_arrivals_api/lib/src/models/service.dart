//http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=

class NextBus {
  String estimatedArrival = ""; //2017-04-29T07:20:24+08:00
  NextBus(this.estimatedArrival);

  NextBus.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty && json.containsKey('EstimatedArrival'))
      this.estimatedArrival = json['EstimatedArrival'];
  }

  Map<String, dynamic> toJson() {
    return {
      'EstimatedArrival': estimatedArrival,
    };
  }
}

class Service {
  final String number;
  final String busOperator;
  final NextBus bus1;
  final NextBus bus2;
  final NextBus bus3;

  const Service(
      {required this.number,
      required this.busOperator,
      required this.bus1,
      required this.bus2,
      required this.bus3});

  Service.fromJson(Map<String, dynamic> json)
      : number = json["ServiceNo"],
        busOperator = json["Operator"],
        bus1 = NextBus.fromJson(json["NextBus"]),
        bus2 = NextBus.fromJson(json["NextBus2"]),
        bus3 = NextBus.fromJson(json["NextBus3"]);

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
