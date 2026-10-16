import 'package:flutter/material.dart';

/// Available player colors.
const List<Color> kPlayerColors = [
  Color(0xFFE53935), // red
  Color(0xFF1E88E5), // blue
  Color(0xFF43A047), // green
  Color(0xFFFDD835), // yellow
  Color(0xFF8E24AA), // purple
  Color(0xFFFF6D00), // orange
  Color(0xFF00ACC1), // cyan
  Color(0xFFD81B60), // pink
];

/// Default Spanish player names.
const List<String> kDefaultPlayerNames = [
  'Jugador 1',
  'Jugador 2',
  'Jugador 3',
  'Jugador 4',
  'Jugador 5',
  'Jugador 6',
  'Jugador 7',
  'Jugador 8',
];

/// A single player in a game.
class PlayerState {
  final String name;
  final Color color;
  final int balance;

  const PlayerState({
    required this.name,
    required this.color,
    required this.balance,
  });

  PlayerState copyWith({String? name, Color? color, int? balance}) {
    return PlayerState(
      name: name ?? this.name,
      color: color ?? this.color,
      balance: balance ?? this.balance,
    );
  }
}

/// The complete in-memory game state.
class GameState {
  final List<PlayerState> players;
  final int freeParking;

  const GameState({
    required this.players,
    this.freeParking = 0,
  });
}
