import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'theme_notifier.dart';
import 'package:flutter/cupertino.dart';



final themeNotifier = ThemeNotifier();


void main() {
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MyApp(themeMode: currentTheme); // 👈 pass the current theme
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // ✅ Declare isDark here

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFlow - Pomodoro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: 'Toggle Theme',
            onPressed: () {
              themeNotifier.value =
              isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: const PomodoroBody(),
    );
  }

}


class PomodoroBody extends StatefulWidget {
  const PomodoroBody({super.key});

  @override
  State<PomodoroBody> createState() => _PomodoroBodyState();
}

enum TimerMode { focus, breakTime }

TimerMode _currentMode = TimerMode.focus;

class _PomodoroBodyState extends State<PomodoroBody> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _focusDuration = 1500; // default 25 min
  int _breakDuration = 300;  // default 5 min

  int _focusMinutes = 10;
  int _focusSeconds = 0;
  int _breakMinutes = 5;
  int _breakSeconds = 0;



  @override
  void initState() {
    super.initState();
    _remainingSeconds = _focusDuration;
  }



  double get _progress {
    final total = _currentMode == TimerMode.focus ? _focusDuration : _breakDuration;
    return 1 - (_remainingSeconds / total);
  }


  late int _remainingSeconds;

  TimerMode _currentMode = TimerMode.focus;
  bool _isRunning = false;
  Timer? _timer;

  void _showDurationPicker({
    required BuildContext context,
    required Duration initialDuration,
    required void Function(Duration) onDurationSelected,
  }) {
    Duration tempDuration = initialDuration;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          contentPadding: const EdgeInsets.all(8),
          content: SizedBox(
            height: 200,
            width: 300,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hms,
              initialTimerDuration: initialDuration,
              onTimerDurationChanged: (Duration newDuration) {
                tempDuration = newDuration;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDurationSelected(tempDuration);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }




  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _audioPlayer.play(AssetSource('positive-notif.wav'));

        setState(() {
          _isRunning = false;
          _currentMode = _currentMode == TimerMode.focus
              ? TimerMode.breakTime
              : TimerMode.focus;
          _remainingSeconds = _currentMode == TimerMode.focus
              ? _focusDuration
              : _breakDuration;
        });
        return;
      }


      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _showTimerPickerDialog({
    required Duration initialDuration,
    required Function(Duration) onDurationChanged,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          contentPadding: const EdgeInsets.all(16),
          content: SizedBox(
            height: 180,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hms,
              initialTimerDuration: initialDuration,
              onTimerDurationChanged: onDurationChanged,
            ),
          ),
        );
      },
    );
  }


  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _currentMode == TimerMode.focus
          ? _focusDuration
          : _breakDuration;
    });
  }

  void _switchMode() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentMode = _currentMode == TimerMode.focus
          ? TimerMode.breakTime
          : TimerMode.focus;
      _remainingSeconds = _currentMode == TimerMode.focus
          ? _focusDuration
          : _breakDuration;
    });
  }


  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentMode == TimerMode.focus ? 'Focus Mode' : 'Break Time',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CircularProgressIndicator(
                      value: 1 - value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentMode == TimerMode.focus ? Colors.deepPurple : Colors.teal,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showDurationPicker(
                        context: context,
                        initialDuration: Duration(
                          seconds: _currentMode == TimerMode.focus ? _focusDuration : _breakDuration,
                        ),
                        onDurationSelected: (duration) {
                          setState(() {
                            if (_currentMode == TimerMode.focus) {
                              _focusDuration = duration.inSeconds;
                              _remainingSeconds = _focusDuration;
                            } else {
                              _breakDuration = duration.inSeconds;
                              _remainingSeconds = _breakDuration;
                            }
                          });
                        },
                      );
                    },

                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),


                ],
              );
            },
          ),

          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _startTimer,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Start"),
              ),
              ElevatedButton.icon(
                onPressed: _pauseTimer,
                icon: const Icon(Icons.pause),
                label: const Text("Pause"),
              ),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.restart_alt),
                label: const Text("Reset"),
              ),
              ElevatedButton.icon(
                onPressed: _switchMode,
                icon: const Icon(Icons.swap_horiz),
                label: const Text("Switch Mode"),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              '"u i i a e u u i a i (motivational quote plceholder)."',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
