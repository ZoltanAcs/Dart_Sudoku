import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const SudokuHomePage(),
    );
  }
}

class SudokuHomePage extends StatefulWidget {
  const SudokuHomePage({super.key});

  @override
  State<SudokuHomePage> createState() => _SudokuHomePageState();
}

class _SudokuHomePageState extends State<SudokuHomePage> {
  final Random _random = Random();
  final FocusNode _keyboardFocusNode = FocusNode();

  late List<List<int>> _solution;
  late List<List<int>> _board;
  late List<List<bool>> _fixed;
  late List<List<Set<int>>> _notes;

  int? selectedRow;
  int? selectedCol;

  bool notesMode = false;
  bool paused = false;
  bool completed = false;
  bool gameStarted = false;

  int secondsElapsed = 0;
  int mistakes = 0;
  int hintsUsed = 0;
  String difficulty = 'Easy';

  Timer? _timer;

  final List<Move> _history = [];

  final Map<String, List<SudokuPuzzle>> puzzleBank = {
    'Easy': [
      SudokuPuzzle(
        puzzle: [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9],
        ],
        solution: [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ],
      ),
      SudokuPuzzle(
        puzzle: [
          [0, 2, 0, 6, 0, 8, 0, 0, 0],
          [5, 8, 0, 0, 0, 9, 7, 0, 0],
          [0, 0, 0, 0, 4, 0, 0, 0, 0],
          [3, 7, 0, 0, 0, 0, 5, 0, 0],
          [6, 0, 0, 0, 0, 0, 0, 0, 4],
          [0, 0, 8, 0, 0, 0, 0, 1, 3],
          [0, 0, 0, 0, 2, 0, 0, 0, 0],
          [0, 0, 9, 8, 0, 0, 0, 3, 6],
          [0, 0, 0, 3, 0, 6, 0, 9, 0],
        ],
        solution: [
          [1, 2, 3, 6, 7, 8, 9, 4, 5],
          [5, 8, 4, 2, 3, 9, 7, 6, 1],
          [9, 6, 7, 1, 4, 5, 3, 2, 8],
          [3, 7, 2, 4, 6, 1, 5, 8, 9],
          [6, 9, 1, 5, 8, 3, 2, 7, 4],
          [4, 5, 8, 7, 9, 2, 6, 1, 3],
          [8, 3, 6, 9, 2, 4, 1, 5, 7],
          [2, 1, 9, 8, 5, 7, 4, 3, 6],
          [7, 4, 5, 3, 1, 6, 8, 9, 2],
        ],
      ),
    ],
    'Medium': [
      SudokuPuzzle(
        puzzle: [
          [0, 0, 0, 2, 6, 0, 7, 0, 1],
          [6, 8, 0, 0, 7, 0, 0, 9, 0],
          [1, 9, 0, 0, 0, 4, 5, 0, 0],
          [8, 2, 0, 1, 0, 0, 0, 4, 0],
          [0, 0, 4, 6, 0, 2, 9, 0, 0],
          [0, 5, 0, 0, 0, 3, 0, 2, 8],
          [0, 0, 9, 3, 0, 0, 0, 7, 4],
          [0, 4, 0, 0, 5, 0, 0, 3, 6],
          [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ],
        solution: [
          [4, 3, 5, 2, 6, 9, 7, 8, 1],
          [6, 8, 2, 5, 7, 1, 4, 9, 3],
          [1, 9, 7, 8, 3, 4, 5, 6, 2],
          [8, 2, 6, 1, 9, 5, 3, 4, 7],
          [3, 7, 4, 6, 8, 2, 9, 1, 5],
          [9, 5, 1, 7, 4, 3, 6, 2, 8],
          [5, 1, 9, 3, 2, 6, 8, 7, 4],
          [2, 4, 8, 9, 5, 7, 1, 3, 6],
          [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ],
      ),
    ],
    'Hard': [
      SudokuPuzzle(
        puzzle: [
          [8, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 3, 6, 0, 0, 0, 0, 0],
          [0, 7, 0, 0, 9, 0, 2, 0, 0],
          [0, 5, 0, 0, 0, 7, 0, 0, 0],
          [0, 0, 0, 0, 4, 5, 7, 0, 0],
          [0, 0, 0, 1, 0, 0, 0, 3, 0],
          [0, 0, 1, 0, 0, 0, 0, 6, 8],
          [0, 0, 8, 5, 0, 0, 0, 1, 0],
          [0, 9, 0, 0, 0, 0, 4, 0, 0],
        ],
        solution: [
          [8, 1, 2, 7, 5, 3, 6, 4, 9],
          [9, 4, 3, 6, 8, 2, 1, 7, 5],
          [6, 7, 5, 4, 9, 1, 2, 8, 3],
          [1, 5, 4, 2, 3, 7, 8, 9, 6],
          [3, 6, 9, 8, 4, 5, 7, 2, 1],
          [2, 8, 7, 1, 6, 9, 5, 3, 4],
          [5, 2, 1, 9, 7, 4, 3, 6, 8],
          [4, 3, 8, 5, 2, 6, 9, 1, 7],
          [7, 9, 6, 3, 1, 8, 4, 5, 2],
        ],
      ),
    ],
  };

  @override
  void dispose() {
    _timer?.cancel();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused && !completed && gameStarted) {
        setState(() {
          secondsElapsed++;
        });
      }
    });
  }

  void _startNewGame({String? newDifficulty}) {
    if (newDifficulty != null) {
      difficulty = newDifficulty;
    }

    final puzzles = puzzleBank[difficulty]!;
    final chosen = puzzles[_random.nextInt(puzzles.length)];

    _solution = _deepCopy(chosen.solution);
    _board = _deepCopy(chosen.puzzle);
    _fixed = List.generate(
      9,
      (r) => List.generate(9, (c) => chosen.puzzle[r][c] != 0),
    );
    _notes = List.generate(
      9,
      (_) => List.generate(9, (_) => <int>{}),
    );

    selectedRow = 0;
    selectedCol = 0;
    notesMode = false;
    paused = false;
    completed = false;
    secondsElapsed = 0;
    mistakes = 0;
    hintsUsed = 0;
    gameStarted = true;
    _history.clear();

    _startTimer();
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  List<List<int>> _deepCopy(List<List<int>> source) {
    return source.map((row) => List<int>.from(row)).toList();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isConflict(int row, int col, int value) {
    if (value == 0) return false;

    for (int c = 0; c < 9; c++) {
      if (c != col && _board[row][c] == value) return true;
    }

    for (int r = 0; r < 9; r++) {
      if (r != row && _board[r][col] == value) return true;
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && _board[r][c] == value) return true;
      }
    }

    return false;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (!gameStarted || paused || completed) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1, 0);
      return;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1, 0);
      return;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveSelection(0, -1);
      return;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveSelection(0, 1);
      return;
    }

    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0) {
      _clearCell();
      return;
    }

    final number = _logicalKeyToNumber(key);
    if (number != null) {
      _enterNumber(number);
    }
  }

  int? _logicalKeyToNumber(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) return 1;
    if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) return 2;
    if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) return 3;
    if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) return 4;
    if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) return 5;
    if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) return 6;
    if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) return 7;
    if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) return 8;
    if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) return 9;
    return null;
  }

  void _moveSelection(int rowDelta, int colDelta) {
    if (selectedRow == null || selectedCol == null) return;

    setState(() {
      selectedRow = (selectedRow! + rowDelta).clamp(0, 8);
      selectedCol = (selectedCol! + colDelta).clamp(0, 8);
    });
  }

  void _selectCell(int row, int col) {
    if (!gameStarted || paused || completed) return;

    setState(() {
      selectedRow = row;
      selectedCol = col;
    });

    _keyboardFocusNode.requestFocus();
  }

  void _enterNumber(int number) {
    if (!gameStarted || selectedRow == null || selectedCol == null || paused || completed) {
      return;
    }

    final row = selectedRow!;
    final col = selectedCol!;

    if (_fixed[row][col]) return;

    final previousValue = _board[row][col];
    final previousNotes = Set<int>.from(_notes[row][col]);

    if (notesMode) {
      setState(() {
        if (_notes[row][col].contains(number)) {
          _notes[row][col].remove(number);
        } else {
          _notes[row][col].add(number);
        }

        _history.add(
          Move(
            row: row,
            col: col,
            previousValue: previousValue,
            newValue: previousValue,
            previousNotes: previousNotes,
            newNotes: Set<int>.from(_notes[row][col]),
          ),
        );
      });
      return;
    }

    setState(() {
      _board[row][col] = number;
      _notes[row][col].clear();

      _history.add(
        Move(
          row: row,
          col: col,
          previousValue: previousValue,
          newValue: number,
          previousNotes: previousNotes,
          newNotes: {},
        ),
      );

      if (number != _solution[row][col]) {
        mistakes++;
      }

      _checkCompletion();
    });
  }

  void _clearCell() {
    if (!gameStarted || selectedRow == null || selectedCol == null || paused || completed) {
      return;
    }

    final row = selectedRow!;
    final col = selectedCol!;

    if (_fixed[row][col]) return;

    final previousValue = _board[row][col];
    final previousNotes = Set<int>.from(_notes[row][col]);

    setState(() {
      _board[row][col] = 0;
      _notes[row][col].clear();

      _history.add(
        Move(
          row: row,
          col: col,
          previousValue: previousValue,
          newValue: 0,
          previousNotes: previousNotes,
          newNotes: {},
        ),
      );
    });
  }

  void _undo() {
    if (!gameStarted || _history.isEmpty || paused) return;

    final last = _history.removeLast();

    setState(() {
      _board[last.row][last.col] = last.previousValue;
      _notes[last.row][last.col] = Set<int>.from(last.previousNotes);
      completed = false;
    });
  }

  void _useHint() {
    if (!gameStarted || selectedRow == null || selectedCol == null || paused || completed) {
      return;
    }

    final row = selectedRow!;
    final col = selectedCol!;

    if (_fixed[row][col]) return;

    final previousValue = _board[row][col];
    final previousNotes = Set<int>.from(_notes[row][col]);
    final correct = _solution[row][col];

    setState(() {
      _board[row][col] = correct;
      _notes[row][col].clear();
      hintsUsed++;

      _history.add(
        Move(
          row: row,
          col: col,
          previousValue: previousValue,
          newValue: correct,
          previousNotes: previousNotes,
          newNotes: {},
        ),
      );

      _checkCompletion();
    });
  }

  void _checkCompletion() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_board[r][c] != _solution[r][c]) {
          return;
        }
      }
    }

    completed = true;
    _timer?.cancel();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gratulálok!'),
        content: Text(
          'Megoldottad a Sudoku táblát.\n\n'
          'Idő: ${_formatTime(secondsElapsed)}\n'
          'Hibák: $mistakes\n'
          'Tippek: $hintsUsed',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _cellColor(int row, int col) {
    final isSelected = row == selectedRow && col == selectedCol;

    if (isSelected) {
      return Colors.indigo.shade100;
    }

    if (selectedRow != null && selectedCol != null) {
      if (row == selectedRow || col == selectedCol) {
        return Colors.indigo.shade50;
      }

      if (row ~/ 3 == selectedRow! ~/ 3 && col ~/ 3 == selectedCol! ~/ 3) {
        return Colors.indigo.shade50;
      }
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    final horizontalPadding = size.width < 500 ? 12.0 : 24.0;
    final maxBoardSize = isWide
        ? min(size.height * 0.72, 620.0)
        : min(size.width - (horizontalPadding * 2), size.height * 0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: gameStarted
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: isWide
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: _buildBoardSection(maxBoardSize),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: _buildSidePanel(),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildTopStats(),
                                    const SizedBox(height: 16),
                                    _buildBoardSection(maxBoardSize),
                                    const SizedBox(height: 20),
                                    _buildSidePanel(),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 14,
                              color: Colors.black12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.grid_on_rounded, size: 72),
                            const SizedBox(height: 16),
                            const Text(
                              'Sudoku',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'A játék csak akkor indul el, amikor te szeretnéd.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              value: difficulty,
                              decoration: const InputDecoration(
                                labelText: 'Nehézség',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    difficulty = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: () => _startNewGame(),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Játék indítása'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _statChip('Nehézség', difficulty),
        _statChip('Idő', _formatTime(secondsElapsed)),
        _statChip('Hibák', '$mistakes'),
        _statChip('Tippek', '$hintsUsed'),
      ],
    );
  }

  Widget _buildBoardSection(double boardSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTopStats(),
        const SizedBox(height: 16),
        if (paused)
          Container(
            width: boardSize,
            height: boardSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pause_circle, size: 64),
                SizedBox(height: 12),
                Text(
                  'A játék szünetel',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
            ),
            child: Column(
              children: List.generate(9, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(9, (col) {
                      final value = _board[row][col];
                      final notes = _notes[row][col];
                      final isFixed = _fixed[row][col];
                      final conflict = _isConflict(row, col, value);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectCell(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _cellColor(row, col),
                              border: Border(
                                top: BorderSide(
                                  color: row % 3 == 0 ? Colors.black : Colors.grey.shade400,
                                  width: row % 3 == 0 ? 2 : 0.5,
                                ),
                                left: BorderSide(
                                  color: col % 3 == 0 ? Colors.black : Colors.grey.shade400,
                                  width: col % 3 == 0 ? 2 : 0.5,
                                ),
                                right: BorderSide(
                                  color: col == 8 ? Colors.black : Colors.grey.shade400,
                                  width: col == 8 ? 2 : 0.5,
                                ),
                                bottom: BorderSide(
                                  color: row == 8 ? Colors.black : Colors.grey.shade400,
                                  width: row == 8 ? 2 : 0.5,
                                ),
                              ),
                            ),
                            child: value != 0
                                ? Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$value',
                                        style: TextStyle(
                                          fontSize: boardSize * 0.055,
                                          fontWeight: isFixed ? FontWeight.bold : FontWeight.w600,
                                          color: conflict
                                              ? Colors.red
                                              : isFixed
                                                  ? Colors.black
                                                  : Colors.indigo,
                                        ),
                                      ),
                                    ),
                                  )
                                : _NotesGrid(
                                    notes: notes,
                                    boardSize: boardSize,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: _showDifficultyDialog,
              child: const Text('Új játék'),
            ),
            OutlinedButton(
              onPressed: _undo,
              child: const Text('Visszavonás'),
            ),
            OutlinedButton(
              onPressed: _useHint,
              child: const Text('Tipp'),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  notesMode = !notesMode;
                });
                _keyboardFocusNode.requestFocus();
              },
              child: Text(notesMode ? 'Jegyzet: BE' : 'Jegyzet: KI'),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  paused = !paused;
                });
                _keyboardFocusNode.requestFocus();
              },
              child: Text(paused ? 'Folytatás' : 'Szünet'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = constraints.maxWidth > 420 ? 68.0 : 56.0;
            final fontSize = constraints.maxWidth > 420 ? 22.0 : 18.0;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 1; i <= 9; i++)
                  SizedBox(
                    width: buttonWidth,
                    height: buttonWidth,
                    child: FilledButton(
                      onPressed: () {
                        _enterNumber(i);
                        _keyboardFocusNode.requestFocus();
                      },
                      child: Text(
                        '$i',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                SizedBox(
                  width: max(120, buttonWidth * 2),
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _clearCell();
                      _keyboardFocusNode.requestFocus();
                    },
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('Törlés'),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Billentyűzet: 1-9 beírás, 0 / Delete / Backspace törlés, nyilak mozgatás',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Válassz nehézséget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Easy'),
                onTap: () {
                  Navigator.pop(context);
                  _startNewGame(newDifficulty: 'Easy');
                },
              ),
              ListTile(
                title: const Text('Medium'),
                onTap: () {
                  Navigator.pop(context);
                  _startNewGame(newDifficulty: 'Medium');
                },
              ),
              ListTile(
                title: const Text('Hard'),
                onTap: () {
                  Navigator.pop(context);
                  _startNewGame(newDifficulty: 'Hard');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  final double boardSize;

  const _NotesGrid({
    required this.notes,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;
        final contains = notes.contains(number);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              contains ? '$number' : '',
              style: TextStyle(
                fontSize: boardSize * 0.022,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SudokuPuzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  SudokuPuzzle({
    required this.puzzle,
    required this.solution,
  });
}

class Move {
  final int row;
  final int col;
  final int previousValue;
  final int newValue;
  final Set<int> previousNotes;
  final Set<int> newNotes;

  Move({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
    required this.previousNotes,
    required this.newNotes,
  });
}