import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import 'notification_service.dart'; // taruh di bagian import paling atas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const AplikasiLangganan());
}

// === Fungsi untuk menentukan periode tagihan secara otomatis ===
String tentukanPeriodeTagihan(DateTime tanggalJatuhTempo) {
  final DateTime sekarang = DateTime.now();
  final DateTime hariIniSaja = DateTime(
    sekarang.year,
    sekarang.month,
    sekarang.day,
  );
  final int selisihHari = tanggalJatuhTempo.difference(hariIniSaja).inDays;

  if (selisihHari > 180) {
    return 'Tahunan';
  }
  return 'Bulanan';
}

// === Geser tanggal jatuh tempo yang sudah lewat ke periode berikutnya ===
DateTime majukanTanggalJikaLewat(DateTime tanggal, String periode) {
  DateTime hasil = tanggal;
  final DateTime hariIniSaja = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  while (hasil.isBefore(hariIniSaja)) {
    if (periode == 'Tahunan') {
      hasil = DateTime(hasil.year + 1, hasil.month, hasil.day);
    } else {
      int bulanBaru = hasil.month + 1;
      int tahunBaru = hasil.year;
      if (bulanBaru > 12) {
        bulanBaru = 1;
        tahunBaru += 1;
      }
      int hariTerakhirBulan = DateTime(tahunBaru, bulanBaru + 1, 0).day;
      int hariBaru =
          hasil.day > hariTerakhirBulan ? hariTerakhirBulan : hasil.day;
      hasil = DateTime(tahunBaru, bulanBaru, hariBaru);
    }
  }
  return hasil;
}

// === Formatter otomatis titik ribuan saat mengetik ===
class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitSaja = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitSaja.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String hasilFormat = digitSaja.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: hasilFormat,
      selection: TextSelection.collapsed(offset: hasilFormat.length),
    );
  }
}

class AplikasiLangganan extends StatelessWidget {
  const AplikasiLangganan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SakuLangganan',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HalamanSplash(),
    );
  }
}

// ==========================================
// HALAMAN SPLASH SCREEN / ONBOARDING
// ==========================================
class HalamanSplash extends StatefulWidget {
  const HalamanSplash({super.key});

  @override
  State<HalamanSplash> createState() => _HalamanSplashState();
}

