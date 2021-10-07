import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class BookMark extends Equatable {
  final String busStopCode;
  final String desc;

  BookMark(this.busStopCode, this.desc);

  BookMark.fromJson(Map<String, dynamic> json)
      : busStopCode = json['busStopCode'] as String,
        desc = json['description'] as String;

  Map<String, dynamic>? toJson() {
    return {'busStopCode': busStopCode, 'description': desc};
  }

  @override
  List<Object?> get props => [busStopCode, desc];
}

class BookMarkCubit extends HydratedCubit<List<BookMark>> {
  BookMarkCubit() : super(<BookMark>[]);

  void addBookMark(BookMark bookMark) {
    emit([bookMark] + state);
  }

  void removeBookMark(int index) {
    emit(state.sublist(0, index) + state.sublist(index + 1));
  }

  void removeLastBookMark() {
    emit(state.sublist(0, state.length - 1));
  }

  @override
  List<BookMark>? fromJson(Map<String, dynamic> json) {
    List<dynamic>? listBookMark = json['bookmarks'];
    if (listBookMark == null) {
      return null;
    }
    return List<BookMark>.generate(listBookMark.length, (index) {
      return BookMark.fromJson(listBookMark[index]);
    });
  }

  @override
  Map<String, dynamic>? toJson(List<BookMark> state) {
    return {
      'bookmarks':
          List<dynamic>.generate(state.length, (index) => state[index].toJson())
    };
  }
}
