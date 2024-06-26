import 'package:fake_async/fake_async.dart';
import 'package:mobx/mobx.dart';
import 'package:mocktail/mocktail.dart' as mock;
import 'package:test/test.dart';

import 'shared_mocks.dart';
import 'util.dart';

// ignore_for_file: unnecessary_lambdas

void main() {
  testSetup();

  group('when()', () {
    test('basics work', () {
      var executed = false;
      final x = Observable(10);
      final d = when((_) => x.value > 10, () {
        executed = true;
      }, name: 'Basic when');

      expect(executed, isFalse);
      expect(d.reaction.name, 'Basic when');

      x.value = 11;

      expect(executed, isTrue);
      expect(d.reaction.isDisposed, isTrue);
      executed = false;

      x.value = 12;
      expect(executed, isFalse); // No more effects as its disposed
    });

    test('with default name', () {
      final d = when((_) => true, () {});

      expect(d.reaction.name, startsWith('When@'));

      d();
    });

    test('works with asyncWhen', () {
      final x = Observable(10);
      asyncWhen((_) => x.value > 10, name: 'Async-when').then((_) {
        expect(true, isTrue);
      });

      x.value = 11;
    });

    test('fires onError on exception', () {
      var thrown = false;
      final dispose = when(
          (_) {
            throw Exception('FAILED in when');
          },
          () {},
          onError: (_, a) {
            thrown = true;
          });

      expect(thrown, isTrue);
      dispose();
    });

    test('exceptions inside asyncWhen are caught and reaction is disposed', () {
      late Reaction rxn;
      asyncWhen((rx) {
        rxn = rx;
        throw Exception('FAIL');
      }, name: 'Async-when')
          .catchError((_) {
        expect(rxn.isDisposed, isTrue);
      });
    });

    test('uses provided context', () {
      final context = MockContext();
      mock.when(() => context.nameFor(mock.any())).thenReturn('Test-When');

      when((_) => true, () {}, context: context);

      mock.verify(() => context.runReactions());
    });

    test('throws if timeout occurs before when() completes', () {
      fakeAsync((async) {
        final x = Observable(10);
        var thrown = false;
        final d =
            when((_) => x.value > 10, () {}, timeout: 1000, onError: (_, a) {
          thrown = true;
        });

        async.elapse(const Duration(milliseconds: 1000)); // cause a timeout
        expect(thrown, isTrue);
        expect(d.reaction.isDisposed, isTrue);

        d();
      });
    });

    test('does NOT throw if when() completes before timeout', () {
      fakeAsync((async) {
        final x = Observable(10);
        final d = when((_) => x.value > 10, () {}, timeout: 1000);

        x.value = 11;
        expect(() {
          async.elapse(const Duration(milliseconds: 1000));
        }, returnsNormally);
        expect(d.reaction.isDisposed, isTrue);

        d();
      });
    });
  });
}
