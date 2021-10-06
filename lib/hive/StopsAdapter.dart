import 'package:bus_stops/bus_stops.dart';
import 'package:hive/hive.dart';

class StopAdapter extends TypeAdapter<Stop> {
  @override
  Stop read(BinaryReader reader) {
    return Stop(
      busStopCode: reader.readString(),
      description: reader.readString(),
      roadName: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
    );
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Stop obj) {
    writer.writeString(obj.busStopCode);
    writer.writeString(obj.description);
    writer.writeString(obj.roadName);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
