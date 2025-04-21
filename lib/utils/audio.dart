import 'package:audioplayers/audioplayers.dart';

Future<void> playJingle() async {
  final player = AudioPlayer();
  await player.play(AssetSource('jingle.mp3'));
}
