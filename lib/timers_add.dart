import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:provider/provider.dart';

import 'package:intervaltimer/timers_list.dart';
import 'package:intervaltimer/timers_repository.dart' as tr;

class TimersAdd extends StatefulWidget {
  const TimersAdd({
    super.key,
    this.existingTimerIndex,
    this.existingTimer,
  });

  final int? existingTimerIndex;
  final tr.Timer? existingTimer;

  @override
  State<TimersAdd> createState() => _TimersAddState();
}

class _TimersAddState extends State<TimersAdd> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  List<tr.Interval> _intervals = [];
  bool _isLoading = false;

  String? _validatorRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _validatorNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      return 'The field must be a number';
    }

    if (parsedValue <= 0) {
      return 'This field must be greater than 0';
    }

    return null;
  }

  Future<void> _saveTimer() async {
    try {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        if (widget.existingTimerIndex != null) {
          setState(() {
            _isLoading = true;
          });

          await Provider.of<tr.TimersRepository>(
            context,
            listen: false,
          ).editTimer(
            widget.existingTimerIndex!,
            tr.Timer(
              id: widget.existingTimer!.id,
              name: _name.text,
              intervals: _intervals,
            ),
          );
        } else {
          await Provider.of<tr.TimersRepository>(
            context,
            listen: false,
          ).addTimer(
            tr.Timer(
              id: const Uuid().v4(),
              name: _name.text,
              intervals: _intervals,
            ),
          );
        }

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const TimersList();
              },
            ),
            (route) => false,
          );
        }
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });

      // ignore: avoid_print
      print('Failed to save timer ${err.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();

    _name.text = widget.existingTimer?.name ?? '';
    _intervals = widget.existingTimer?.intervals ?? [];
  }

  @override
  void dispose() {
    _name.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: widget.existingTimerIndex != null
            ? const Text('Edit Timer')
            : const Text('Add Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _intervals.add(
                  tr.Interval(
                    id: const Uuid().v4(),
                    name: '',
                    seconds: 0,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    color: const Color(0xff1b2738),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            enableSuggestions: false,
                            maxLines: 1,
                            validator: _validatorRequired,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            cursorColor:
                                Theme.of(context).colorScheme.onPrimary,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              labelText: 'Timer Name',
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(
                    _intervals.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: const Color(0xff1b2738),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(
                                      'name${_intervals[index].id}',
                                    ),
                                    initialValue: _intervals[index].name,
                                    onChanged: (value) {
                                      setState(() {
                                        _intervals[index].name = value;
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    maxLines: 1,
                                    validator: _validatorRequired,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    cursorColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      labelText: 'Interval Name',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    key: ValueKey(
                                      'seconds${_intervals[index].id}',
                                    ),
                                    initialValue:
                                        _intervals[index].seconds.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        _intervals[index].seconds =
                                            int.parse(value);
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    maxLines: 1,
                                    validator: _validatorNumber,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    cursorColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      labelText: 'Duration',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      suffixText: 'Seconds',
                                      suffixStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: index == 0
                                            ? null
                                            : () {
                                                final intervals = _intervals;
                                                final tmp = intervals[index];
                                                intervals[index] =
                                                    intervals[index - 1];
                                                intervals[index - 1] = tmp;

                                                setState(() {
                                                  _intervals = intervals;
                                                });
                                              },
                                        icon: const Icon(Icons.arrow_upward),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _intervals.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                      IconButton(
                                        onPressed: index ==
                                                _intervals.length - 1
                                            ? null
                                            : () {
                                                final intervals = _intervals;
                                                final tmp = intervals[index];
                                                intervals[index] =
                                                    intervals[index + 1];
                                                intervals[index + 1] = tmp;

                                                setState(() {
                                                  _intervals = intervals;
                                                });
                                              },
                                        icon: const Icon(Icons.arrow_downward),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1b2738),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                    onPressed: _isLoading ? null : _saveTimer,
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            'Save Timer',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
