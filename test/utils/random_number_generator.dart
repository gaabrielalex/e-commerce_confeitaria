import 'dart:math';

class RandomNumberGenerator {
  static final _random = Random();

  // Gera um número inteiro aleatório dentro de um intervalo
  static int generateInt({int min = 0, required int max}) {
    return min + _random.nextInt(max - min + 1);
  }

  // Gera um número double aleatório dentro de um intervalo
  static double generateDouble({double min = 0.0, required double max}) {
    return min + _random.nextDouble() * (max - min);
  }

  // Gera um número aleatório com um comprimento específico em dígitos
  static String generateDigitString(int length) {
    return List.generate(length, (_) => _random.nextInt(10).toString()).join();
  }

  //Gera uma lista de números num intervalo especificado
   static List<int> generateIntList({int length = 10, int min = 0, int max = 10}) {
    return List.generate(length, (_) => generateInt(min: min, max: max));
  }
}