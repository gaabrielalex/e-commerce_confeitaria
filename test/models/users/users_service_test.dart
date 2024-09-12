import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../utils/random_number_generator.dart';

void main() {
  group('UsersService Validations', () {
    group('Phone validation', () {
      test('Should return null if the phone is a null string', () {
        const String? phone = null;

        final result = UsersServices.validatePhone(phone);

        expect(result, null, reason: 'An empty string is a valid phone');
      });

      test('Should return null if the phone is an empty string', () {
        const String phone = '';

        final result = UsersServices.validatePhone(phone);

        expect(result, null, reason: 'An empty string is a valid phone');
      });

      for (var validPhone in [
        RandomNumberGenerator.generateDigitString(10),
        RandomNumberGenerator.generateDigitString(11)
      ]) {
        test(
            'Should return null if the length of the phone is ${validPhone.length}',
            () {
          String phone = validPhone;

          final result = UsersServices.validatePhone(phone);

          expect(result, null, reason: 'A valid phone is a valid phone');
        });
      }

      for (var validPhone in [
        RandomNumberGenerator.generateDigitString(9),
        RandomNumberGenerator.generateDigitString(8),
        RandomNumberGenerator.generateDigitString(12),
        RandomNumberGenerator.generateDigitString(13)
      ]) {
        test(
            'Should return invalid if the length of the phone is ${validPhone.length}',
            () {
          String phone = validPhone;

          final result = UsersServices.validatePhone(phone);

          expect(result, equals('Insira um telefone válido.'),
              reason: 'A valid phone is a valid phone');
        });
      }
    });
  });
}
