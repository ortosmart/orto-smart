import 'route_write_availability.dart';

/// Owns the shared write availability of a planning navigation flow.
///
/// Closing the originating route permanently revokes write availability.
/// Disposal is deferred until all retained route references are released.
class PlanningRouteLifetime {
  final RouteWriteAvailability availability;

  int _references = 1;
  bool _isClosed = false;

  PlanningRouteLifetime({required this.availability});

  bool get isClosed => _isClosed;

  /// Retains the availability for a dependent route.
  ///
  /// The returned callback releases this reference at most once.
  void Function() retain() {
    if (_isClosed) {
      throw StateError('The planning route lifetime is closed.');
    }

    _references++;
    var released = false;

    return () {
      if (released) {
        return;
      }

      released = true;
      _release();
    };
  }

  /// Revokes write availability and releases the originating reference.
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;

    try {
      availability.invalidate();
    } finally {
      _release();
    }
  }

  void _release() {
    _references--;

    if (_references == 0) {
      availability.dispose();
    }
  }
}
