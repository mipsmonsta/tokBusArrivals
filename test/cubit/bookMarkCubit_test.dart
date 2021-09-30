import 'package:bloc_test/bloc_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../lib/cubit/bookMarkCubit.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {} //using mocktail

void main() {
  group('BookMarkCubitTest', () {
    late BookMark oneBookMark;
    late BookMark secondBookMark;
    late Storage storage;
    setUp(() {
      // setting up mock storage
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when<dynamic>(() => storage.read(any())).thenReturn(<String, dynamic>{});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
      oneBookMark = BookMark("65009", "Punggol Interchange");
      secondBookMark = BookMark("83111", "Jln Eunos");
    });

    test('reads from storage once upon initialization', () {
      BookMarkCubit();
      verify<dynamic>(() => storage.read('BookMarkCubit')).called(1);
    });
    blocTest(
      'emits [] when nothing is added',
      build: () => BookMarkCubit(),
      expect: () => [],
    );

    blocTest(
      'emits [oneBookMark] when BookMark is added',
      build: () => BookMarkCubit(),
      act: (cubit) => (cubit as BookMarkCubit).addBookMark(oneBookMark),
      expect: () => [
        [oneBookMark]
      ],
    );

    blocTest(
      'emits correctly when 2x oneBookMarks are added',
      build: () => BookMarkCubit(),
      act: (cubit) {
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
      },
      expect: () => [
        [oneBookMark],
        [oneBookMark, oneBookMark]
      ],
    );

    blocTest(
      'emits correctly when oneBookMark is removed using removeLastBookMark',
      build: () => BookMarkCubit(),
      act: (cubit) {
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).removeLastBookMark();
      },
      expect: () => [
        [oneBookMark],
        [oneBookMark, oneBookMark],
        [oneBookMark, oneBookMark, oneBookMark],
        [oneBookMark, oneBookMark],
      ],
    );

    blocTest(
      'emits correctly when oneBookMark is removed using index',
      build: () => BookMarkCubit(),
      act: (cubit) {
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).addBookMark(secondBookMark);
        (cubit as BookMarkCubit).removeBookMark(0);
      },
      expect: () => [
        [oneBookMark],
        [oneBookMark, secondBookMark],
        [secondBookMark],
      ],
    );

    blocTest(
      'emits correctly when secondBookMark is removed using index',
      build: () => BookMarkCubit(),
      act: (cubit) {
        (cubit as BookMarkCubit).addBookMark(oneBookMark);
        (cubit as BookMarkCubit).addBookMark(secondBookMark);
        (cubit as BookMarkCubit).removeBookMark(1);
      },
      expect: () => [
        [oneBookMark],
        [oneBookMark, secondBookMark],
        [oneBookMark],
      ],
    );
  });
}
