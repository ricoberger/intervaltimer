import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:intervaltimer/timers_add.dart';
import 'package:intervaltimer/timers_details.dart';
import 'package:intervaltimer/timers_repository.dart' as tr;

class TimersList extends StatefulWidget {
  const TimersList({super.key});

  @override
  State<TimersList> createState() => _TimersListState();
}

class _TimersListState extends State<TimersList> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<tr.TimersRepository>(context, listen: false)
          .init()
          .then((_) => FlutterNativeSplash.remove());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tr.TimersRepository timers = Provider.of<tr.TimersRepository>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Timers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const TimersAdd();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timers.timers.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Positioned.fill(
                      child: Builder(
                        builder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[900]!,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Slidable(
                      key: UniqueKey(),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.3 * 2,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return TimersAdd(
                                      existingTimerIndex: index,
                                      existingTimer: timers.timers[index],
                                    );
                                  },
                                ),
                              );
                            },
                            backgroundColor: Colors.blue[900]!,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            icon: Icons.edit,
                            label: 'Edit',
                            borderRadius: BorderRadius.zero,
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              timers.deleteTimer(index);
                            },
                            backgroundColor: Colors.red[900]!,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4.0),
                              bottomRight: Radius.circular(4.0),
                            ),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return TimersDetails(
                                  timer: timers.timers[index],
                                );
                              },
                            ),
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: const Color(0xff1b2738),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timers.timers[index].name,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${tr.printDuration(Duration(seconds: timers.timers[index].intervals.map((e) => e.seconds).reduce((a, b) => a + b)))} (${timers.timers[index].intervals.length} ${timers.timers[index].intervals.length == 1 ? 'Interval' : 'Intervals'})',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
