import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/banking_service.dart';
import '../domain/game_state.dart';

/// Main game screen showing balances and banking operations.
class GameScreen extends StatefulWidget {
  final GameState game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _banking = BankingService();
  late GameState _game;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  void _applyResult(({GameState? state, String? error}) result) {
    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    setState(() => _game = result.state!);
  }

  // --- dialogs ---

  void _showCreditDialog() {
    _showOperationSheet(
      title: 'Abonar al jugador',
      needsAmount: true,
      confirmLabel: 'Abonar',
      onConfirm: (playerIndex, amount) {
        _applyResult(_banking.creditPlayer(
          game: _game,
          playerIndex: playerIndex,
          amount: amount,
        ));
      },
    );
  }

  void _showChargeDialog() {
    _showOperationSheet(
      title: 'Cobrar a Parada Libre',
      needsAmount: true,
      confirmLabel: 'Cobrar',
      onConfirm: (playerIndex, amount) {
        _applyResult(_banking.chargeToFreeParking(
          game: _game,
          playerIndex: playerIndex,
          amount: amount,
        ));
      },
    );
  }

  void _showAwardDialog() {
    if (_game.freeParking <= 0) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('El pozo de Parada Libre está vacío.'),
          ),
        );
      return;
    }
    _showOperationSheet(
      title: 'Entregar Parada Libre',
      subtitle: 'Pozo actual: M ${_game.freeParking}',
      needsAmount: false,
      confirmLabel: 'Entregar',
      onConfirm: (playerIndex, _) {
        _applyResult(_banking.awardFreeParking(
          game: _game,
          playerIndex: playerIndex,
        ));
      },
    );
  }

  void _showOperationSheet({
    required String title,
    String? subtitle,
    required bool needsAmount,
    required String confirmLabel,
    required void Function(int playerIndex, int amount) onConfirm,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OperationSheet(
        players: _game.players,
        title: title,
        subtitle: subtitle,
        needsAmount: needsAmount,
        confirmLabel: confirmLabel,
        onConfirm: (playerIndex, amount) {
          Navigator.of(context).pop();
          onConfirm(playerIndex, amount);
        },
      ),
    );
  }

  // --- build ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MonoBank'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // Human players
                  ..._game.players.map((p) => _PlayerTile(player: p)),

                  const SizedBox(height: 16),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),

                  // Parada Libre
                  _FreeParkingTile(balance: _game.freeParking),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: 'Abonar',
                      onTap: _showCreditDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.local_parking_rounded,
                      label: 'Cobrar',
                      onTap: _showChargeDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Entregar',
                      onTap: _showAwardDialog,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiles
// ---------------------------------------------------------------------------

class _PlayerTile extends StatelessWidget {
  final PlayerState player;
  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'M ${player.balance}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeParkingTile extends StatelessWidget {
  final int balance;
  const _FreeParkingTile({required this.balance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_parking_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Parada Libre',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'M $balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet for operations
// ---------------------------------------------------------------------------

class _OperationSheet extends StatefulWidget {
  final List<PlayerState> players;
  final String title;
  final String? subtitle;
  final bool needsAmount;
  final String confirmLabel;
  final void Function(int playerIndex, int amount) onConfirm;

  const _OperationSheet({
    required this.players,
    required this.title,
    this.subtitle,
    required this.needsAmount,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  State<_OperationSheet> createState() => _OperationSheetState();
}

class _OperationSheetState extends State<_OperationSheet> {
  int? _selectedIndex;
  final _amountController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_selectedIndex == null) return 'Selecciona un jugador.';
    if (widget.needsAmount) {
      final amount = int.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        return 'Ingresa un monto mayor a cero.';
      }
    }
    return null;
  }

  void _onConfirm() {
    if (_submitted) return;
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _submitted = true;
    final amount = widget.needsAmount
        ? int.parse(_amountController.text.trim())
        : 0;
    widget.onConfirm(_selectedIndex!, amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Amount field
          if (widget.needsAmount) ...[
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                prefixText: 'M ',
                prefixStyle: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                hintText: '0',
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Player selector
          Text(
            'Selecciona jugador',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(widget.players.length, (i) {
            final player = widget.players[i];
            final selected = _selectedIndex == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: colorScheme.primary, width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: player.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        player.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      'M ${player.balance}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Confirm
          FilledButton(
            onPressed: _onConfirm,
            child: Text(widget.confirmLabel),
          ),
        ],
      ),
    );
  }
}
