class AppUser {
  final String uid;
  final String email;
  final String artistAlias;
  final String description;
  final String contactMethod;
  final List<Map<String, String>> instruments;
  final List<String> genres;
  final bool profileCompleted;

  final String profileImage;
  final String bannerImage;

  AppUser({
    required this.uid,
    required this.email,
    required this.artistAlias,
    required this.description,
    required this.contactMethod,
    required this.instruments,
    required this.genres,
    required this.profileCompleted,
    required this.profileImage,
    required this.bannerImage,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    final rawInstruments = data["instruments"];
    final rawGenres = data["genres"];

    List<Map<String, String>> parsedInstruments = [];

    if (rawInstruments is List) {
      parsedInstruments = rawInstruments.map((item) {
        if (item is Map) {
          return item.map(
                (key, value) => MapEntry(
              key.toString(),
              value.toString(),
            ),
          );
        }

        return {
          "name": item.toString(),
          "experience": "",
          "learningMethod": "",
        };
      }).toList();
    } else if (rawInstruments is String &&
        rawInstruments.isNotEmpty) {
      parsedInstruments = [
        {
          "name": rawInstruments,
          "experience": "",
          "learningMethod": "",
        }
      ];
    }

    List<String> parsedGenres = [];

    if (rawGenres is List) {
      parsedGenres =
          rawGenres.map((item) => item.toString()).toList();
    } else if (rawGenres is String &&
        rawGenres.isNotEmpty) {
      parsedGenres = [rawGenres];
    }

    return AppUser(
      uid: data["uid"]?.toString() ?? "",
      email: data["email"]?.toString() ?? "",
      artistAlias: data["artistAlias"]?.toString() ?? "",
      description: data["description"]?.toString() ?? "",
      contactMethod:
      data["contactMethod"]?.toString() ?? "",
      instruments: parsedInstruments,
      genres: parsedGenres,
      profileCompleted:
      data["profileCompleted"] == true,

      profileImage:
      data["profileImage"]?.toString() ??
          "https://i.pravatar.cc/300",

      bannerImage:
      data["bannerImage"]?.toString() ??
          "https://images.unsplash.com/photo-1516280440614-37939bbacd81?q=80&w=1200&auto=format&fit=crop",
    );
  }
}