class _HalamanSplashState extends State<HalamanSplash>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const HalamanBeranda(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1115), Color(0xFF161922), Color(0xFF0A0C0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.8),
                              Colors.blueAccent.withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'SakuLangganan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pantau Semua Tagihan Langgananmu',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  width: 3,
                                ),
                              ),
                            ),
                            RotationTransition(
                              turns: _scaleController,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// === WIDGET KACA CHRONICLE STYLE ===
class ChronicleCardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ChronicleCardBox({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: padding ?? const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN 1: BERANDA (CHRONICLE DASHBOARD)
// ==========================================
class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> daftarLangganan = [];
  bool _sedangMemuat = true;
  static const String _kunciPenyimpanan = 'daftar_langganan_v1';

  // === Tambahan untuk Tab & Kalender ===
  late TabController _tabController;
  bool _fabMengecil = false;
  DateTime _bulanKalenderAktif = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime? _tanggalTerpilihKalender;
  final ScrollController _scrollControllerDaftar = ScrollController();
  final ScrollController _scrollControllerKalender = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _muatData();

    _scrollControllerDaftar.addListener(_onScroll);
    _scrollControllerKalender.addListener(_onScroll);
  }

  void _onScroll() {
    final ScrollController controller =
        _tabController.index == 0
            ? _scrollControllerDaftar
            : _scrollControllerKalender;

    if (!controller.hasClients) return;

    final bool mengecil = controller.offset > 20;
    if (mengecil != _fabMengecil) {
      setState(() {
        _fabMengecil = mengecil;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerDaftar.dispose();
    _scrollControllerKalender.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(_kunciPenyimpanan);

    List<Map<String, dynamic>> hasil = [];
    if (dataJson != null) {
      try {
        final List decoded = jsonDecode(dataJson);
        hasil =
            decoded.map<Map<String, dynamic>>((item) {
              return {
                'nama': item['nama'],
                'harga': item['harga'],
                'tanggalJatuhTempo': DateTime.parse(item['tanggalJatuhTempo']),
                'ingatkan': item['ingatkan'] ?? true,
                'periode': item['periode'],
              };
            }).toList();
      } catch (e) {
        debugPrint('Gagal memuat data: $e');
      }
    }

    for (var item in hasil) {
      final String periode =
          item['periode'] ?? tentukanPeriodeTagihan(item['tanggalJatuhTempo']);
      item['tanggalJatuhTempo'] = majukanTanggalJikaLewat(
        item['tanggalJatuhTempo'],
        periode,
      );
    }

    hasil.sort(
      (a, b) => (a['tanggalJatuhTempo'] as DateTime).compareTo(
        b['tanggalJatuhTempo'] as DateTime,
      ),
    );

    setState(() {
      daftarLangganan = hasil;
      _sedangMemuat = false;
    });

    _simpanData();
  }

  Future<void> _simpanData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> dataUntukDisimpan =
        daftarLangganan.map((item) {
          return {
            'nama': item['nama'],
            'harga': item['harga'],
            'tanggalJatuhTempo':
                (item['tanggalJatuhTempo'] as DateTime).toIso8601String(),
            'ingatkan': item['ingatkan'],
            'periode': item['periode'],
          };
        }).toList();
    await prefs.setString(_kunciPenyimpanan, jsonEncode(dataUntukDisimpan));
  }

  void _urutkanDanSimpan() {
    daftarLangganan.sort(
      (a, b) => (a['tanggalJatuhTempo'] as DateTime).compareTo(
        b['tanggalJatuhTempo'] as DateTime,
      ),
    );
    _simpanData();
  }

  int get totalPengeluaran {
    int total = 0;
    for (var item in daftarLangganan) {
      total += item['harga'] as int;
    }
    return total;
  }

  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // === DAFTAR MAPPING NAMA LAYANAN → SLUG ICON (200+ layanan populer dunia) ===
  String getIconSlug(String namaLayanan) {
    String n = namaLayanan.toLowerCase().replaceAll(' ', '');

    // === Streaming Video ===
    if (n.contains('netflix')) return 'netflix';
    if (n.contains('disney')) return 'disneyplus';
    if (n.contains('hbo') || n.contains('max')) return 'hbo';
    if (n.contains('primevideo') ||
        n.contains('amazonprime') ||
        n.contains('prime'))
      return 'amazonprimevideo';
    if (n.contains('vidio')) return 'vidio';
    if (n.contains('viu')) return 'viu';
    if (n.contains('iqiyi') || n.contains('iqyi')) return 'iqiyi';
    if (n.contains('appletv')) return 'appletv';
    if (n.contains('catchplay')) return 'catchplay';
    if (n.contains('hulu')) return 'hulu';
    if (n.contains('peacock')) return 'peacock';
    if (n.contains('paramount')) return 'paramountplus';
    if (n.contains('crunchyroll')) return 'crunchyroll';

    // === Musik & Audio ===
    if (n.contains('spotify')) return 'spotify';
    if (n.contains('youtubemusic') || n.contains('ytmusic'))
      return 'youtubemusic';
    if (n.contains('applemusic')) return 'applemusic';
    if (n.contains('joox')) return 'joox';
    if (n.contains('soundcloud')) return 'soundcloud';
    if (n.contains('tidal')) return 'tidal';
    if (n.contains('deezer')) return 'deezer';
    if (n.contains('audible')) return 'audible';
    if (n.contains('pandora')) return 'pandora';

    // === Video Sharing ===
    if (n.contains('youtube') || n == 'yt') return 'youtube';
    if (n.contains('tiktok')) return 'tiktok';
    if (n.contains('twitch')) return 'twitch';
    if (n.contains('vimeo')) return 'vimeo';
    if (n.contains('bilibili')) return 'bilibili';

    // === AI & Produktivitas AI ===
    if (n.contains('chatgpt') || n.contains('openai')) return 'openai';
    if (n.contains('gemini')) return 'googlegemini';
    if (n.contains('claude') || n.contains('anthropic')) return 'anthropic';
    if (n.contains('midjourney')) return 'midjourney';
    if (n.contains('copilot')) return 'githubcopilot';
    if (n.contains('perplexity')) return 'perplexity';
    if (n.contains('deepseek')) return 'deepseek';
    if (n.contains('runway')) return 'runway';
    if (n.contains('elevenlabs')) return 'elevenlabs';
    if (n.contains('stabilityai') || n.contains('stablediffusion'))
      return 'stabilityai';
    if (n.contains('huggingface')) return 'huggingface';

    // === Cloud & Storage ===
    if (n.contains('googledrive') || n.contains('gdrive')) return 'googledrive';
    if (n.contains('googleone')) return 'google';
    if (n.contains('icloud')) return 'icloud';
    if (n.contains('dropbox')) return 'dropbox';
    if (n.contains('onedrive')) return 'microsoftonedrive';
    if (n.contains('mega')) return 'mega';
    if (n.contains('box') && !n.contains('xbox') && !n.contains('inbox'))
      return 'box';

    // === Produktivitas / Kerja ===
    if (n.contains('canva')) return 'canva';
    if (n.contains('figma')) return 'figma';
    if (n.contains('notion')) return 'notion';
    if (n.contains('photoshop')) return 'adobephotoshop';
    if (n.contains('illustrator')) return 'adobeillustrator';
    if (n.contains('premiere')) return 'adobepremierepro';
    if (n.contains('adobe')) return 'adobe';
    if (n.contains('word')) return 'microsoftword';
    if (n.contains('excel')) return 'microsoftexcel';
    if (n.contains('powerpoint')) return 'microsoftpowerpoint';
    if (n.contains('office') || n.contains('microsoft365'))
      return 'microsoftoffice';
    if (n.contains('googleworkspace') || n.contains('gsuite')) return 'google';
    if (n.contains('slack')) return 'slack';
    if (n.contains('trello')) return 'trello';
    if (n.contains('asana')) return 'asana';
    if (n.contains('zoom')) return 'zoom';
    if (n.contains('grammarly')) return 'grammarly';
    if (n.contains('evernote')) return 'evernote';
    if (n.contains('linkedin')) return 'linkedin';
    if (n.contains('github')) return 'github';
    if (n.contains('gitlab')) return 'gitlab';
    if (n.contains('jira')) return 'jira';
    if (n.contains('miro')) return 'miro';
    if (n.contains('airtable')) return 'airtable';
    if (n.contains('clickup')) return 'clickup';
    if (n.contains('monday')) return 'mondaydotcom';

    // === Gaming - Platform ===
    if (n.contains('steam')) return 'steam';
    if (n.contains('playstation') ||
        n.contains('psplus') ||
        n.contains('ps5') ||
        n.contains('ps4') ||
        n.contains('psn'))
      return 'playstation';
    if (n.contains('xbox') || n.contains('gamepass')) return 'xbox';
    if (n.contains('nintendo') || n.contains('switch')) return 'nintendoswitch';
    if (n.contains('epicgames') || n.contains('epic')) return 'epicgames';
    if (n.contains('ea') || n.contains('eaplay') || n.contains('origin'))
      return 'ea';
    if (n.contains('ubisoft') || n.contains('uplay')) return 'ubisoft';
    if (n.contains('battlenet') || n.contains('blizzard'))
      return 'battledotnet';
    if (n.contains('rockstar')) return 'rockstargames';
    if (n.contains('gog')) return 'gogdotcom';
    if (n.contains('itchio') || n.contains('itch')) return 'itchdotio';

    // === Gaming - Battle Royale & Shooter ===
    if (n.contains('pubg')) return 'pubg';
    if (n.contains('fortnite')) return 'epicgames';
    if (n.contains('valorant')) return 'valorant';
    if (n.contains('riotgames') || n.contains('riot')) return 'riotgames';
    if (n.contains('leagueoflegends') || n.contains('lol'))
      return 'leagueoflegends';
    if (n.contains('callofduty') || n.contains('cod') || n.contains('warzone'))
      return 'callofduty';
    if (n.contains('freefire') || n.contains('ff')) return 'garena';
    if (n.contains('counterstrike') || n.contains('csgo') || n.contains('cs2'))
      return 'counterstrike';
    if (n.contains('overwatch')) return 'battledotnet';

    // === Gaming - Mobile & MOBA ===
    if (n.contains('mobilelegends') || n == 'ml' || n.contains('mlbb'))
      return 'garena';
    if (n.contains('genshin')) return 'hoyoverse';
    if (n.contains('hoyoverse') || n.contains('mihoyo') || n.contains('honkai'))
      return 'hoyoverse';
    if (n.contains('clashofclans') || n.contains('coc')) return 'clashofclans';
    if (n.contains('clashroyale')) return 'clashroyale';
    if (n.contains('brawlstars')) return 'brawlstars';
    if (n.contains('candycrush')) return 'candycrushsaga';
    if (n.contains('garena')) return 'garena';
    if (n.contains('roblox')) return 'roblox';
    if (n.contains('minecraft')) return 'minecraft';
    if (n.contains('amongus')) return 'amongus';
    if (n.contains('discordnitro')) return 'discord';

    // === Komunikasi ===
    if (n.contains('whatsapp')) return 'whatsapp';
    if (n.contains('telegram')) return 'telegram';
    if (n.contains('discord')) return 'discord';
    if (n.contains('line')) return 'line';
    if (n.contains('skype')) return 'skype';
    if (n.contains('signal')) return 'signal';

    // === Sosial Media ===
    if (n.contains('instagram')) return 'instagram';
    if (n.contains('facebook')) return 'facebook';
    if (n.contains('twitter') || n == 'x') return 'x';
    if (n.contains('snapchat')) return 'snapchat';
    if (n.contains('pinterest')) return 'pinterest';
    if (n.contains('reddit')) return 'reddit';
    if (n.contains('threads')) return 'threads';

    // === E-commerce & Marketplace ===
    if (n.contains('amazon')) return 'amazon';
    if (n.contains('shopee')) return 'shopee';
    if (n.contains('tokopedia')) return 'tokopedia';
    if (n.contains('lazada')) return 'lazada';
    if (n.contains('bukalapak')) return 'bukalapak';
    if (n.contains('ebay')) return 'ebay';
    if (n.contains('alibaba')) return 'alibabadotcom';

    // === Transportasi & Delivery ===
    if (n.contains('gojek')) return 'gojek';
    if (n.contains('grab')) return 'grab';
    if (n.contains('uber')) return 'uber';

    // === Keuangan / Fintech ===
    if (n.contains('paypal')) return 'paypal';
    if (n.contains('dana')) return 'dana';
    if (n.contains('ovo')) return 'ovo';
    if (n.contains('gopay')) return 'gojek';
    if (n.contains('flip')) return 'flip';
    if (n.contains('jenius')) return 'jenius';
    if (n.contains('stripe')) return 'stripe';

    // === Provider & Utilitas Indonesia ===
    if (n.contains('telkomsel')) return 'telkomsel';
    if (n.contains('indihome')) return 'indihome';
    if (n.contains('xl')) return 'xl';
    if (n.contains('indosat')) return 'indosatooredoo';
    if (n.contains('smartfren')) return 'smartfren';

    // Fallback: coba pakai nama apa adanya (tanpa spasi)
    return n;
  }

  // === Daftar slug yang FILE SVG-nya beneran ada di assets/logos/ ===
  static const Set<String> _slugTersedia = {
    'netflix',
    'disneyplus',
    'hbo',
    'amazonprimevideo',
    'vidio',
    'viu',
    'iqiyi',
    'appletv',
    'hulu',
    'peacock',
    'paramountplus',
    'crunchyroll',
    'spotify',
    'youtubemusic',
    'applemusic',
    'joox',
    'soundcloud',
    'tidal',
    'deezer',
    'audible',
    'pandora',
    'youtube',
    'tiktok',
    'twitch',
    'vimeo',
    'bilibili',
    'openai',
    'googlegemini',
    'anthropic',
    'midjourney',
    'githubcopilot',
    'perplexity',
    'deepseek',
    'runway',
    'elevenlabs',
    'stabilityai',
    'huggingface',
    'googledrive',
    'google',
    'icloud',
    'dropbox',
    'microsoftonedrive',
    'mega',
    'box',
    'canva',
    'figma',
    'notion',
    'adobephotoshop',
    'adobeillustrator',
    'adobepremierepro',
    'adobe',
    'microsoftword',
    'microsoftexcel',
    'microsoftpowerpoint',
    'microsoftoffice',
    'slack',
    'trello',
    'asana',
    'zoom',
    'grammarly',
    'evernote',
    'linkedin',
    'github',
    'gitlab',
    'jira',
    'miro',
    'airtable',
    'clickup',
    'mondaydotcom',
    'steam',
    'playstation',
    'xbox',
    'nintendoswitch',
    'epicgames',
    'ea',
    'ubisoft',
    'battledotnet',
    'rockstargames',
    'gogdotcom',
    'itchdotio',
    'pubg',
    'valorant',
    'riotgames',
    'leagueoflegends',
    'callofduty',
    'garena',
    'counterstrike',
    'hoyoverse',
    'clashofclans',
    'clashroyale',
    'brawlstars',
    'candycrushsaga',
    'roblox',
    'minecraft',
    'amongus',
    'discord',
    'whatsapp',
    'telegram',
    'line',
    'skype',
    'signal',
    'instagram',
    'facebook',
    'x',
    'snapchat',
    'pinterest',
    'reddit',
    'threads',
    'amazon',
    'shopee',
    'tokopedia',
    'lazada',
    'bukalapak',
    'ebay',
    'alibabadotcom',
    'gojek',
    'grab',
    'uber',
    'paypal',
    'dana',
    'ovo',
    'flip',
    'jenius',
    'stripe',
    'telkomsel',
    'indihome',
    'xl',
    'indosatooredoo',
    'smartfren',
  };

  Widget getLogoAsli(String namaLayanan) {
    String iconSlug = getIconSlug(namaLayanan);
    bool logoTersedia = _slugTersedia.contains(iconSlug);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            logoTersedia
                ? FutureBuilder<ByteData>(
                  future: DefaultAssetBundle.of(
                    context,
                  ).load('assets/logos/$iconSlug.svg'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox.shrink();
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.lengthInBytes < 50) {
                      return _logoDariCdn(namaLayanan, iconSlug);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/logos/$iconSlug.svg',
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                )
                : _logoDariCdn(namaLayanan, iconSlug),
      ),
    );
  }

  Widget _logoDariCdn(String namaLayanan, String iconSlug) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.network(
        'https://cdn.simpleicons.org/$iconSlug',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              namaLayanan.isNotEmpty ? namaLayanan[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
    );
  }

  void _bukaHalamanTambah({
    Map<String, dynamic>? itemUntukEdit,
    int? index,
  }) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HalamanTambahLangganan(itemUntukEdit: itemUntukEdit),
      ),
    );

    if (hasil == null) return;

    if (hasil is Map<String, dynamic>) {
      if (index != null) {
        final lama = daftarLangganan[index];
        await NotificationService().batalkanPengingat(
          lama['nama'],
          lama['tanggalJatuhTempo'],
        );
      }

      setState(() {
        if (index != null) {
          daftarLangganan[index] = hasil;
        } else {
          daftarLangganan.add(hasil);
        }
        _urutkanDanSimpan();
      });

      if (hasil['ingatkan'] == true) {
        await NotificationService().jadwalkanPengingat(
          nama: hasil['nama'],
          harga: hasil['harga'],
          tanggalJatuhTempo: hasil['tanggalJatuhTempo'],
        );
      }
    } else if (hasil == 'hapus' && index != null) {
      final item = daftarLangganan[index];
      await NotificationService().batalkanPengingat(
        item['nama'],
        item['tanggalJatuhTempo'],
      );
      setState(() {
        daftarLangganan.removeAt(index);
        _simpanData();
      });
    }
  }

  // === Cari item yang jatuh tempo pada tanggal tertentu (untuk Kalender) ===
  List<Map<String, dynamic>> _itemPadaTanggal(DateTime tanggal) {
    return daftarLangganan.where((item) {
      final d = item['tanggalJatuhTempo'] as DateTime;
      return d.year == tanggal.year &&
          d.month == tanggal.month &&
          d.day == tanggal.day;
    }).toList();
  }

  bool _adaTagihanPadaTanggal(DateTime tanggal) {
    return _itemPadaTanggal(tanggal).isNotEmpty;
  }

  void _gantiBulanKalender(int delta) {
    setState(() {
      _bulanKalenderAktif = DateTime(
        _bulanKalenderAktif.year,
        _bulanKalenderAktif.month + delta,
      );
      _tanggalTerpilihKalender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1115), Color(0xFF161922), Color(0xFF0A0C0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.9),
                      Colors.blueAccent.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'SakuLangganan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 22,
                ),
                tooltip: 'Tentang Aplikasi',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HalamanTentangAplikasi(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body:
            _sedangMemuat
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                )
                : Column(
                  children: [
                    // === CARD TOTAL BIAYA ===
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ChronicleCardBox(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TOTAL BIAYA LANGGANAN',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Rp ${formatRupiah(totalPengeluaran)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.blueAccent,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === TAB BAR: Daftar Langganan | Kalender ===
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blueAccent,
                          indicatorWeight: 2.5,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white38,
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.list_alt_rounded, size: 18),
                              text: 'Daftar Langganan',
                              height: 52,
                            ),
                            Tab(
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                              ),
                              text: 'Kalender',
                              height: 52,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // === ISI TAB ===
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTabDaftarLangganan(),
                          _buildTabKalender(),
                        ],
                      ),
                    ),
                  ],
                ),
        bottomNavigationBar: Container(
          height: 30,
          decoration: const BoxDecoration(color: Color(0xFF0A0C0E)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _fabMengecil ? 52 : 64,
            height: _fabMengecil ? 52 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(
                    _fabMengecil ? 0.25 : 0.4,
                  ),
                  blurRadius: _fabMengecil ? 12 : 20,
                  spreadRadius: _fabMengecil ? 1 : 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _bukaHalamanTambah(),
                child: Icon(
                  Icons.add,
                  size: _fabMengecil ? 24 : 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ), // <-- Tutup Scaffold
    ); // <-- Tutup Container utama (yang sebelumnya hilang)
  } // <-- Tutup build

  // ==========================================
  // TAB 1: DAFTAR LANGGANAN
  // ==========================================
  Widget _buildTabDaftarLangganan() {
    if (daftarLangganan.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollControllerDaftar,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: daftarLangganan.length,
      itemBuilder: (context, index) {
        final item = daftarLangganan[index];
        final DateTime tanggal = item['tanggalJatuhTempo'];
        final DateTime hariIni = DateTime.now();

        final String periode =
            item['periode'] ?? tentukanPeriodeTagihan(tanggal);

        final int sisaHari =
            tanggal
                .difference(DateTime(hariIni.year, hariIni.month, hariIni.day))
                .inDays;
        final bool isBahaya = sisaHari <= 3;

        return Dismissible(
          key: Key(item['nama'] + tanggal.toIso8601String()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 24),
          ),
          onDismissed: (direction) {
            final itemDihapus = item;
            final indexDihapus = index;

            setState(() {
              daftarLangganan.removeAt(indexDihapus);
              _simpanData();
            });

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  SnackBar(
                    content: Text('Tagihan "${itemDihapus['nama']}" dihapus'),
                    backgroundColor: const Color(0xFF161922),
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.blueAccent,
                      onPressed: () {
                        setState(() {
                          daftarLangganan.insert(indexDihapus, itemDihapus);
                          _urutkanDanSimpan();
                        });
                        if (itemDihapus['ingatkan'] == true) {
                          NotificationService().jadwalkanPengingat(
                            nama: itemDihapus['nama'],
                            harga: itemDihapus['harga'],
                            tanggalJatuhTempo: itemDihapus['tanggalJatuhTempo'],
                          );
                        }
                      },
                    ),
                  ),
                )
                .closed
                .then((reason) {
                  if (reason != SnackBarClosedReason.action) {
                    NotificationService().batalkanPengingat(
                      itemDihapus['nama'],
                      itemDihapus['tanggalJatuhTempo'],
                    );
                  }
                });
          },
          child: ChronicleCardBox(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () => _bukaHalamanTambah(itemUntukEdit: item, index: index),
            child: Row(
              children: [
                getLogoAsli(item['nama']),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isBahaya ? Colors.redAccent : Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tanggal.day} ${namaBulan(tanggal.month)} • Sisa $sisaHari hari',
                            style: TextStyle(
                              color:
                                  isBahaya ? Colors.redAccent : Colors.white38,
                              fontSize: 12,
                              fontWeight:
                                  isBahaya
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${formatRupiah(item['harga'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      periode == 'Tahunan' ? '/tahun' : '/bulan',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isBahaya
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBahaya ? 'Mendekati Batas' : 'Aktif',
                        style: TextStyle(
                          color:
                              isBahaya ? Colors.redAccent : Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Align(
      alignment: const Alignment(0.0, -0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 15),
            const Text(
              'Ayo atur langgananmu!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Catat aplikasi atau tagihan langgananmu di sini. Kami bantu pantau biayanya, biar saldo rekeningmu nggak kepotong otomatis tanpa disadari!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: KALENDER
  // ==========================================
  Widget _buildTabKalender() {
    final DateTime bulan = _bulanKalenderAktif;
    final DateTime awalBulan = DateTime(bulan.year, bulan.month, 1);
    final int jumlahHari = DateTime(bulan.year, bulan.month + 1, 0).day;
    // Senin = 1 ... Minggu = 7 -> offset supaya grid mulai dari Senin
    final int offsetHariPertama = awalBulan.weekday - 1;
    final DateTime hariIni = DateTime.now();

    const namaHariSingkat = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final List<Map<String, dynamic>> itemTerpilih =
        _tanggalTerpilihKalender != null
            ? _itemPadaTanggal(_tanggalTerpilihKalender!)
            : [];

    return ListView(
      controller: _scrollControllerKalender,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        ChronicleCardBox(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Navigasi bulan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _gantiBulanKalender(-1),
                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                  ),
                  Text(
                    '${namaBulan(bulan.month)} ${bulan.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _gantiBulanKalender(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Header nama hari
              Row(
                children:
                    namaHariSingkat
                        .map(
                          (h) => Expanded(
                            child: Center(
                              child: Text(
                                h,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 6),
              // Grid tanggal
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offsetHariPertama + jumlahHari,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < offsetHariPertama) {
                    return const SizedBox.shrink();
                  }
                  final int tanggalNum = index - offsetHariPertama + 1;
                  final DateTime tanggalSel = DateTime(
                    bulan.year,
                    bulan.month,
                    tanggalNum,
                  );
                  final bool adaTagihan = _adaTagihanPadaTanggal(tanggalSel);
                  final bool isHariIni =
                      tanggalSel.year == hariIni.year &&
                      tanggalSel.month == hariIni.month &&
                      tanggalSel.day == hariIni.day;
                  final bool isTerpilih =
                      _tanggalTerpilihKalender != null &&
                      _tanggalTerpilihKalender!.year == tanggalSel.year &&
                      _tanggalTerpilihKalender!.month == tanggalSel.month &&
                      _tanggalTerpilihKalender!.day == tanggalSel.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tanggalTerpilihKalender = tanggalSel;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color:
                            isTerpilih
                                ? Colors.blueAccent
                                : isHariIni
                                ? Colors.blueAccent.withOpacity(0.15)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            isHariIni && !isTerpilih
                                ? Border.all(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                )
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$tanggalNum',
                            style: TextStyle(
                              color: isTerpilih ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight:
                                  isHariIni || isTerpilih
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (adaTagihan)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isTerpilih
                                          ? Colors.white
                                          : Colors.redAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_tanggalTerpilihKalender != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'TAGIHAN TANGGAL ${_tanggalTerpilihKalender!.day} ${namaBulan(_tanggalTerpilihKalender!.month)}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (itemTerpilih.isEmpty)
            ChronicleCardBox(
              child: const Text(
                'Tidak ada tagihan pada tanggal ini.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            ...itemTerpilih.map((item) {
              final int idxAsli = daftarLangganan.indexOf(item);
              return ChronicleCardBox(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                onTap:
                    () => _bukaHalamanTambah(
                      itemUntukEdit: item,
                      index: idxAsli >= 0 ? idxAsli : null,
                    ),
                child: Row(
                  children: [
                    getLogoAsli(item['nama']),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item['nama'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'Rp ${formatRupiah(item['harga'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Tap salah satu tanggal untuk lihat tagihannya 👆',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  String namaBulan(int bulan) {
    const daftarBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return daftarBulan[bulan - 1];
  }
}

// ==========================================
// HALAMAN 2: FORM TAMBAH / EDIT LANGGANAN
// ==========================================
class HalamanTambahLangganan extends StatefulWidget {
  final Map<String, dynamic>? itemUntukEdit;

  const HalamanTambahLangganan({super.key, this.itemUntukEdit});

  @override
  State<HalamanTambahLangganan> createState() => _HalamanTambahLanggananState();
}

class _HalamanTambahLanggananState extends State<HalamanTambahLangganan> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  DateTime? _tanggalPilihan;
  bool _ingatkanH1 = true;
  String? _pesanErrorHarga;

  bool get _sedangEdit => widget.itemUntukEdit != null;

  @override
  void initState() {
    super.initState();
    if (_sedangEdit) {
      final item = widget.itemUntukEdit!;
      _namaController.text = item['nama'];
      final String hargaFormatted = item['harga'].toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      _hargaController.text = hargaFormatted;
      _tanggalPilihan = item['tanggalJatuhTempo'];
      _ingatkanH1 = item['ingatkan'] ?? true;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _tanggalPilihan ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF161922),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalPilihan = picked;
      });
    }
  }

  int? _validasiDanParseHarga() {
    final teksMentah = _hargaController.text.trim();
    final teks = teksMentah.replaceAll('.', ''); // buang titik ribuan

    if (teks.isEmpty) {
      setState(() => _pesanErrorHarga = 'Jumlah tagihan wajib diisi');
      return null;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(teks)) {
      setState(
        () => _pesanErrorHarga = 'Masukkan angka saja, tanpa titik/koma/huruf',
      );
      return null;
    }

    final angka = int.tryParse(teks);
    if (angka == null || angka <= 0) {
      setState(() => _pesanErrorHarga = 'Jumlah tagihan harus lebih dari 0');
      return null;
    }

    setState(() => _pesanErrorHarga = null);
    return angka;
  }

  void _simpanData() {
    final namaValid = _namaController.text.trim().isNotEmpty;
    final harga = _validasiDanParseHarga();

    if (!namaValid || harga == null || _tanggalPilihan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data tagihan dengan benar terlebih dahulu!'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'nama': _namaController.text.trim(),
      'harga': harga,
      'tanggalJatuhTempo': _tanggalPilihan,
      'ingatkan': _ingatkanH1,
      'periode': tentukanPeriodeTagihan(_tanggalPilihan!),
    });
  }

  void _hapusData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF161922),
            title: const Text(
              'Hapus Tagihan?',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Yakin mau hapus "${_namaController.text}" dari daftar?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'hapus');
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildChronicleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType type = TextInputType.text,
    String? errorText,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1115), Color(0xFF161922), Color(0xFF0A0C0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _sedangEdit ? 'Edit Tagihan' : 'Tambah Tagihan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_sedangEdit)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Hapus tagihan',
                onPressed: _hapusData,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChronicleTextField(
                controller: _namaController,
                label: 'Nama Layanan / Tagihan',
                hint: 'Contoh: Netflix, Spotify, PLN',
              ),
              const SizedBox(height: 16),
              _buildChronicleTextField(
                controller: _hargaController,
                label: 'Jumlah Tagihan (Rp)',
                hint: 'Contoh: 150.000',
                type: TextInputType.number,
                errorText: _pesanErrorHarga,
                inputFormatters: [RupiahInputFormatter()],
                onChanged: (_) {
                  if (_pesanErrorHarga != null) {
                    setState(() => _pesanErrorHarga = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pilihTanggal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tanggalPilihan == null
                            ? 'Pilih Tanggal Jatuh Tempo...'
                            : 'Jatuh Tempo: ${_tanggalPilihan!.day}/${_tanggalPilihan!.month}/${_tanggalPilihan!.year}',
                        style: TextStyle(
                          color:
                              _tanggalPilihan == null
                                  ? Colors.white38
                                  : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              if (_tanggalPilihan != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Terdeteksi sebagai tagihan: ${tentukanPeriodeTagihan(_tanggalPilihan!)}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ChronicleCardBox(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ingatkan H-1 sebelum jatuh tempo',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Switch(
                      value: _ingatkanH1,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      onChanged: (val) {
                        setState(() {
                          _ingatkanH1 = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _sedangEdit ? 'Simpan Perubahan' : 'Simpan Tagihan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN 3: TENTANG APLIKASI
// ==========================================
class HalamanTentangAplikasi extends StatelessWidget {
  const HalamanTentangAplikasi({super.key});

  Future<void> _downloadApk() async {
  final Uri url = Uri.parse(
    'https://saku-langganan.vercel.app/downloads/saku-langganan.apk',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Gagal membuka link download APK');
  }
}

  Widget _buildFiturItem(IconData icon, String judul, String deskripsi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deskripsi,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1115), Color(0xFF161922), Color(0xFF0A0C0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Tentang Aplikasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.9),
                          Colors.blueAccent.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SakuLangganan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ChronicleCardBox(
              margin: const EdgeInsets.only(bottom: 20),
              child: const Text(
                'SakuLangganan membantu kamu memantau semua tagihan langganan '
                'seperti streaming, musik, hingga aplikasi produktivitas dalam '
                'satu tempat. Dilengkapi dengan pengingat sebelum jatuh tempo agar '
                'saldo rekeningmu tidak terpotong otomatis tanpa disadari.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'FITUR UTAMA',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ChronicleCardBox(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildFiturItem(
                    Icons.account_balance_wallet,
                    'Ringkasan Total Biaya',
                    'Pantau total pengeluaran langganan tiap bulan.',
                  ),
                  _buildFiturItem(
                    Icons.notifications_active_outlined,
                    'Pengingat Jatuh Tempo',
                    'Dapatkan pengingat H-1 sebelum tagihan jatuh tempo.',
                  ),
                  _buildFiturItem(
                    Icons.calendar_month_rounded,
                    'Tampilan Kalender',
                    'Lihat semua tagihan dalam bentuk kalender bulanan, tap tanggal untuk melihat detailnya.',
                  ),
                  _buildFiturItem(
                    Icons.autorenew,
                    'Deteksi & Perbarui Periode Otomatis',
                    'Sistem otomatis mendeteksi dan memperbarui tagihan bulanan/tahunan yang lewat.',
                  ),
                  _buildFiturItem(
                    Icons.edit_outlined,
                    'Edit & Kelola Tagihan',
                    'Tap tagihan untuk mengedit, atau geser untuk menghapus.',
                  ),
                  _buildFiturItem(
                    Icons.save_outlined,
                    'Data Tersimpan Otomatis',
                    'Data tagihan tersimpan di perangkat, aman meski app ditutup.',
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DEVELOPER',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ChronicleCardBox(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white70),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kemal Pramayuda | Virzan Pasha Nugraha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'kemalpramayuda10@gmail.com',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _downloadApk,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Unduh APK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                '© 2026 Kemal Pramayuda & Virzan Pasha Nugraha',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
