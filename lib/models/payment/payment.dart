
class Payment {
  String? id;
  PaymentMethod? paymentMethod;
  double? paymentAmount;
  DateTime? paymentDateTime;

  Payment({
    this.id,
    this.paymentMethod,
    this.paymentAmount,
    this.paymentDateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "paymentMethod": paymentMethod?.name,
      "paymentAmount": paymentAmount,
      "paymentDateTime": paymentDateTime,
    };
  }

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentMethod = PaymentMethod.values.firstWhere(
      (e) => e.name == json['paymentMethod'],
      orElse: () => PaymentMethod.pix,
    );
    paymentAmount = json['paymentAmount']?.toDouble() ?? 0.0;
    paymentDateTime = json['paymentDateTime']?.toDate();
  }

  Payment.fromMap(Map<String, dynamic> map) {
    paymentMethod = PaymentMethod.values.firstWhere(
      (e) => e.name == map['paymentMethod'],
      orElse: () => PaymentMethod.pix,
    );
    paymentAmount = map['paymentAmount'];
    paymentDateTime = map['paymentDateTime'];
  }
}

enum PaymentMethod {
  pix("Pix"),
  creditCard("Cartão de crédito"),
  debitCard("Cartão de débito"),
  money("Dinheiro");

  final String _name;

  const PaymentMethod(this._name);

  String get name => _name;

  static List<String> getNames() {
    return PaymentMethod.values.map((e) => e._name).toList();
  }
}