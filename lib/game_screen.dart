import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const platform = MethodChannel('com.saransa');
  bool _isUnityVisible = false;

  Future<void> _loadUnityScene(String sceneName) async {
    try {
      await platform.invokeMethod('loadScene', {'sceneName': sceneName});
      setState(() {
        _isUnityVisible = true;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to load scene: '${e.message}'.");
    }
  }

  Future<void> _unloadUnityScene() async {
    try {
      await platform.invokeMethod('unloadScene');
      setState(() {
        _isUnityVisible = false;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to unload scene: '${e.message}'.");
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
              // Standard back navigation if needed, or leave empty if sign out is the only exit
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 30),
            tooltip: 'Sign Out',
            onPressed: () {
              // Sign out logic
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isUnityVisible)
            Expanded(
              child: SingleChildScrollView(
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
                      _buildGameTile(
                        'Carrom Singleplayer',
                        'CarromSingleplayerScene',
                        'assets/images/carrom_singleplayer.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildGameTile(
                        'Carrom Multiplayer',
                        'CarromMultiplayerScene',
                        'assets/images/carrom_multiplayer.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildGameTile(
                        'Hero Trial',
                        'TrialAppScene',
                        'assets/images/hero_trial.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildGameTile(
                        'Chess',
                        'ChessScene',
                        'assets/images/chess_game.jpg',
                      ),
                      const SizedBox(height: 20),
                      _buildGameTile(
                        'Fast Ludo',
                        'LudoScene',
                        'assets/images/fast_ludo.jpg',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          if (_isUnityVisible) Expanded(child: _buildUnityWidget()),
        ],
      ),
    );
  }

  Widget _buildGameTile(String title, String sceneName, String imagePath) {
    return GestureDetector(
      onTap: () => _loadUnityScene(sceneName),
      child: Container(
        height: 180,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
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
