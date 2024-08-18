// lib/models.dart
class Game {
  final int userID;
  final int gameID;
  final int point;
  final int gamePoint;

  Game({
    required this.userID,
    required this.gameID,
    required this.point,
    required this.gamePoint,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      userID: json['user_id'],
      gameID: json['game_id'],
      point: json['point'],
      gamePoint: json['gamepoint'],
    );
  }
}
