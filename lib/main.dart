import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================================
// MODEL DATA KONTAK
// ==========================================================
class Contact {
  final String nama;
  final String email;
  final String noHp;
  bool isFavorite;

  Contact({
    required this.nama,
    required this.email,
    required this.noHp,
    this.isFavorite = false,
  });
}

// ==========================================================
// PENYIMPANAN DATA KONTAK (agar Kontak & Favorit selalu sinkron)
// ==========================================================
class ContactStore extends ChangeNotifier {
  ContactStore._internal();
  static final ContactStore instance = ContactStore._internal();

  final List<Contact> _contacts = [];

  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Contact> get favorites => _contacts.where((c) => c.isFavorite).toList();

  void add(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void toggleFavorite(Contact contact) {
    contact.isFavorite = !contact.isFavorite;
    notifyListeners();
  }
}

// ==========================================================
// WARNA & TEMA
// ==========================================================
const kPrimaryColor = Color(0xFF3B6FE0);
const kAccentColor = Color(0xFF8B5CF6);
const kBackgroundColor = Color(0xFFF4F6FB);

// ==========================================================
// APLIKASI UTAMA
// ==========================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          secondary: kAccentColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/tambah-kontak': (context) => const TambahKontakScreen(),
        '/tentang': (context) => const TentangScreen(),
      },
    );
  }
}

// ==========================================================
// HALAMAN BERANDA (AppBar + Drawer + TabBar + TabBarView + FAB)
// ==========================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kAccentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: const Text(
            'BUKU KONTAK',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.account_circle), text: 'Kontak'),
              Tab(icon: Icon(Icons.star), text: 'Favorit'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kAccentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.contacts,
                        color: kPrimaryColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'BUKU KONTAK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.assignment_ind,
                label: 'Kontak',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.person_add_alt_1,
                label: 'Tambah Kontak',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/tambah-kontak');
                },
              ),
              _DrawerItem(
                icon: Icons.star,
                label: 'Favorit',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.info,
                label: 'Tentang',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/tentang');
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [KontakTab(), FavoritTab()]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kAccentColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/tambah-kontak');
          },
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// ==========================================================
// HALAMAN KONTAK
// ==========================================================
class KontakTab extends StatelessWidget {
  const KontakTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ContactStore.instance,
      builder: (context, _) {
        final contacts = ContactStore.instance.contacts;
        if (contacts.isEmpty) {
          return const _EmptyState(
            icon: Icons.contacts_outlined,
            message: 'Belum ada kontak',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return _ContactCard(
              contact: contact,
              onFavoriteTap: () =>
                  ContactStore.instance.toggleFavorite(contact),
            );
          },
        );
      },
    );
  }
}

// ==========================================================
// HALAMAN FAVORIT
// ==========================================================
class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ContactStore.instance,
      builder: (context, _) {
        final favorites = ContactStore.instance.favorites;
        if (favorites.isEmpty) {
          return const _EmptyState(
            icon: Icons.star_border,
            message: 'Belum ada kontak favorit.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final contact = favorites[index];
            return _ContactCard(
              contact: contact,
              onFavoriteTap: () =>
                  ContactStore.instance.toggleFavorite(contact),
            );
          },
        );
      },
    );
  }
}

// Kartu kontak yang dipakai bersama oleh tab Kontak & Favorit
class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onFavoriteTap;

  const _ContactCard({required this.contact, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: kPrimaryColor.withOpacity(0.12),
          child: Text(
            contact.nama.isNotEmpty ? contact.nama[0].toUpperCase() : '?',
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          contact.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${contact.email}\n${contact.noHp}'),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            contact.isFavorite ? Icons.star : Icons.star_border,
            color: contact.isFavorite ? Colors.amber : Colors.grey,
          ),
          onPressed: onFavoriteTap,
        ),
      ),
    );
  }
}

// Tampilan saat daftar kosong
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// HALAMAN TAMBAH KONTAK
// ==========================================================
class TambahKontakScreen extends StatefulWidget {
  const TambahKontakScreen({super.key});

  @override
  State<TambahKontakScreen> createState() => _TambahKontakScreenState();
}

class _TambahKontakScreenState extends State<TambahKontakScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (_formKey.currentState!.validate()) {
      ContactStore.instance.add(
        Contact(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          noHp: _hpController.text.trim(),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kontak')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _hpController,
                label: 'No Handphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _simpanKontak,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? '$label wajib diisi' : null,
    );
  }
}

// ==========================================================
// HALAMAN TENTANG (profil diri)
// ==========================================================
class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [kPrimaryColor, kAccentColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white,
                // Foto diambil dari assets/profil.jpg
                // (sudah didaftarkan di pubspec.yaml)
                backgroundImage: AssetImage('assets/profil.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Muhammad Finza Mutaali',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'XII RPL B',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: kPrimaryColor),
                    SizedBox(width: 12),
                    Text('SMK Negeri 5 Surakarta'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
