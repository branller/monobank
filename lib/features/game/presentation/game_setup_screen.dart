import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/game_state.dart';
import 'game_screen.dart';

/// Screen to configure a new game: players, colors, and starting balance.
class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  static const _minPlayers = 2;
  static const _maxPlayers = 8;
  static const _defaultBalance = 1500;

  late final TextEditingController _balanceController;
  late List<_PlayerEntry> _entries;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController(
      text: _defaultBalance.toString(),
    );
    _entries = List.generate(_minPlayers, _createEntry);
  }

  _PlayerEntry _createEntry(int index) {
    return _PlayerEntry(
      nameController: TextEditingController(text: kDefaultPlayerNames[index]),
      color: kPlayerColors[index],
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    for (final e in _entries) {
      e.nameController.dispose();
    }
    super.dispose();
  }

  Set<Color> get _usedColors => _entries.map((e) => e.color).toSet();

  // --- mutations ---

  void _addPlayer() {
    if (_entries.length >= _maxPlayers) return;
    final index = _entries.length;
    final available = kPlayerColors
        .where((c) => !_usedColors.contains(c))
        .toList();
    setState(() {
      _entries.add(
        _PlayerEntry(
          nameController: TextEditingController(
            text: kDefaultPlayerNames[index],
          ),
          color: available.isNotEmpty ? available.first : kPlayerColors[index],
        ),
      );
    });
  }

  void _removePlayer(int index) {
    if (_entries.length <= _minPlayers) return;
    setState(() {
      _entries[index].nameController.dispose();
      _entries.removeAt(index);
    });
  }

  void _changeColor(int index, Color color) {
    setState(() => _entries[index].color = color);
  }

  // --- validation ---

  String? _validate() {
    for (var i = 0; i < _entries.length; i++) {
      final name = _entries[i].nameController.text.trim();
      if (name.isEmpty) return 'El jugador ${i + 1} necesita un nombre.';
    }

    final names = _entries
        .map((e) => e.nameController.text.trim().toLowerCase())
        .toList();
    if (names.toSet().length != names.length) {
      return 'Los nombres de jugadores deben ser únicos.';
    }

    final balance = int.tryParse(_balanceController.text.trim());
    if (balance == null || balance < 0) {
      return 'El saldo inicial debe ser un número válido ≥ 0.';
    }

    return null;
  }

  void _confirm() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final balance = int.parse(_balanceController.text.trim());
    final players = _entries
        .map(
          (e) => PlayerState(
            name: e.nameController.text.trim(),
            color: e.color,
            balance: balance,
          ),
        )
        .toList();

    final game = GameState(players: players, freeParking: 0);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(game: game)),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva partida'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // Starting balance
                  _SectionLabel(text: 'Saldo inicial por jugador'),
                  const SizedBox(height: 8),
                  _BalanceField(controller: _balanceController),
                  const SizedBox(height: 24),

                  // Players header
                  Row(
                    children: [
                      _SectionLabel(
                        text: 'Jugadores (${_entries.length}/$_maxPlayers)',
                      ),
                      const Spacer(),
                      if (_entries.length < _maxPlayers)
                        TextButton.icon(
                          onPressed: _addPlayer,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Agregar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Player cards
                  ...List.generate(_entries.length, (i) {
                    return _PlayerCard(
                      key: ValueKey(i),
                      entry: _entries[i],
                      index: i,
                      usedColors: _usedColors,
                      canRemove: _entries.length > _minPlayers,
                      onRemove: () => _removePlayer(i),
                      onColorChanged: (c) => _changeColor(i, c),
                    );
                  }),
                ],
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: _confirm,
                child: const Text('Crear partida'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _PlayerEntry {
  final TextEditingController nameController;
  Color color;

  _PlayerEntry({required this.nameController, required this.color});
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BalanceField extends StatelessWidget {
  final TextEditingController controller;
  const _BalanceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        prefixText: 'M ',
        prefixStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
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
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final _PlayerEntry entry;
  final int index;
  final Set<Color> usedColors;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<Color> onColorChanged;

  const _PlayerCard({
    super.key,
    required this.entry,
    required this.index,
    required this.usedColors,
    required this.canRemove,
    required this.onRemove,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field + remove button
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: entry.nameController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Nombre del jugador',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Eliminar jugador',
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Color palette
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kPlayerColors.map((color) {
              final isSelected = entry.color == color;
              final isUsedByOther = usedColors.contains(color) && !isSelected;

              return GestureDetector(
                onTap: isUsedByOther ? null : () => onColorChanged(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUsedByOther
                        ? color.withValues(alpha: 0.25)
                        : color,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : isUsedByOther
                      ? Icon(
                          Icons.block_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
