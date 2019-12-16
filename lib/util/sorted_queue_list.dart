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

  /*
  void animatedSelectionSort(Widget displayWidget) async {
    AnimatedListState state = key.currentState;
    for (int i = 0; i < length; i++) {
      int minIndex = i;
      for (int j = i + 1; j < length; j++) {
        if (Comparable.compare(this[j], this[minIndex]) < 0) {
          minIndex = j;
        }
      }
      if (i != minIndex) {
        TrackQueueItem temp = this[i];
        state.removeItem(
            minIndex, (context, animation) => _buildItem(animation, displayWidget, minIndex), duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        state.removeItem(i, (context, animation) => _buildItem(animation, displayWidget, i), duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        this[i] = this[minIndex];
        this[minIndex] = temp;
        state.insertItem(i, duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        state.insertItem(minIndex, duration: Duration(seconds: 1));
      }
    }
  }

  Widget _buildItem(Animation animation, Widget displayWidget, int index) {
    return FadeTransition(
      opacity: animation,
      child: displayWidget,
    );
  }
   */
}
