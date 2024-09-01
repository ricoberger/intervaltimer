import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:intervaltimer/timers_repository.dart' as tr;
import 'package:wakelock_plus/wakelock_plus.dart';

class TimersDetails extends StatefulWidget {
  const TimersDetails({
    super.key,
    required this.timer,
  });

  final tr.Timer timer;

  @override
  State<TimersDetails> createState() => _TimersDetailsState();
}

class _TimersDetailsState extends State<TimersDetails> {
  late AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  int _intervalIndex = 0;
  int _seconds = 0;

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_seconds == 0) {
          _player.play(AssetSource('sounds/alarm.wav'));

          if (_intervalIndex == widget.timer.intervals.length - 1) {
            timer.cancel();
            return;
          } else {
            setState(() {
              _intervalIndex++;
              _seconds = widget.timer.intervals[_intervalIndex].seconds;
              timer.cancel();
            });

            _startTimer();
          }
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  Widget _buildTimer() {
    if (_timer == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1b2738),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        onPressed: _startTimer,
        child: Text(
          'Start',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tr.printDuration(Duration(seconds: _seconds)),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.timer.intervals[_intervalIndex].name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
    _player = AudioPlayer();
    _seconds = widget.timer.intervals[_intervalIndex].seconds;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _player.dispose();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.timer.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Center(
                    child: _buildTimer(),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.timer.intervals.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: const Color(0xff1b2738),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.timer.intervals[index].name,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                tr.printDuration(
                                  Duration(
                                    seconds:
                                        widget.timer.intervals[index].seconds,
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
