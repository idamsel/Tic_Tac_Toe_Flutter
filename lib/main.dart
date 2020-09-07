import 'package:flutter/material.dart';

enum Mark { X, O, NONE }
const STROKE_WIDTH = 6.0;
const HALF_STROKE_WIDTH = STROKE_WIDTH / 2.0;
const DOUBLE_STROKE_WIDTH = STROKE_WIDTH * 2.0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.amberAccent,
          appBarTheme: AppBarTheme(color: Colors.grey)),
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  Map<int, Mark> _gameMarks = Map();
  Mark _currentMark = Mark.O;
  List<int> _winningLine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tic Tac Toe"),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTapUp: (TapUpDetails details) {
            setState(() {
              if (_gameMarks.length >= 9 || _winningLine != null) {
                //Reset the game if there is an additional tap after all the slots have been filled.
                _gameMarks = Map<int, Mark>();
                _currentMark = Mark.O;
                _winningLine = null; // announce winner.
              } else {
                _addMark(details.localPosition.dx, details.localPosition.dy);
                _winningLine = getWinningLine(); // check winning status.
              }
            });
          },
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              child: Container(
                child: CustomPaint(
                  painter: GamePainter(_gameMarks, _winningLine),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addMark(double x, double y) {
    double _dividedSize = GamePainter.getDividedSize();
    bool isAbsent = false;
    _gameMarks
        .putIfAbsent((x ~/ _dividedSize + (y ~/ _dividedSize) * 3.toInt()), () {
      isAbsent = true;
      return _currentMark;
    });

    if (isAbsent) _currentMark = _currentMark == Mark.O ? Mark.X : Mark.O;
  }

  List<int> getWinningLine() {
    final winningLines = [
      [0, 1, 2], //Horizontal.
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6], //Verical.
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8], //Diagonal.
      [2, 4, 6]
    ];

    List<int> winningLineFound;
    winningLines.forEach((winningLine) {
      int countNoughts = 0;
      int countcross = 0;

      winningLine.forEach((index) {
        if (_gameMarks[index] == Mark.O) {
          ++countNoughts;
        } else if (_gameMarks[index] == Mark.X) {
          ++countcross;
        }
      });

      if (countNoughts >= 3 || countcross >= 3) {
        winningLineFound = winningLine;
      }
    });
    return winningLineFound;
  }
}

class GamePainter extends CustomPainter {
  static double _dividedSize;
  Map<int, Mark> _gameMarks; //store X and O values.
  List<int> _winningLine; //store winning line.

  GamePainter(this._gameMarks,
      this._winningLine); //Constructor receives the X and O status and store it internally.

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = STROKE_WIDTH
      ..color = Colors.black;

    final blackThickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DOUBLE_STROKE_WIDTH
      ..color = Colors.black;

    final redThickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DOUBLE_STROKE_WIDTH
      ..color = Colors.red;

    final orangeThickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DOUBLE_STROKE_WIDTH
      ..color = Colors.orange;

    _dividedSize = size.width / 3.0;

    //1st horizontal line.
    canvas.drawLine(
      Offset(STROKE_WIDTH, _dividedSize - HALF_STROKE_WIDTH),
      Offset(size.width - STROKE_WIDTH, _dividedSize - HALF_STROKE_WIDTH),
      blackPaint,
    );

    //2nd horizontal line.
    canvas.drawLine(
        Offset(STROKE_WIDTH, _dividedSize * 2 - HALF_STROKE_WIDTH),
        Offset(size.width - STROKE_WIDTH, _dividedSize * 2 - HALF_STROKE_WIDTH),
        blackPaint);

    //1st vertical line.
    canvas.drawLine(
      Offset(_dividedSize - HALF_STROKE_WIDTH, STROKE_WIDTH),
      Offset(_dividedSize - HALF_STROKE_WIDTH, size.height - STROKE_WIDTH),
      blackPaint,
    );

    //2nd vertical line.
    canvas.drawLine(
      Offset(_dividedSize * 2 - HALF_STROKE_WIDTH, STROKE_WIDTH),
      Offset(_dividedSize * 2 - HALF_STROKE_WIDTH, size.height - STROKE_WIDTH),
      blackPaint,
    );

    _gameMarks.forEach((index, mark) {
      switch (mark) {
        case Mark.O:
          drawNought(canvas, index, redThickPaint);
          break;
        case Mark.X:
          drawCross(canvas, index, blackThickPaint);
          break;
        default:
          break;
      }
    });
    drawWinningLine(
        canvas, _winningLine, orangeThickPaint); //Draw winning line if any.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static double getDividedSize() => _dividedSize;

  //Draw 0.

  void drawNought(Canvas canvas, int index, Paint paint) {
    double left = (index % 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;
    double top = (index ~/ 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;
    double noughtSize = _dividedSize - DOUBLE_STROKE_WIDTH * 4;

    canvas.drawOval(Rect.fromLTWH(left, top, noughtSize, noughtSize), paint);
  }

  //Draw X.

  void drawCross(Canvas canvas, int index, Paint paint) {
    double x1, y1;
    double x2, y2;

    x1 = (index % 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;
    y1 = (index ~/ 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;

    x2 = (index % 3 + 1) * _dividedSize - DOUBLE_STROKE_WIDTH * 2;
    y2 = (index ~/ 3 + 1) * _dividedSize - DOUBLE_STROKE_WIDTH * 2;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

    x1 = (index % 3 + 1) * _dividedSize - DOUBLE_STROKE_WIDTH * 2;
    y1 = (index ~/ 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;

    x2 = (index % 3) * _dividedSize + DOUBLE_STROKE_WIDTH * 2;
    y2 = (index ~/ 3 + 1) * _dividedSize - DOUBLE_STROKE_WIDTH * 2;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  //if there is no winner we shouldn't drawing winning line.
  void drawWinningLine(Canvas canvas, List<int> winningLine, Paint paint) {
    if (winningLine == null) return;

    double x1 = 0, y1 = 0;
    double x2 = 0, y2 = 0;

    //determine the direction.
    int firstIndex = winningLine.first;
    int lastIndex = winningLine.last;

    if (firstIndex % 3 == lastIndex % 3) {
      //vertical line.
      x1 = x2 = firstIndex % 3 * _dividedSize + _dividedSize / 2;
      y1 = STROKE_WIDTH;
      y2 = _dividedSize * 3 - STROKE_WIDTH;
    } else if (firstIndex ~/ 3 == lastIndex ~/ 3) {
      //horizontal line.
      x1 = STROKE_WIDTH;
      x2 = _dividedSize * 3 - STROKE_WIDTH;
      y1 = y2 = firstIndex ~/ 3 * _dividedSize + _dividedSize / 2;
    } else {
      //diagonal line.
      if (firstIndex == 0) {
        x1 = y1 = DOUBLE_STROKE_WIDTH;
        x2 = y2 = _dividedSize * 3 - DOUBLE_STROKE_WIDTH;
      } else {
        x1 = _dividedSize * 3 - DOUBLE_STROKE_WIDTH;
        y1 = DOUBLE_STROKE_WIDTH;
        x2 = DOUBLE_STROKE_WIDTH;
        y2 = _dividedSize * 3 - DOUBLE_STROKE_WIDTH;
      }
    }

    //draw the winning line.
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }
}
