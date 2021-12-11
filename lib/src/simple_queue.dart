import 'dart:async';

class SimpleMicroTask {
  int _version = 0;
  int _microTask = 0;

  int get microTask => _microTask;

  int get version => _version;

  void exec(Function callback) {
    if (_microTask == _version) {
      _microTask++;
      scheduleMicrotask(() {
        _version++;
        _microTask = _version;
        callback();
      });
    }
  }
}

class SimpleQueue {
  final List<_Item> _queue = <_Item>[];
  bool _active = false;

  Future<T> add<T>(Function job) {
    Completer<T> completer = Completer<T>();
    _queue.add(_Item(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    _queue.clear();
  }

  void _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      _Item item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } on Exception catch (e) {
        item.completer.completeError(e);
      }
      _active = false;
      _check();
    }
  }
}

class _Item {
  _Item(
    this.completer,
    this.job,
  );

  final dynamic completer;
  final dynamic job;
}
