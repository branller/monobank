import 'game_state.dart';

/// Pure banking operations on [GameState].
/// Each method returns a new [GameState] or a [String] error.
class BankingService {
  const BankingService();

  /// Credit [amount] from the bank to the player at [playerIndex].
  ({GameState? state, String? error}) creditPlayer({
    required GameState game,
    required int playerIndex,
    required int amount,
  }) {
    final error = _validateAmount(amount);
    if (error != null) return (state: null, error: error);
    if (playerIndex < 0 || playerIndex >= game.players.length) {
      return (state: null, error: 'Jugador inválido.');
    }

    final player = game.players[playerIndex];
    final updated = List<PlayerState>.of(game.players);
    updated[playerIndex] = player.copyWith(balance: player.balance + amount);

    return (
      state: GameState(players: updated, freeParking: game.freeParking),
      error: null,
    );
  }

  /// Charge [amount] from the player at [playerIndex] into Parada Libre.
  ({GameState? state, String? error}) chargeToFreeParking({
    required GameState game,
    required int playerIndex,
    required int amount,
  }) {
    final error = _validateAmount(amount);
    if (error != null) return (state: null, error: error);
    if (playerIndex < 0 || playerIndex >= game.players.length) {
      return (state: null, error: 'Jugador inválido.');
    }

    final player = game.players[playerIndex];
    if (player.balance < amount) {
      return (state: null, error: 'Saldo insuficiente.');
    }

    final updated = List<PlayerState>.of(game.players);
    updated[playerIndex] = player.copyWith(balance: player.balance - amount);

    return (
      state: GameState(
        players: updated,
        freeParking: game.freeParking + amount,
      ),
      error: null,
    );
  }

  /// Award the entire Parada Libre pot to the player at [playerIndex].
  ({GameState? state, String? error}) awardFreeParking({
    required GameState game,
    required int playerIndex,
  }) {
    if (game.freeParking <= 0) {
      return (state: null, error: 'El pozo de Parada Libre está vacío.');
    }
    if (playerIndex < 0 || playerIndex >= game.players.length) {
      return (state: null, error: 'Jugador inválido.');
    }

    final player = game.players[playerIndex];
    final updated = List<PlayerState>.of(game.players);
    updated[playerIndex] = player.copyWith(
      balance: player.balance + game.freeParking,
    );

    return (
      state: GameState(players: updated, freeParking: 0),
      error: null,
    );
  }

  String? _validateAmount(int amount) {
    if (amount <= 0) return 'El monto debe ser mayor a cero.';
    return null;
  }
}
