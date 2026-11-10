class Profile {
  final String name;
  final String nim;
  final String kelas;
  final String bio;
  final int avatarColor; // indeks warna di ProfileAvatar.colors

  const Profile({
    required this.name,
    required this.nim,
    required this.kelas,
    this.bio = '',
    this.avatarColor = 0,
  });

  static const defaultProfile = Profile(
    name: 'Achmad Dhanil Ahkam',
    nim: '2415051049',
    kelas: 'PTI 5C',
    bio: 'Pecinta film.',
  );

  Profile copyWith({
    String? name,
    String? nim,
    String? kelas,
    String? bio,
    int? avatarColor,
  }) {
    return Profile(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      kelas: kelas ?? this.kelas,
      bio: bio ?? this.bio,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}