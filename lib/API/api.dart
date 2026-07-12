import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';

class ApiService {
  static const String baseUrl = 'https://be-xcsg.onrender.com';
  static String? token;
  static String? currentUserEmail;

  static void logout() {
    token = null;
    currentUserEmail = null;
  }

  static Map<String, String> get headers {
    final map = {'Content-Type': 'application/json'};
    if (token != null) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }

  static Future<UserModel?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/Auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'] ?? data['Token'];
      final userData = data['user'] ?? data['User'];
      if (userData != null) {
        currentUserEmail = userData['email'] ?? '';
        final role = userData['role'] ?? 'user';
        final avatarUrl = role == 'admin'
            ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200'
            : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200';

        return UserModel(
          username: userData['username'] ?? 'User',
          email: userData['email'] ?? '',
          role: role,
          avatarUrl: avatarUrl,
        );
      }
      return null;
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Failed to log in.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    }
  }

  static Future<String> register(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/Auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Registration successful';
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Failed to register.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    }
  }

  static Future<List<GameModel>> getGames() async {
    final url = Uri.parse('$baseUrl/api/Games');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) {
        final genre = item['genre'] ?? 'Other';
        String imageUrl;
        if (genre == 'MOBA') {
          imageUrl = 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800';
        } else if (genre == 'MMORPG') {
          imageUrl = 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=800';
        } else {
          imageUrl = 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800';
        }

        final gameId = item['gameId'] ?? 0;
        final playersCount = '${(gameId * 1.2).toStringAsFixed(1)}M';
        final companyName = item['companyName'] ?? 'Unknown Company';

        return GameModel(
          gameId: gameId,
          title: item['gameName'] ?? 'Unknown Game',
          description: 'Published by $companyName',
          imageUrl: imageUrl,
          category: genre,
          playersCount: playersCount,
          isPopular: gameId % 2 == 1,
          companyName: companyName,
        );
      }).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<PlayerModel>> getPlayers() async {
    final url = Uri.parse('$baseUrl/api/Players');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => PlayerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<PlayerModel?> getPlayerById(int id) async {
    final url = Uri.parse('$baseUrl/api/Players/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PlayerModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<PlayerModel>> searchPlayers(String name) async {
    final url = Uri.parse('$baseUrl/api/Players/search?name=${Uri.encodeComponent(name)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PlayerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<PlayerModel>> getPlayersByGame(int gameId) async {
    final url = Uri.parse('$baseUrl/api/Players/game/$gameId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PlayerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<PlayerModel>> getPlayersByServer(int serverId) async {
    final url = Uri.parse('$baseUrl/api/Players/server/$serverId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PlayerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<PlayerModel>> getPlayersByGuild(int guildId) async {
    final url = Uri.parse('$baseUrl/api/Players/guild/$guildId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PlayerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<ServerModel>> getServers() async {
    final url = Uri.parse('$baseUrl/api/servers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => ServerModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<OcrExtractResponse> extractText(String filePath, {String language = 'vie'}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File does not exist at $filePath');
    }

    final url = Uri.parse('https://hxvf123-demoocrserver.hf.space/api/v1/extract?language=$language');
    final client = HttpClient();

    try {
      final request = await client.postUrl(url);
      
      final boundary = '----BoundaryString${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('content-type', 'multipart/form-data; boundary=$boundary');

      final fileName = file.path.split('/').last.split('\\').last;
      final header = '--$boundary\r\n'
          'Content-Disposition: form-data; name="image"; filename="$fileName"\r\n'
          'Content-Type: image/png\r\n\r\n';
      final footer = '\r\n--$boundary--\r\n';

      final fileBytes = await file.readAsBytes();
      
      request.write(header);
      request.add(fileBytes);
      request.write(footer);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return OcrExtractResponse.fromJson(data);
      } else {
        String? validationMsg;
        try {
          final errorData = jsonDecode(responseBody);
          if (errorData is Map && errorData.containsKey('detail')) {
            final details = errorData['detail'];
            if (details is List && details.isNotEmpty) {
              final firstError = details.first;
              if (firstError is Map) {
                final msg = firstError['msg'];
                final loc = firstError['loc'];
                if (msg != null) {
                  validationMsg = 'Extraction validation error: $msg (at $loc)';
                }
              }
            }
          }
        } catch (_) {
          // ignore parsing error
        }

        if (validationMsg != null) {
          throw Exception(validationMsg);
        }
        throw Exception('Extraction failed with status code: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  static Future<List<ApiUserModel>> getUsers() async {
    final url = Uri.parse('$baseUrl/api/Users');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => ApiUserModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<ApiUserModel> createUser(
      String username, String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/api/Users');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ApiUserModel.fromJson(data);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Failed to create user.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    }
  }

  static Future<ApiUserModel> getUserProfile() async {
    final url = Uri.parse('$baseUrl/api/Users/profile');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiUserModel.fromJson(data);
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<ApiUserModel> updateUserProfile(String username, String email) async {
    final url = Uri.parse('$baseUrl/api/Users/profile');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        'username': username,
        'email': email,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      final data = jsonDecode(response.body);
      return ApiUserModel.fromJson(data);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Failed to update profile.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    }
  }

  static Future<void> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/api/Users/$id');
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<GameModel> createGame(String gameName, String genre, String companyName) async {
    final url = Uri.parse('$baseUrl/api/Games');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'gamename': gameName,
        'genre': genre,
        'company': {
          'companyname': companyName,
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final genreVal = data['genre'] ?? 'Other';
      final gameId = data['gameId'] ?? 0;
      final companyNameVal = data['companyName'] ?? companyName;
      return GameModel(
        gameId: gameId,
        title: data['gameName'] ?? gameName,
        description: 'Published by $companyNameVal',
        imageUrl: genreVal == 'MOBA'
            ? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800'
            : 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=800',
        category: genreVal,
        playersCount: '0.0M',
        isPopular: false,
        companyName: companyNameVal,
      );
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<GameModel> updateGame(int id, String gameName, String genre, String companyName) async {
    final url = Uri.parse('$baseUrl/api/Games/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        'gameid': id,
        'gamename': gameName,
        'genre': genre,
        'company': {
          'companyname': companyName,
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return GameModel(
        gameId: id,
        title: gameName,
        description: 'Published by $companyName',
        imageUrl: genre == 'MOBA'
            ? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800'
            : 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=800',
        category: genre,
        playersCount: '0.0M',
        isPopular: false,
        companyName: companyName,
      );
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<void> deleteGame(int id) async {
    final url = Uri.parse('$baseUrl/api/Games/$id');
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<List<LeaderboardModel>> getLeaderboards() async {
    final url = Uri.parse('$baseUrl/api/leaderboard');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => LeaderboardModel.fromJson(item)).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }

  static Future<AnalysisResultModel> analyzeAutomatic({int gameId = 0}) async {
    final url = Uri.parse('$baseUrl/api/ai/analyze/automatic?gameName=$gameId');
    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AnalysisResultModel.fromJson(data);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Failed to run automatic analysis.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    }
  }

  static Future<List<double>> getHeatmapData() async {
    final url = Uri.parse('$baseUrl/api/ai/heatmap');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => (item as num).toDouble()).toList();
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }
}

class PlayerModel {
  final int playerId;
  final String playerName;
  final String guildName;
  final int latestScore;
  final int latestRank;
  final String gameName;
  final String serverName;

  PlayerModel({
    required this.playerId,
    required this.playerName,
    required this.guildName,
    required this.latestScore,
    required this.latestRank,
    required this.gameName,
    required this.serverName,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      playerId: json['playerId'] ?? 0,
      playerName: json['playerName'] ?? '',
      guildName: json['guildName'] ?? '',
      latestScore: json['latestScore'] ?? 0,
      latestRank: json['latestRank'] ?? 0,
      gameName: json['gameName'] ?? '',
      serverName: json['serverName'] ?? '',
    );
  }
}

class ServerModel {
  final int serverId;
  final String serverName;
  final String region;
  final String status;
  final String gameName;

  ServerModel({
    required this.serverId,
    required this.serverName,
    required this.region,
    required this.status,
    required this.gameName,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      serverId: json['serverId'] ?? 0,
      serverName: json['serverName'] ?? '',
      region: json['region'] ?? '',
      status: json['status'] ?? 'active',
      gameName: json['gameName'] ?? '',
    );
  }
}

class AnalysisResultModel {
  final int analysisId;
  final String imageUrl;
  final String processedTime;
  final String gameName;
  final String serverName;
  final String eventName;
  final List<LeaderboardItem> leaderboard;

  AnalysisResultModel({
    required this.analysisId,
    required this.imageUrl,
    required this.processedTime,
    required this.gameName,
    required this.serverName,
    required this.eventName,
    required this.leaderboard,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lb = json['leaderboard'] ?? [];
    return AnalysisResultModel(
      analysisId: json['analysisId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      processedTime: json['processedTime'] ?? '',
      gameName: json['gameName'] ?? '',
      serverName: json['serverName'] ?? '',
      eventName: json['eventName'] ?? '',
      leaderboard: lb.map((item) => LeaderboardItem.fromJson(item)).toList(),
    );
  }
}

class LeaderboardItem {
  final int rank;
  final String playerName;
  final int score;
  final int value;
  final String guildName;

  LeaderboardItem({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.value,
    required this.guildName,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: json['rank'] ?? 0,
      playerName: json['playerName'] ?? '',
      score: json['score'] ?? 0,
      value: json['value'] ?? 0,
      guildName: json['guildName'] ?? '',
    );
  }
}

class OcrExtractResponse {
  final bool success;
  final String filename;
  final String language;
  final int width;
  final int height;
  final String fullText;
  final List<TextBlock> textBlocks;
  final double processingTimeMs;

  OcrExtractResponse({
    required this.success,
    required this.filename,
    required this.language,
    required this.width,
    required this.height,
    required this.fullText,
    required this.textBlocks,
    required this.processingTimeMs,
  });

  factory OcrExtractResponse.fromJson(Map<String, dynamic> json) {
    final size = json['image_size'] ?? {};
    final List<dynamic> blocks = json['text_blocks'] ?? [];
    return OcrExtractResponse(
      success: json['success'] ?? false,
      filename: json['filename'] ?? '',
      language: json['language'] ?? 'eng',
      width: (size['width'] as num?)?.toInt() ?? 0,
      height: (size['height'] as num?)?.toInt() ?? 0,
      fullText: json['full_text'] ?? '',
      textBlocks: blocks.map((b) => TextBlock.fromJson(b)).toList(),
      processingTimeMs: (json['processing_time_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TextBlock {
  final String text;
  final int confidence;
  final int x;
  final int y;
  final int width;
  final int height;

  TextBlock({
    required this.text,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    final box = json['bounding_box'] ?? {};
    return TextBlock(
      text: json['text'] ?? '',
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
      x: (box['x'] as num?)?.toInt() ?? 0,
      y: (box['y'] as num?)?.toInt() ?? 0,
      width: (box['width'] as num?)?.toInt() ?? 0,
      height: (box['height'] as num?)?.toInt() ?? 0,
    );
  }
}

class ApiUserModel {
  final int userId;
  final String username;
  final String email;
  final String role;

  ApiUserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
  });

  factory ApiUserModel.fromJson(Map<String, dynamic> json) {
    return ApiUserModel(
      userId: json['userId'] ?? json['userId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}

class LeaderboardModel {
  final int leaderboardId;
  final String title;
  final String eventName;
  final String metricType;

  LeaderboardModel({
    required this.leaderboardId,
    required this.title,
    required this.eventName,
    required this.metricType,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardId: json['leaderboardId'] ?? 0,
      title: json['title'] ?? '',
      eventName: json['eventName'] ?? '',
      metricType: json['metricType'] ?? '',
    );
  }
}

class LocalHistoryService {
  static const String _baseFileName = 'analysis_history';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final userSuffix = ApiService.currentUserEmail != null 
        ? '_${ApiService.currentUserEmail!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}' 
        : '';
    return File('${dir.path}/${_baseFileName}${userSuffix}.json');
  }

  static Future<void> clearAllHistory() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static Future<List<AnalysisResultModel>> getHistory() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((item) => AnalysisResultModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveResult(AnalysisResultModel result) async {
    try {
      final file = await _getFile();
      List<AnalysisResultModel> history = await getHistory();

      final finalResult = AnalysisResultModel(
        analysisId: result.analysisId == 0 ? DateTime.now().millisecondsSinceEpoch : result.analysisId,
        imageUrl: result.imageUrl,
        processedTime: result.processedTime,
        gameName: result.gameName,
        serverName: result.serverName,
        eventName: result.eventName,
        leaderboard: result.leaderboard,
      );

      history.insert(0, finalResult);

      final jsonList = history.map((item) => {
        'analysisId': item.analysisId,
        'imageUrl': item.imageUrl,
        'processedTime': item.processedTime,
        'gameName': item.gameName,
        'serverName': item.serverName,
        'eventName': item.eventName,
        'leaderboard': item.leaderboard.map((lb) => {
          'rank': lb.rank,
          'playerName': lb.playerName,
          'score': lb.score,
          'value': lb.value,
          'guildName': lb.guildName,
        }).toList(),
      }).toList();

      await file.writeAsString(jsonEncode(jsonList));
    } catch (_) {}
  }
}
