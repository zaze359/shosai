import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class ReadEvent {
  int chapterIndex;

  ReadEvent(this.chapterIndex);
}
