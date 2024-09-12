import 'package:uuid/uuid.dart';

class BooleanController {
  final String id;
  bool _value = false;
  Function(BooleanController, bool)? onSetValue;

  BooleanController({this.onSetValue}) : id = const Uuid().v4();

  bool get value => _value;

  void toggle() {
    _setValue(!_value);
  }

  void set(bool value) {
    _setValue(value);
  }

  void _setValue(bool value) {
    if (onSetValue != null) {
      onSetValue!(this, value);
    }
    _value = value;
  }
}
