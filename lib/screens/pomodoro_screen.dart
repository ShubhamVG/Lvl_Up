import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Duration _duration = const Duration(minutes: 25);
  late final Ticker _ticker;
  late DateTime _endTime;
  bool _running = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  void _startTimer() {
    setState(() {
      _endTime = DateTime.now().add(_duration);
      _running = true;
      _completed = false;
    });
    _ticker.start();
  }

  void _pauseTimer() {
    _ticker.stop();
    setState(() => _running = false);
  }

  void _resumeTimer() {
    _endTime = DateTime.now().add(_duration);
    _ticker.start();
    setState(() => _running = true);
  }

  void _resetTimer() {
    _ticker.stop();
    setState(() {
      _duration = const Duration(minutes: 25);
      _running = false;
      _completed = false;
    });
  }

  void _onTick(Duration elapsed) {
    final remaining = _endTime.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _ticker.stop();
      setState(() {
        _running = false;
        _duration = Duration.zero;
        _completed = true;
      });
    } else {
      setState(() {
        _duration = remaining;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pomodoro Timer"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDuration(_duration),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_running)
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    child: const Text("Pause"),
                  )
                else if (!_completed && _duration.inSeconds != 1500)
                  ElevatedButton(
                    onPressed: _resumeTimer,
                    child: const Text("Resume"),
                  )
                else if (!_running && !_completed)
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text("Start Pomodoro"),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text("Reset"),
                ),
              ],
            ),
            if (_completed)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Pomodoro Complete!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  late final VoidCallback _tick;

  Ticker(this.onTick) {
    _stopwatch = Stopwatch();
    _interval = const Duration(seconds: 1);
    _tick = () {
      if (_stopwatch.isRunning) {
        onTick(_stopwatch.elapsed);
        Future.delayed(_interval, _tick);
      }
    };
  }

  void start() {
    _stopwatch.start();
    _tick();
  }

  void stop() {
    _stopwatch.stop();
  }

  void dispose() {
    _stopwatch.stop();
  }
}

class TickerFuture {}
