import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

String printDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return '$negativeSign${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds';
}

class Timer {
  String id;
  String name;
  List<Interval> intervals;

  Timer({
    required this.id,
    required this.name,
    required this.intervals,
  });

  factory Timer.fromJson(Map<String, dynamic> data) {
    return Timer(
      id: data['id'],
      name: data['name'],
      intervals: data.containsKey('intervals') && data['intervals'] != null
          ? List<Interval>.from(
              data['intervals'].map((v) => Interval.fromJson(v)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'intervals': intervals.map((e) => e.toJson()).toList(),
    };
  }
}

class Interval {
  String id;
  String name;
  int seconds;

  Interval({
    required this.id,
    required this.name,
    required this.seconds,
  });

  factory Interval.fromJson(Map<String, dynamic> data) {
    return Interval(
      id: data['id'],
      name: data['name'],
      seconds: data['seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seconds': seconds,
    };
  }
}

class TimersRepository with ChangeNotifier {
  List<Timer> _timers = [];

  List<Timer> get timers => _timers;

  Future<void> init() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? timers = prefs.getString('timers');
      if (timers != null) {
        _timers =
            List<Timer>.from(json.decode(timers).map((v) => Timer.fromJson(v)));
      }
      notifyListeners();
    } catch (err) {
      // ignore: avoid_print
      print('Failed to read timers ${err.toString()}');
    }
  }

  Future<void> _save() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'timers',
        json.encode(_timers.map((e) => e.toJson()).toList()),
      );
    } catch (err) {
      // ignore: avoid_print
      print('Failed to write timers ${err.toString()}');
    }
  }

  Future<void> addTimer(Timer timer) async {
    _timers.add(timer);
    await _save();
    notifyListeners();
  }

  Future<void> editTimer(int index, Timer timer) async {
    _timers[index] = timer;
    await _save();
    notifyListeners();
  }

  Future<void> deleteTimer(int index) async {
    _timers.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> reorder(int start, int current) async {
    if (start < current) {
      int end = current - 1;
      Timer startItem = _timers[start];
      int i = 0;
      int local = start;
      do {
        _timers[local] = _timers[++local];
        i++;
      } while (i < end - start);
      _timers[end] = startItem;
    } else if (start > current) {
      Timer startItem = _timers[start];
      for (int i = start; i > current; i--) {
        _timers[i] = _timers[i - 1];
      }
      _timers[current] = startItem;
    }

    await _save();
    notifyListeners();
  }
}
