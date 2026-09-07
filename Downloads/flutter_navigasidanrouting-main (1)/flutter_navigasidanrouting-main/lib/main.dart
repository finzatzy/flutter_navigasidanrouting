import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final String? kategori; // Properti baru bertipe nullable (bisa kosong/null)
  bool isFavorite;

  Contact({
    required this.nama,
    required this.email,
    required this.noHp,
    this.kategori, // Bersifat opsional, tidak wajib diisi
    this.isFavorite = false,
  });
}

// ==========================================================
// VALIDATOR INPUT (Nama, Email, No HP)
// ==========================================================
class Validators {
  static String? nama(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nama wajib diisi';
    if (v.length < 3) return 'Nama minimal 3 karakter';
    final regex = RegExp(r"^[a-zA-Z\s.']+$");
    if (!regex.hasMatch(v)) return 'Nama hanya boleh berisi huruf';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');
    if (!regex.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  static String? noHp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'No Handphone wajib diisi';
    final regex = RegExp(r'^(0|\+62)[0-9]{9,13}$');
    if (!regex.hasMatch(v)) {
      return 'No HP tidak valid (contoh: 08123456789)';
    }
    return null;
  }
}

// ==========================================================
// PENYIMPANAN DATA KONTAK (agar Kontak & Favorit selalu sinkron)
// ==========================================================
class ContactStore extends ChangeNotifier {
  ContactStore._internal() {
    // Menambahkan data dirimu secara otomatis saat aplikasi dibuka
    _contacts.add(
      Contact(
        nama: 'Yuri Aulia Widyadana',
        email: 'yuriwidyadana@gmail.com',
        noHp: '08812653247',
        kategori: 'Keluarga',
        isFavorite: true,
      ),
    );
  }

  static final ContactStore instance = ContactStore._internal();

  final List<Contact> _contacts = [];

  // Query pencarian, dipisah agar UI pencarian bisa didengarkan sendiri
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Contact> get favorites => _contacts.where((c) => c.isFavorite).toList();

  List<Contact> get filteredContacts => _applySearch(contacts);
  List<Contact> get filteredFavorites => _applySearch(favorites);

  List<Contact> _applySearch(List<Contact> source) {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source
        .where((c) => c.nama.toLowerCase().contains(query))
        .toList();
  }

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
      title: 'Buku Kontak Favorit',
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
// KOTAK PENCARIAN (dipakai bersama oleh tab Kontak & Favorit)
// ==========================================================
class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.hintText});

  final String hintText;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ContactStore.instance.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        controller: _controller,
        onChanged: (value) => ContactStore.instance.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: ContactStore.instance.searchQuery,
            builder: (context, value, _) {
              if (value.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  ContactStore.instance.searchQuery.value = '';
                },
              );
            },
          ),
        ),
      ),
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
    return Column(
      children: [
        const _SearchBar(hintText: 'Cari nama kontak...'),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge(
              [ContactStore.instance, ContactStore.instance.searchQuery],
            ),
            builder: (context, _) {
              final contacts = ContactStore.instance.filteredContacts;
              final isSearching =
                  ContactStore.instance.searchQuery.value.trim().isNotEmpty;
              if (contacts.isEmpty) {
                return _EmptyState(
                  icon: isSearching
                      ? Icons.search_off
                      : Icons.contacts_outlined,
                  message: isSearching
                      ? 'Nama kontak tidak ditemukan'
                      : 'Belum ada kontak',
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
          ),
        ),
      ],
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
    return Column(
      children: [
        const _SearchBar(hintText: 'Cari nama favorit...'),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge(
              [ContactStore.instance, ContactStore.instance.searchQuery],
            ),
            builder: (context, _) {
              final favorites = ContactStore.instance.filteredFavorites;
              final isSearching =
                  ContactStore.instance.searchQuery.value.trim().isNotEmpty;
              if (favorites.isEmpty) {
                return _EmptyState(
                  icon: isSearching ? Icons.search_off : Icons.star_border,
                  message: isSearching
                      ? 'Nama favorit tidak ditemukan'
                      : 'Belum ada kontak favorit.',
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
          ),
        ),
      ],
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
          child: Text(
            '${contact.email}\n${contact.noHp}\nKategori: ${contact.kategori ?? 'Tanpa kategori'}',
          ),
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

// Tampilan saat daftar kosong / hasil pencarian kosong
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
  final _kategoriController = TextEditingController(); // Controller untuk kategori

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (_formKey.currentState!.validate()) {
      ContactStore.instance.add(
        Contact(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          noHp: _hpController.text.trim(),
          kategori: _kategoriController.text.trim().isEmpty 
              ? null 
              : _kategoriController.text.trim(),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kontak')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: Validators.nama,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _hpController,
                label: 'No Handphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.noHp,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
              ),
              const SizedBox(height: 16),
              // Field Input Kategori Baru (Opsional / Null Safety)
              _buildField(
                controller: _kategoriController,
                label: 'Kategori (Opsional, cth: Keluarga)',
                icon: Icons.category_outlined,
                validator: (value) => null, // Tidak wajib diisi
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
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
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
                backgroundImage: AssetImage('assets/profil.jpg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yuri Aulia Widyadana',
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