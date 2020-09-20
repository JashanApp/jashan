import 'package:collection/collection.dart';

class JashanQueueList<E> extends QueueList<E> {
  final int cap;

  JashanQueueList({this.cap});

  @override
  void add(E element) {
    if (cap != null && length + 1 > cap) {
      super.removeFirst();
    }
    super.add(element);
  }

  @override
  String toString() {
    if (length == 0) {
      return "[]";
    }
    String result = "[";
    forEach((item) {
      result += "\"${item.toString()}\", ";
    });
    result = result.substring(0, result.length - 2);
    return "$result]";
  }
}
