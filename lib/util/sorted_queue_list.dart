import 'package:collection/collection.dart';

class SortedQueueList<E> extends QueueList<E> {
  @override
  void add(element) {
    super.add(element);
    sort();
  }

  @override
  E removeFirst() {
    E result = super.removeFirst();
    sort();
    return result;
  }
}
