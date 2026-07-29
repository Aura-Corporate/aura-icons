import 'package:aura_icons_tool/src/name_utils.dart';
import 'package:test/test.dart';

void main() {
  group('kebabToLowerCamel', () {
    test('simple two-segment name', () {
      expect(kebabToLowerCamel('arrow-down'), 'arrowDown');
    });

    test('multi-segment name', () {
      expect(kebabToLowerCamel('users-group-rounded'), 'usersGroupRounded');
    });

    test('single segment name', () {
      expect(kebabToLowerCamel('home'), 'home');
    });
  });

  group('kebabToPascalCase', () {
    test('capitalizes the first letter of the camelCase result', () {
      expect(kebabToPascalCase('arrow-down'), 'ArrowDown');
    });
  });

  group('resolveDartIdentifier', () {
    test('plain names resolve via camelCase', () {
      expect(resolveDartIdentifier('arrow-down', {}), 'arrowDown');
    });

    test('reserved-word collisions get an automatic Icon suffix', () {
      expect(resolveDartIdentifier('export', {}), 'exportIcon');
      expect(resolveDartIdentifier('import', {}), 'importIcon');
      expect(resolveDartIdentifier('case', {}), 'caseIcon');
    });

    test('explicit override always wins over automatic resolution', () {
      expect(
        resolveDartIdentifier('export', {'export': 'exportArrow'}),
        'exportArrow',
      );
    });

    test('a name starting with a digit gets an "n" prefix', () {
      expect(resolveDartIdentifier('4k-monitor', {}), 'n4kMonitor');
    });
  });
}
