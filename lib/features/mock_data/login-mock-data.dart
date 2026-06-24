// Định nghĩa cấu trúc thông tin User
class UserModel {
  final String username;
  final String avatarUrl;

  UserModel({required this.username, required this.avatarUrl});
}

// Định nghĩa cấu trúc thông tin một tựa Game
class GameModel {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String playersCount;
  final bool isPopular;

  GameModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.playersCount,
    this.isPopular = false,
  });
}

// Nơi chứa dữ liệu giả lập để gọi ở bất cứ đâu trong App
class LoginMockData {
  // 1. Giả lập tài khoản vừa đăng nhập thành công
  static final UserModel mockUser = UserModel(
    username: "Dottore",
    avatarUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
  );

  // 2. Giả lập danh sách Game đổ vào thư viện
  static final List<GameModel> mockGames = [
    GameModel(
      title: "Eternal Guardians",
      description: "An epic MMORPG with high-stakes guild wars and intricate gear scoring systems.",
      imageUrl: "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=800",
      category: "FPS",
      playersCount: "2.4M",
      isPopular: true,
    ),
    GameModel(
      title: "Shadow Legacy",
      description: "Explore dark dungeons and unveil ancient secrets in this classic turn-based RPG.",
      imageUrl: "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800",
      category: "RPG",
      playersCount: "1.8M",
      isPopular: false,
    ),
  ];
}