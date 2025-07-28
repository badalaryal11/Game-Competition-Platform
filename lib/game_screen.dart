import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const platform = MethodChannel('com.yourdomain.yourapp/unity');
  bool _isUnityVisible = false;

  Future<void> _loadUnityScene(String sceneName) async {
    try {
      await platform.invokeMethod('loadScene', {'sceneName': sceneName});
      setState(() {
        _isUnityVisible = true;
      });
    } on PlatformException catch (e) {
      print("Failed to load scene: '${e.message}'.");
    }
  }

  Future<void> _unloadUnityScene() async {
    try {
      await platform.invokeMethod('unloadScene');
      setState(() {
        _isUnityVisible = false;
      });
    } on PlatformException catch (e) {
      print("Failed to unload scene: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUnityVisible ? 'Now Playing' : 'Game Lobby'),
        backgroundColor: const Color(0xFF004D40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isUnityVisible) {
              _unloadUnityScene();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: Column(
        children: [
          if (!_isUnityVisible)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Select a Game',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 30),
                    _buildGameButton(
                      'Carrom Singleplayer',
                      'CarromSingleplayerScene',
                    ),
                    const SizedBox(height: 20),
                    _buildGameButton(
                      'Carrom Multiplayer',
                      'CarromMultiplayerScene',
                    ),
                    const SizedBox(height: 20),
                    _buildGameButton('Trial App', 'TrialAppScene'),
                  ],
                ),
              ),
            ),
          if (_isUnityVisible) Expanded(child: _buildUnityWidget()),
        ],
      ),
    );
  }

  Widget _buildGameButton(String title, String sceneName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD81B60),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: () => _loadUnityScene(sceneName),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildUnityWidget() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const AndroidView(viewType: 'UnityView');
    } else {
      return const Center(
        child: Text(
          'Unity is only available on Android in this demo.',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
