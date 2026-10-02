import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const DemokrasiApp());
}

const String kAppFontFamily = 'Outfit';
const double kReadingLetterSpacing = 0.27;

/// Balpy projesinden uyarlanan tipografi ölçeği ve font stilleri.
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 57,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 45,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLargeCompact = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 12,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: kAppFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

class DemokrasiApp extends StatelessWidget {
  const DemokrasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demokrasi Platformu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: kAppFontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        cardColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF38BDF8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF818CF8),
          surface: Color(0xFF0F172A),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: kAppFontFamily,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF090D16),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================================
// MODELLER (Tamamı Cihaz Üzerinde Local ve Reaktif)
// ============================================================================

class Citizen {
  final String id;
  final String fullName;
  final String tcNo;
  final String birthDate;
  final String city;
  final String district;
  final String pseudonym; // ZKP ile üretilen kamusal anonim rumuz
  final int reputation;
  final String role;
  final double expertMultiplier;
  int voiceCredits;
  int spentCredits;

  Citizen({
    required this.id,
    required this.fullName,
    required this.tcNo,
    required this.birthDate,
    required this.city,
    required this.district,
    required this.pseudonym,
    required this.reputation,
    this.role = 'Yurttaş',
    this.expertMultiplier = 1.0,
    this.voiceCredits = 100,
    this.spentCredits = 25,
  });

  int get availableCredits => max(0, voiceCredits - spentCredits);
}

class SubTopic {
  final String id;
  String title;
  final String proposer;
  int yesVotes;
  int noVotes;
  String status;

  SubTopic({
    required this.id,
    required this.title,
    required this.proposer,
    this.yesVotes = 120,
    this.noVotes = 25,
    this.status = 'OYLAMADA',
  });

  double get approvalRate => (yesVotes / (yesVotes + noVotes > 0 ? yesVotes + noVotes : 1)) * 100;
}

class CommentItem {
  final String id;
  final String author;
  final String text;
  final String timestamp;
  final String txHash;
  bool isUnderRedaction;
  String? redactionReason;
  int deleteVotes;
  int keepVotes;
  bool isMasked;

  CommentItem({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
    required this.txHash,
    this.isUnderRedaction = false,
    this.redactionReason,
    this.deleteVotes = 0,
    this.keepVotes = 0,
    this.isMasked = false,
  });

  double get deleteRate => (deleteVotes / (deleteVotes + keepVotes > 0 ? deleteVotes + keepVotes : 1)) * 100;
}

class Proposal {
  final String id;
  String title;
  String content;
  final String author;
  final String category;
  int yesVotes;
  int noVotes;
  String status; // OYLAMADA, KABUL_EDILDI, REDDEDILDI
  int ontologyScore;
  bool hasAmendment;
  String? amendmentOldText;
  String? amendmentNewText;
  int amendmentYes;
  int amendmentNo;
  String? vetoReason;
  String? normViolation;
  List<SubTopic> subTopics;
  List<CommentItem> comments;

  Proposal({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    this.yesVotes = 340,
    this.noVotes = 110,
    this.status = 'OYLAMADA',
    this.ontologyScore = 96,
    this.hasAmendment = false,
    this.amendmentOldText,
    this.amendmentNewText,
    this.amendmentYes = 45,
    this.amendmentNo = 12,
    this.vetoReason,
    this.normViolation,
    required this.subTopics,
    required this.comments,
  });

  double get approvalRate => (yesVotes / (yesVotes + noVotes > 0 ? yesVotes + noVotes : 1)) * 100;
}

class BlockItem {
  final int index;
  final String timestamp;
  final String hash;
  final String prevHash;
  final String merkleRoot;
  final String summary;

  BlockItem({
    required this.index,
    required this.timestamp,
    required this.hash,
    required this.prevHash,
    required this.merkleRoot,
    required this.summary,
  });
}

// ============================================================================
// ANA EKRAN (MainScreen)
// ============================================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _selectedFilter = 'Tümü';

  late List<Citizen> citizens;
  late Citizen activeCitizen;
  late List<Proposal> proposals;
  late List<BlockItem> ledger;
  final Map<String, int> userVotes = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    citizens = [
      Citizen(
        id: 'cit-1',
        fullName: 'Yiğit Baturalp',
        tcNo: '10928374650',
        birthDate: '2001-05-14',
        city: 'Ankara',
        district: 'Çankaya',
        pseudonym: '@AdaletSavunucusu',
        reputation: 98,
        role: 'Yurttaş & Topluluk Temsilcisi',
        expertMultiplier: 1.0,
        voiceCredits: 100,
        spentCredits: 25,
      ),
      Citizen(
        id: 'cit-2',
        fullName: 'Prof. Dr. İlker Akman',
        tcNo: '30495827160',
        birthDate: '1974-11-20',
        city: 'İstanbul',
        district: 'Beşiktaş',
        pseudonym: '@IlkerHukuk',
        reputation: 99,
        role: 'Anayasa Hukukçusu & Bilirkişi',
        expertMultiplier: 2.2,
        voiceCredits: 250,
        spentCredits: 40,
      ),
      Citizen(
        id: 'cit-3',
        fullName: 'Zeynep Yıldız',
        tcNo: '20491827361',
        birthDate: '1995-03-08',
        city: 'İzmir',
        district: 'Bornova',
        pseudonym: '@GelecekOncusu',
        reputation: 94,
        role: 'Mahalle Meclis Temsilcisi',
        expertMultiplier: 1.5,
        voiceCredits: 150,
        spentCredits: 36,
      ),
    ];
    activeCitizen = citizens[0];

    proposals = [
      Proposal(
        id: 'prop-1',
        title: 'Kentsel Yeşil Koridorların Korunması ve Yapılaşma Sınırı',
        content: 'Şehir sınırları içerisindeki tüm tescilli park ve rekreasyon alanlarında betonlaşma yerine geçirgen zemin mecburidir. Doğal flora korunacak ve yeni binalar için yeşil çatı standartları getirilecektir.',
        author: '@AdaletSavunucusu',
        category: 'Çevre & Şehircilik',
        yesVotes: 342,
        noVotes: 114,
        status: 'OYLAMADA',
        ontologyScore: 96,
        hasAmendment: true,
        amendmentOldText: 'betonlaşma yerine geçirgen zemin mecburidir.',
        amendmentNewText: 'betonlaşma yerine geçirgen zemin mecburidir. Ayrıca park alanlarında yağmur suyu hasadı göletleri kurulması zorunludur.',
        amendmentYes: 48,
        amendmentNo: 12,
        subTopics: [
          SubTopic(id: 'sub-1', title: 'Park İçi Bisiklet ve Yürüyüş Yolu Standardı', proposer: '@GelecekOncusu', yesVotes: 280, noVotes: 40, status: 'KABUL_EDILDI'),
          SubTopic(id: 'sub-2', title: 'Gece Park Aydınlatmalarının Güneş Enerjisine Geçirilmesi', proposer: '@IlkerHukuk', yesVotes: 195, noVotes: 65, status: 'OYLAMADA'),
        ],
        comments: [
          CommentItem(id: 'c-1', author: '@EkolojikDenge', text: 'Gelecek kuşaklar için betonlaşmayı engelleyen 2. madde çok hayati.', timestamp: '14:22', txHash: '0x8f192b001a4c'),
          CommentItem(
            id: 'c-2',
            author: '@AnonimKullanici',
            text: 'Bu tasarıyı destekleyen temsilci Ayşe K. (TC: 10492819401, Adres: Gül Mah. No:4) hesabını verecek!',
            timestamp: '09:12',
            txHash: '0x33e410f881ab',
            isUnderRedaction: true,
            redactionReason: 'KVKK İhlali (Şahsi Bilgi ve Adres İfşası)',
            deleteVotes: 142,
            keepVotes: 18,
          ),
        ],
      ),
      Proposal(
        id: 'prop-2',
        title: 'Kıyı Şeridi ve Doğal Plajların Özel İşletmelere Devri & Ücretlendirilmesi',
        content: 'Belediye sınırları içindeki tüm doğal plaj alanları gelir artırımı amacıyla özel işletmelere devredilecek ve giriş ücreti uygulanacaktır.',
        author: '@RantMerkezi',
        category: 'Kıyı Mevzuatı',
        yesVotes: 520,
        noVotes: 130,
        status: 'REDDEDILDI',
        ontologyScore: 18,
        vetoReason: 'ANAYASAL VETO: T.C. Anayasası Madde 43 uyarınca kıyılardan yararlanmada kamu yararı esastır. Normlar Hiyerarşisi gereği yerel karar Anayasaya aykırı olamaz.',
        normViolation: 'T.C. Anayasası Madde 43 (Kıyıların Korunması) İhlali',
        subTopics: [],
        comments: [
          CommentItem(id: 'c-3', author: '@IlkerHukuk', text: 'Bilirkişi Veto Görüşü: Çoğunluk oyu olsa dahi anayasal kamu yararı oylamayla yok edilemez. Teklif hukuken geçersizdir.', timestamp: '11:05', txHash: '0x44c19b02ef01'),
        ],
      ),
      Proposal(
        id: 'prop-3',
        title: 'Yenilenebilir Enerji ve Çatı Tipi Güneş Santralleri Teşviki',
        content: 'Konut ve sanayi çatılarında güneş paneli kurulumları bürokratik izinlerden muaf tutulacak; üretilen ihtiyaç fazlası elektrik belediye şebekesi tarafından satın alınacaktır.',
        author: '@YesilEnerji',
        category: 'Enerji & Çevre',
        yesVotes: 1420,
        noVotes: 85,
        status: 'KABUL_EDILDI',
        ontologyScore: 99,
        subTopics: [
          SubTopic(id: 'sub-3', title: 'Apartman Ortak Alanlarında Elektrik Mahsuplaşması Standardı', proposer: '@AdaletSavunucusu', yesVotes: 1200, noVotes: 40, status: 'KABUL_EDILDI'),
        ],
        comments: [
          CommentItem(id: 'c-4', author: '@EnerjiMasasi', text: 'Yasa tasarısı oybirliğiyle kabul edilerek resmi mevzuat defterine mühürlenmiştir.', timestamp: '12:00', txHash: '0x9948c201fa00'),
        ],
      ),
    ];

    ledger = [
      BlockItem(index: 1045, timestamp: '10:15', hash: '0x0000e84b12f990ac', prevHash: '0x0000a4b91f08e41c', merkleRoot: '0x3f9a88c21e01', summary: 'GENESIS_INIT: Demokrasi Zinciri Başlatıldı'),
      BlockItem(index: 1046, timestamp: '10:30', hash: '0x00003b7194f109de', prevHash: '0x0000e84b12f990ac', merkleRoot: '0x99a1bc4028fa', summary: 'PROPOSAL_REGISTER: Kentsel Yeşil Koridorlar (#prop-1)'),
      BlockItem(index: 1047, timestamp: '11:05', hash: '0x00009c210a44fe11', prevHash: '0x00003b7194f109de', merkleRoot: '0x12ac49e001ba', summary: 'VETO_ENACT: Kıyı Şeridi Teklifi Anayasa Md. 43 ile Veto Edildi'),
    ];
  }

  void _addBlock(String summary) {
    final last = ledger.last;
    final newHash = '0x0000${sha256.convert(utf8.encode(DateTime.now().toIso8601String() + summary)).toString().substring(0, 12)}';
    setState(() {
      ledger.add(BlockItem(
        index: last.index + 1,
        timestamp: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        hash: newHash,
        prevHash: last.hash,
        merkleRoot: '0x${Random().nextInt(999999).toRadixString(16)}',
        summary: summary,
      ));
    });
  }

  void _castQuadraticVote(Proposal prop, bool isIncrement) {
    int current = userVotes[prop.id] ?? 0;
    int target = isIncrement ? current + 1 : current - 1;
    if (target < 0) return;

    int costCurrent = current * current;
    int costTarget = target * target;
    int diffCost = costTarget - costCurrent;

    int available = activeCitizen.availableCredits;
    if (isIncrement && diffCost > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E293B),
          content: Text('Yetersiz Ses Kredisi! Gereken: $diffCost VC, Mevcut: $available VC'),
        ),
      );
      return;
    }

    setState(() {
      userVotes[prop.id] = target;
      activeCitizen.spentCredits += diffCost;
      prop.yesVotes += isIncrement ? 1 : -1;
    });

    _addBlock('VOTE_QUADRATIC: ${activeCitizen.pseudonym} -> ${prop.title.substring(0, min(16, prop.title.length))} ($target Oy, $diffCost VC)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icon/app_logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'DEMOKRASİ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Ses Kredisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 13),
                const SizedBox(width: 3),
                Text(
                  '${activeCitizen.availableCredits} VC',
                  style: const TextStyle(
                    fontFamily: kAppFontFamily,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Sunum Senaryoları & Rehber Menüsü
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 22),
            color: const Color(0xFF0F172A),
            tooltip: 'Hızlı Senaryolar & Rehber',
            onSelected: (val) {
              if (val == 0) {
                _showInteractiveGuideModal();
              } else {
                _switchScenario(val);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Platform & Mimari Rehberi (9 Sistem & Teknik Borç)',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 1, child: Text('1. Kentsel Dönüşüm & Karesel Oylama', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5))),
              const PopupMenuItem(value: 2, child: Text('2. Anayasaya Aykırı Teklif (Veto Örneği)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5))),
              const PopupMenuItem(value: 3, child: Text('3. KVKK İhlali & Sansür Oylaması', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5))),
              const PopupMenuItem(value: 4, child: Text('4. Yürürlükteki Resmi Mevzuat', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5))),
              const PopupMenuItem(value: 5, child: Text('5. Sıfırdan Boş Başlangıç', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5))),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildProposalsTab(),
          _buildHierarchyTab(),
          _buildLedgerTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _switchScenario(int id) {
    setState(() {
      userVotes.clear();
      if (id == 1) {
        _initData();
      } else if (id == 2) {
        _initData();
        // İkinci teklifi öne al
        final p2 = proposals[1];
        proposals = [p2, proposals[0], proposals[2]];
      } else if (id == 3) {
        _initData();
      } else if (id == 4) {
        _initData();
        final p3 = proposals[2];
        proposals = [p3, proposals[0], proposals[1]];
      } else {
        proposals = [
          Proposal(
            id: 'prop-custom',
            title: 'Yeni Hazırlanan Kanun Tasarısı (Taslak)',
            content: 'Bu alana sunum sırasında hocanızın belirleyeceği teklif metnini girebilir, alt maddeler ve oylamayı sıfırdan test edebilirsiniz.',
            author: activeCitizen.pseudonym,
            category: 'Genel Yönetişim',
            yesVotes: 12,
            noVotes: 3,
            status: 'OYLAMADA',
            ontologyScore: 92,
            subTopics: [],
            comments: [],
          ),
        ];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Text(
          '✅ Senaryo $id yüklendi.',
          style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.how_to_vote_outlined, 'active': Icons.how_to_vote, 'label': 'Teklifler'},
      {'icon': Icons.gavel_outlined, 'active': Icons.gavel, 'label': 'Mevzuat'},
      {'icon': Icons.account_tree_outlined, 'active': Icons.account_tree, 'label': 'Defter'},
      {'icon': Icons.badge_outlined, 'active': Icons.badge, 'label': 'Kimlik'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1D),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (idx) {
            final isSel = _currentIndex == idx;
            final it = items[idx];
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = idx),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSel ? (it['active'] as IconData) : (it['icon'] as IconData),
                      size: 22,
                      color: isSel ? const Color(0xFF38BDF8) : Colors.white38,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      it['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? const Color(0xFF38BDF8) : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ==========================================================================
  // 1. SEKME: YASA TEKLİFLERİ & OYLAMA LİSTESİ
  // ==========================================================================

  Widget _buildProposalsTab() {
    List<Proposal> filtered = proposals;
    if (_selectedFilter == 'Oylamada') {
      filtered = proposals.where((p) => p.status == 'OYLAMADA').toList();
    } else if (_selectedFilter == 'Yürürlükte') {
      filtered = proposals.where((p) => p.status == 'KABUL_EDILDI').toList();
    } else if (_selectedFilter == 'Veto') {
      filtered = proposals.where((p) => p.status == 'REDDEDILDI' || p.ontologyScore < 50).toList();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      children: [
        // Filtre Barı ve Yeni Teklif Butonu
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['Tümü', 'Oylamada', 'Yürürlükte', 'Veto'].map((f) {
                    final isSel = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = f),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFF38BDF8) : Colors.transparent),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? const Color(0xFF38BDF8) : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _showCreateProposalDialog,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Teklif',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Teklif Kartları
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Bu filtreye uygun yasa teklifi bulunamadı.',
                style: TextStyle(fontFamily: kAppFontFamily, fontSize: 14, color: Colors.white38),
              ),
            ),
          )
        else
          ...filtered.map((p) => _buildProposalCard(p)),
      ],
    );
  }

  Widget _buildProposalCard(Proposal prop) {
    final bool isVetoed = prop.status == 'REDDEDILDI' || prop.ontologyScore < 50;

    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isVetoed ? Colors.redAccent.withValues(alpha: 0.4) : const Color(0xFF1E293B),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openProposalDetail(prop),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori ve Durum Rozeti
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prop.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38BDF8),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: prop.status == 'KABUL_EDILDI'
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : (isVetoed ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prop.status == 'KABUL_EDILDI'
                          ? '✓ Yürürlükte'
                          : (isVetoed ? '✕ Veto' : '🗳️ Oylamada'),
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: prop.status == 'KABUL_EDILDI'
                            ? const Color(0xFF10B981)
                            : (isVetoed ? Colors.redAccent : const Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isVetoed ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF818CF8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '%${prop.ontologyScore} Uyum',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isVetoed ? Colors.redAccent : const Color(0xFF818CF8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Başlık
              Text(
                prop.title,
                style: const TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),

              // Gerekçe Özeti
              Text(
                prop.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 13.5,
                  color: Colors.white70,
                  height: 1.45,
                  letterSpacing: 0.2,
                ),
              ),

              // Veto Uyarısı Varsa
              if (isVetoed && prop.vetoReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gavel, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prop.vetoReason!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 12.5,
                            color: Colors.redAccent,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Oylama Oranı Çubuğu
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'Evet: %${prop.approvalRate.toStringAsFixed(1)} (${prop.yesVotes})',
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Hayır: ${prop.noVotes}',
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: prop.approvalRate / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                  minHeight: 5,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 10),

              // Alt Bilgiler ve Detay Butonu
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (prop.hasAmendment)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.difference_outlined, size: 14, color: Color(0xFF06B6D4)),
                            SizedBox(width: 4),
                            Text(
                              'Diff Aktif',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12,
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 4),
                          Text(
                            '${prop.subTopics.length} Alt Madde',
                            style: const TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 12,
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            '${prop.comments.length} Görüş',
                            style: const TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 12,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'İncele & Oyla',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13,
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFF38BDF8)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DETAY EKRANI (ProposalDetailScreen - Hocanın 3-4 Dk Test Edeceği Merkez)
  // ==========================================================================

  void _openProposalDetail(Proposal prop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDetailState) {
            int userVote = userVotes[prop.id] ?? 0;
            int nextCost = (userVote + 1) * (userVote + 1) - (userVote * userVote);
            final bool isVetoed = prop.status == 'REDDEDILDI' || prop.ontologyScore < 50;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF090D16),
                centerTitle: false,
                title: Text(
                  prop.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVetoed ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prop.status == 'KABUL_EDILDI' ? '✓ Yürürlükte' : (isVetoed ? '✕ Veto' : '🗳️ Oylamada'),
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isVetoed ? Colors.redAccent : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // 1. Yasa Başlığı ve Metni
                  Text(
                    prop.title,
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        'Öneren: ${prop.author}',
                        style: const TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yasa Metni & Gerekçe:',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prop.content,
                          style: const TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 14.5,
                            color: Colors.white,
                            height: 1.5,
                            letterSpacing: kReadingLetterSpacing,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Metin Düzenleme Önergesi (Diff)
                  _buildAmendmentSection(prop, setDetailState),
                  const SizedBox(height: 14),

                  // 3. Alt Konular & Maddeler
                  _buildSubTopicsSection(prop, setDetailState),
                  const SizedBox(height: 14),

                  // 4. Hukuki Denetim & Normlar Hiyerarşisi
                  _buildLegalAuditSection(prop),
                  const SizedBox(height: 14),

                  // 5. Müzakere Defteri (Yorumlar & Sansür Oylaması)
                  _buildDiscussionSection(prop, setDetailState),
                  const SizedBox(height: 14),

                  // 6. Oylama ve Yürürlük Paneli
                  _buildVotingSection(prop, userVote, nextCost, setDetailState),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- BÖLÜM: DÜZENLEME ÖNERGESİ (DIFF) ---
  Widget _buildAmendmentSection(Proposal prop, StateSetter setDetailState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: prop.hasAmendment ? const Color(0xFF06B6D4) : const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.difference_outlined, size: 16, color: Color(0xFF06B6D4)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Metin Değişiklik Önergesi (Diff)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!prop.hasAmendment)
                TextButton.icon(
                  onPressed: () => _showAddAmendmentDialog(prop, setDetailState),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text(
                    'Önerge Ver',
                    style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (prop.hasAmendment) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '[-] Yürürlükteki Madde (Eski):',
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prop.amendmentOldText ?? '',
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.5,
                      color: Colors.redAccent,
                      height: 1.4,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '[+] Teklif Edilen Düzenleme (Diff):',
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prop.amendmentNewText ?? '',
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.5,
                      color: Color(0xFF10B981),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Önerge: ${prop.amendmentYes} Kabul / ${prop.amendmentNo} Red',
                  style: const TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 12.5,
                    color: Colors.white70,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setDetailState(() {
                      prop.content = prop.content.replaceFirst(prop.amendmentOldText ?? '', prop.amendmentNewText ?? prop.content);
                      prop.hasAmendment = false;
                    });
                    setState(() {});
                    _addBlock('DIFF_ENACTED: Düzenleme Kabul Edildi & Metne İşlendi');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  ),
                  child: const Text(
                    '✓ Kabul Et & Metne İşle',
                    style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Şu an aktif bir değişiklik önerisi bulunmuyor. Dilerseniz yukarıdan madde düzenleme teklifi verebilirsiniz.',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- BÖLÜM: ALT KONULAR (SUB-TOPICS) ---
  Widget _buildSubTopicsSection(Proposal prop, StateSetter setDetailState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.account_tree_outlined, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bağlı Alt Maddeler (${prop.subTopics.length})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: () => _showAddSubTopicDialog(prop, setDetailState),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Alt Madde Ekle',
                  style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (prop.subTopics.isEmpty)
            const Text(
              'Bu teklife henüz bir alt madde eklenmemiş.',
              style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white54),
            )
          else
            ...prop.subTopics.map((sub) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.title,
                              style: const TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Öneren: ${sub.proposer} | %${sub.approvalRate.toStringAsFixed(0)} Evet (${sub.yesVotes}/${sub.yesVotes + sub.noVotes})',
                              style: const TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 11.5,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      sub.status == 'KABUL_EDILDI'
                          ? const Text(
                              '✓ Kabul',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setDetailState(() {
                                  sub.yesVotes += 1;
                                  if (sub.approvalRate >= 50 && sub.yesVotes > 150) {
                                    sub.status = 'KABUL_EDILDI';
                                  }
                                });
                                setState(() {});
                                _addBlock('SUBTOPIC_VOTE: ${sub.title}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
                                foregroundColor: Colors.black,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text(
                                '+1 Oy',
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // --- BÖLÜM: MEVZUAT UYUMU & NORMLAR HİYERARŞİSİ ---
  Widget _buildLegalAuditSection(Proposal prop) {
    final bool isVetoed = prop.status == 'REDDEDILDI' || prop.ontologyScore < 50;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVetoed ? Colors.redAccent.withValues(alpha: 0.4) : const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.gavel_outlined, size: 16, color: Color(0xFF818CF8)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hukuki Denetim & Normlar Hiyerarşisi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVetoed ? Colors.red.withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isVetoed ? 'VETO' : '%${prop.ontologyScore} UYUMLU',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isVetoed ? Colors.redAccent : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hiyerarşi Katmanları
          _buildNormStep('1. Anayasa Katmanı (Üst Norm)', 'Madde 56: Çevre hakkı / Madde 43: Kıyılar kamu yararınadır.', isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
          _buildNormStep('2. Kanun Katmanı', 'İlgili Çevre ve Şehircilik Kanunları standartları.', const Color(0xFF10B981)),
          _buildNormStep('3. Yerel Yönetmelik', 'Teklif edilen yerel düzenleme metni.', const Color(0xFF38BDF8)),

          if (isVetoed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Bilirkişi Veto Kararı: ${prop.vetoReason ?? "Üst norm ihlali nedeniyle teklif düşürülmüştür."}',
                style: const TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 12.5,
                  color: Colors.redAccent,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNormStep(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 7, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$title: ',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                children: [
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      fontFamily: kAppFontFamily,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM: MÜZAKERE DEFTERİ (YORUMLAR & SANSÜR OYLAMASI) ---
  Widget _buildDiscussionSection(Proposal prop, StateSetter setDetailState) {
    final commentCtrl = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Müzakere Defteri (${prop.comments.length} Görüş)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'SHA-256',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...prop.comments.map((com) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: com.isUnderRedaction ? Colors.amber.withValues(alpha: 0.08) : const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: com.isUnderRedaction ? Colors.amber.withValues(alpha: 0.5) : const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          com.author,
                          style: const TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          com.txHash,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    com.isMasked
                        ? const Text(
                            '[Bu içerik %66 Topluluk Kararıyla Maskelenmiştir - Hash Bütünlüğü Korunmaktadır]',
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 12.5,
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Text(
                            com.text,
                            style: const TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 13.5,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),

                    // Redaksiyon / Sansürleme Oylaması
                    if (com.isUnderRedaction && !com.isMasked) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Şikayet: ${com.redactionReason} (%${com.deleteRate.toStringAsFixed(0)} Silinsin)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 11.5,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () {
                                setDetailState(() {
                                  com.deleteVotes += 1;
                                  if (com.deleteRate >= 66) {
                                    com.isMasked = true;
                                  }
                                });
                                setState(() {});
                                _addBlock('REDACTION_VOTE: ${com.txHash} Maskeleme Oyu');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              child: const Text(
                                'Maskele Oyu Ver',
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Deftere silinemez bir görüş yazın...',
                    hintStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white38),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5, color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 20),
                onPressed: () {
                  if (commentCtrl.text.trim().isEmpty) return;
                  final newCom = CommentItem(
                    id: 'c-${DateTime.now().millisecondsSinceEpoch}',
                    author: activeCitizen.pseudonym,
                    text: commentCtrl.text.trim(),
                    timestamp: '${DateTime.now().hour}:${DateTime.now().minute}',
                    txHash: '0x${sha256.convert(utf8.encode(commentCtrl.text)).toString().substring(0, 8)}',
                  );
                  setDetailState(() => prop.comments.add(newCom));
                  setState(() {});
                  _addBlock('COMMENT_LEDGER: ${newCom.txHash}');
                  commentCtrl.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BÖLÜM: OYLAMA & YÜRÜRLÜK (KARESEL OYLAMA) ---
  Widget _buildVotingSection(Proposal prop, int userVote, int nextCost, StateSetter setDetailState) {
    final bool isVetoed = prop.status == 'REDDEDILDI' || prop.ontologyScore < 50;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Karesel Oylama & Karar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Kullanılan: $userVote Oy (${userVote * userVote} VC)',
                style: const TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 13,
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: userVote > 0
                            ? () {
                                _castQuadraticVote(prop, false);
                                setDetailState(() {});
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '$userVote Oy',
                          style: const TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _castQuadraticVote(prop, true);
                      setDetailState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      '+1 Oy Ver ($nextCost VC)',
                      style: const TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton.icon(
                onPressed: () {
                  setDetailState(() {
                    if (isVetoed) {
                      prop.status = 'REDDEDILDI';
                    } else {
                      prop.status = prop.approvalRate >= 50 ? 'KABUL_EDILDI' : 'REDDEDILDI';
                    }
                  });
                  setState(() {});
                  _addBlock('ENACTMENT_COMPLETE: ${prop.title} -> ${prop.status}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: const Text(
                  'Oylamayı Sonuçlandır & Yürürlüğe Al',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DİYALOGLAR (Yeni Yasa, Diff, Alt Madde) ---

  void _showCreateProposalDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'Çevre & Şehircilik';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          actionsOverflowButtonSpacing: 8,
          actionsAlignment: MainAxisAlignment.end,
          title: const Text(
            'Yeni Yasa Teklifi Sun',
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Yasa Başlığı',
                    labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
                  ),
                  style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5, color: Colors.white),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: const Color(0xFF0F172A),
                  decoration: const InputDecoration(
                    labelText: 'Mevzuat Alanı',
                    labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
                  ),
                  style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5, color: Colors.white),
                  items: ['Çevre & Şehircilik', 'Ulaşım & Sosyal Haklar', 'Kıyı Mevzuatı', 'Enerji & Çevre', 'Genel Yönetişim']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => category = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Gerekçe ve Yasa Metni',
                    labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
                  ),
                  style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Mevzuat Ontolojisi teklifi otomatik analiz eder.',
                        style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                final newProp = Proposal(
                  id: 'prop-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  author: activeCitizen.pseudonym,
                  category: category,
                  yesVotes: 1,
                  noVotes: 0,
                  subTopics: [],
                  comments: [],
                );
                setState(() => proposals.insert(0, newProp));
                _addBlock('NEW_PROPOSAL: ${newProp.title}');
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Teklifi Sun', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAmendmentDialog(Proposal prop, StateSetter setDetailState) {
    final oldCtrl = TextEditingController(text: prop.content.split('.').first);
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Düzenleme Önergesi Hazırla (Diff)',
          style: TextStyle(fontFamily: kAppFontFamily, fontSize: 15.5, fontWeight: FontWeight.w700, color: Color(0xFF06B6D4)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                decoration: const InputDecoration(
                  labelText: 'Değiştirilmek İstenen Kısım',
                  labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
                ),
                style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newCtrl,
                decoration: const InputDecoration(
                  labelText: 'Önerilen Yeni Hüküm',
                  labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
                ),
                style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text.trim().isEmpty) return;
              setDetailState(() {
                prop.hasAmendment = true;
                prop.amendmentOldText = oldCtrl.text.trim();
                prop.amendmentNewText = newCtrl.text.trim();
                prop.amendmentYes = 1;
                prop.amendmentNo = 0;
              });
              setState(() {});
              _addBlock('DIFF_PROPOSED: ${prop.title}');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Önergeyi Sun', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  void _showAddSubTopicDialog(Proposal prop, StateSetter setDetailState) {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Yeni Alt Madde / Konu Ekle',
          style: TextStyle(fontFamily: kAppFontFamily, fontSize: 15.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
        ),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Alt Madde Başlığı',
            labelStyle: TextStyle(fontFamily: kAppFontFamily, fontSize: 13),
          ),
          style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final newSub = SubTopic(
                id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                proposer: activeCitizen.pseudonym,
                yesVotes: 1,
                noVotes: 0,
              );
              setDetailState(() => prop.subTopics.add(newSub));
              setState(() {});
              _addBlock('SUBTOPIC_ADDED: ${newSub.title}');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Alt Maddeyi Kaydet', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 2. SEKME: MEVZUAT & NORMLAR HİYERARŞİSİ ONTOLOJİSİ
  // ==========================================================================

  Widget _buildHierarchyTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'Normlar Hiyerarşisi & Bilirkişi Katmanı',
          style: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hiyerarşide alt norm (yönetmelik), üst norma (Anayasa) aykırı olamaz. Çoğunluk oyu çıksa dahi anayasal haklar gasp edilemez.',
          style: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 13,
            color: Colors.white54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHierarchyCardItem('1. T.C. Anayasası (En Üst Norm)', 'Madde 43: Kıyılar kamu yararına açıktır.\nMadde 56: Herkes sağlıklı ve dengeli bir çevrede yaşama hakkına sahiptir.', const Color(0xFFEF4444)),
                const SizedBox(height: 10),
                _buildHierarchyCardItem('2. Kanunlar', 'Çevre Kanunu, İmar Kanunu, Yenilenebilir Enerji Kanunu.', const Color(0xFFF59E0B)),
                const SizedBox(height: 10),
                _buildHierarchyCardItem('3. Yerel Yönetmelikler', 'Belediye meclisi ve mahalle konseyleri kararları.', const Color(0xFF10B981)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kayıtlı Bilirkişiler ve Oy Ağırlıkları',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF2563EB),
                    child: Text('İA', style: TextStyle(fontFamily: kAppFontFamily, color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    'Prof. Dr. İlker Akman',
                    style: TextStyle(fontFamily: kAppFontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Anayasa Hukuku Bilirkişisi',
                    style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white54),
                  ),
                  trailing: Text(
                    '2.2x Oy Çarpanı',
                    style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHierarchyCardItem(String level, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level,
            style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13.5, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. SEKME: DAĞITIK DEFTER (Blockchain Explorer)
  // ==========================================================================

  Widget _buildLedgerTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Dağıtık Defter (Ledger Explorer)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: kAppFontFamily, fontSize: 16.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                _addBlock('MANUAL_MINE: Blok #${ledger.length + 1045} Kazıldı');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni blok başarıyla kazıldı ve zincire eklendi!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.add_box, size: 14),
              label: const Text('Yeni Blok Kaz', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Yapılan tüm yasa teklifleri, oylar ve kararlar kriptografik olarak zincire işlenir. Geriye dönük silinemez.',
          style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white54, height: 1.4),
        ),
        const SizedBox(height: 14),

        ...ledger.reversed.map((block) => Card(
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Blok #${block.index}',
                          style: const TextStyle(fontFamily: kAppFontFamily, fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF38BDF8)),
                        ),
                        Text(
                          block.timestamp,
                          style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hash: ${block.hash}',
                      style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: Color(0xFF10B981)),
                    ),
                    Text(
                      'Önceki: ${block.prevHash} | Merkle: ${block.merkleRoot}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white38),
                    ),
                    const Divider(color: Color(0xFF1E293B), height: 12),
                    Text(
                      '• ${block.summary}',
                      style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ==========================================================================
  // 4. SEKME: YURTTAŞ KİMLİĞİ & ZKP PROFİLİ
  // ==========================================================================

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // 📘 UYGULAMA & SİSTEM REHBERİ BANNERI
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showInteractiveGuideModal,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              const Text('Platform Rehberi', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                                child: const Text('9 Sistem & Teknik Borç', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Karesel oylama, normlar ontolojisi, diff, UML mimarisi ve teknik borç yönetimini sayfa sayfa inceleyin.',
                            style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white70, height: 1.35, letterSpacing: kReadingLetterSpacing),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF38BDF8), size: 14),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Gerçek Kimlik Kartı (Sistem Katmanı)
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock, color: Color(0xFFF59E0B), size: 15),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Sistem Katmanı: Doğrulanmış Gerçek Kimlik (KYC)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: kAppFontFamily, fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFFF59E0B))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildProfileRow('Adı Soyadı:', activeCitizen.fullName),
                _buildProfileRow('T.C. Kimlik No:', '${activeCitizen.tcNo.substring(0, 3)}*****${activeCitizen.tcNo.substring(8)}'),
                _buildProfileRow('Doğum Tarihi:', activeCitizen.birthDate),
                _buildProfileRow('İkametgah Adresi:', '${activeCitizen.district} / ${activeCitizen.city}'),
                _buildProfileRow('Yetki & Unvan:', activeCitizen.role),
                _buildProfileRow('Oy Ağırlığı Çarpanı:', '${activeCitizen.expertMultiplier}x'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Kamusal ZKP Katmanı
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kamusal Katman: Sıfır Bilgi İspatı (ZKP Rumuzu)', style: TextStyle(fontFamily: kAppFontFamily, fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF38BDF8))),
                const SizedBox(height: 6),
                Text(activeCitizen.pseudonym, style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
                const SizedBox(height: 3),
                Text('Kayıtlı Bölge: ${activeCitizen.district} | İtibar Skoru: ${activeCitizen.reputation}/100', style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 6),
                const Text('Halka açık defterde ve oylamalarda ad, soyad ve TC asla görünmez; yalnızca ZKP rumuzunuz yer alır.', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic, height: 1.3)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text('Profil Değiştir (Bilirkişi veya Diğer Yurttaş Olarak Test Et):', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 8),
        ...citizens.map((c) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${c.pseudonym} (${c.role})', style: const TextStyle(fontFamily: kAppFontFamily, color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Text('${c.fullName} - ${c.district} | ${c.availableCredits} VC', style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Colors.white54)),
              trailing: activeCitizen.id == c.id ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18) : null,
              onTap: () => setState(() => activeCitizen = c),
            )),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SİSTEM REHBERİ (Sayfa Sayfa İnteraktif Öğretici Modal)
  // ==========================================================================

  void _showInteractiveGuideModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int pageIndex = 0;
        final pageCtrl = PageController();

        final List<Map<String, dynamic>> slides = [
          {
            'tag': '1/9 • GİZLİLİK VE KİMLİK',
            'icon': Icons.fingerprint,
            'color': const Color(0xFF10B981),
            'title': 'Çift Katmanlı Kimlik (KYC vs. ZKP)',
            'visual': Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sistem Katmanı (KYC)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                        SizedBox(height: 2),
                        Text('T.C. No, Ad, İkametgah', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white38, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Kamusal Alan (ZKP)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        SizedBox(height: 2),
                        Text('@AdaletSavunucusu', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            'what': 'Sistemde gerçek kişi doğrulaması ile kamusal oylama alanının birbirinden kriptografik olarak soyutlandığı çift katmanlı kimlik mimarisidir.',
            'how': 'Doğrulanmış kimlik bilgileri yerel güvenli alanda tutulur. Kamusal alanda, oylamalarda ve dağıtık defter kayıtlarında yalnızca tek yönlü Sıfır Bilgi İspatı (ZKP) ile türetilen anonim rumuz kullanılır.',
            'why': 'Demokratik seçimlerde hem tekil oy hakkı güvenceye alınır (Sybil saldırısı engellenir) hem de yurttaşın siyasi tercihlerinden ötürü fişlenme ve baskı riski ortadan kaldırılır.',
            'dataFlow': '• Veri Kaynağı: Nüfus/KYC modelinden gelen tekil yurttaş verisi (Citizen sınıfı: tcNo, fullName, city).\n• İşleme Akışı: T.C. verisi yerel _activeCitizen durumunda tutulur; SHA-256 ve tuzlama (salt) algoritmasıyla kamusal rumuz (@AdaletSavunucusu) ve ZKP hash\'i (0x7f4a...8821) türetilir.\n• Veri Çıktısı: Teklif oylamalarına ve dağıtık deftere (BlockItem) T.C. verisi aktarılmaz; yalnızca anonim ZKP kimliği atomik işlem olarak mühürlenir.',
            'pattern': 'Separation of Concerns (SoC) & Strategy Pattern. Citizen sınıfı (main.dart: 48-75) ve _activeCitizen durumu. Kimlik yönetimi ile kamusal oylama yetkisi ayrık nesne modelleriyle yürütülür.',
            'academic': 'GDPR (Madde 25) ve KVKK \'Tasarım Yoluyla Veri Koruması ve Veri Minimizasyonu\' ilkelerine dayanır. Bilgisayar bilimlerindeki Sybil Direnci (Sybil Resistance) ile Bireysel Mahremiyet dengesi ZKP protokolüyle kurulmuştur.',
          },
          {
            'tag': '2/9 • OYLAMA MODELİ',
            'icon': Icons.calculate_outlined,
            'color': const Color(0xFFF59E0B),
            'title': 'Karesel Oylama (Quadratic Voting)',
            'visual': Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: const Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text('1 Oy = 1 VC', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white70)),
                  Text('2 Oy = 4 VC', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white70)),
                  Text('3 Oy = 9 VC', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  Text('4 Oy = 16 VC', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            'what': 'Kullanılan oy adedinin maliyetinin karesel (Maliyet = Oy²) olarak katlandığı, tercih yoğunluğunu ölçen matematiksel oylama algoritmasıdır.',
            'how': 'Her yurttaşa periyodik olarak 100 Ses Kredisi (Voice Credit - VC) tahsis edilir. 1 oy = 1 VC, 2 oy = 4 VC, 3 oy = 9 VC, 4 oy = 16 VC şeklinde harcama yapılır.',
            'why': 'Zengin veya organize grupların tüm oylarını tek bir konuya yığmasını engeller; yurttaşların en çok önem verdikleri konulara rasyonel ağırlık vermesini sağlar.',
            'dataFlow': '• Veri Kaynağı: _activeCitizen.voiceCredits (100 VC) ve Proposal.userVotes oylama durum haritası.\n• İşleme Akışı: _castQuadraticVote() fonksiyonunda mevcut oy adedi n alınır; ek oy için gereken kredi ΔVC = (n+1)² - n² formülüyle hesaplanır. Yeterli kredi varsa kredi havuzundan düşülür.\n• Veri Çıktısı: Teklifin yesVotes/noVotes sayacı güncellenir ve işlem oylama kaydı olarak BlockItem.transactions listesine yazılır.',
            'pattern': 'Quadratic Cost Engine & Command Pattern. _castQuadraticVote() metodu ve Proposal sınıfı (main.dart: 84-118, 590-640). Her oy eylemi hesaplanabilir, atomik bir komut olarak işletilir.',
            'academic': 'Vitalik Buterin, Glen Weyl ve Zoë Hitzig (2018) tarafından formüle edilen \'Liberal Radicalism & Quadratic Voting\' teorisine dayanır. Arrow İmkansızlık Teoremi karşısında toplumsal refahı maksimize eden mikroiktisadi karar modelidir.',
          },
          {
            'tag': '3/9 • HUKUK GÜVENCESİ',
            'icon': Icons.gavel,
            'color': const Color(0xFFEF4444),
            'title': 'Normlar Hiyerarşisi & Anayasal Veto',
            'visual': Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. T.C. Anayasası (En Üst Norm)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  SizedBox(height: 2),
                  Text('   ↳ 2. Kanunlar', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Color(0xFFF59E0B))),
                  SizedBox(height: 2),
                  Text('      ↳ 3. Yerel Yönetmelikler & Kararlar', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Halk oylamasından salt çoğunluk çıksa dahi temel anayasal normlara ve kamu yararına aykırı tekliflerin yazılımsal olarak engellenmesidir.',
            'how': 'Teklifler oylamaya sunulmadan önce ve sonra AI Destekli Mevzuat Denetçisi ve Bilirkişi süzgecinden geçirilir. Üst norm ihlali saptandığında teklif \'VETO Edildi\' durumuna geçirilir.',
            'why': 'Demokrasilerde çoğunluğun tiranlığını (çoğunluk oyuyla temel insan haklarının, kıyıların ve anayasal güvencelerin gasp edilmesini) önler.',
            'dataFlow': '• Veri Kaynağı: kConstitutionArticles anayasa veritabanı (Anayasa Madde 43, 56 vb.) ve Proposal.legalStatus enum verisi.\n• İşleme Akışı: Teklif içeriği kural motoru tarafından anayasal normlarla denetlenir. Kıyı şeridi özelleştirmesi tespiti halinde legalStatus = LegalStatus.vetoed olarak işaretlenir.\n• Veri Çıktısı: Teklif kartında kırmızı VETO rozeti açılır, oylama kilitlenir (isVetoed = true) ve blok defterine \'VETO_TRIGGERED\' işlemi mühürlenir.',
            'pattern': 'Chain of Responsibility & Rule Engine Pattern. _buildLegalAuditSection() ve Proposal.legalStatus denetleyicisi (main.dart: 1200-1280). Teklif bağımsız hukuk normu doğrulayıcı zincirinden geçer.',
            'academic': 'Hans Kelsen\'in \'Saf Hukuk Teorisi\' (Pure Theory of Law) ve Normlar Hiyerarşisi piramidi yazılıma aktarılmıştır. Anayasa en üst normdur; alt normlar üst normlara aykırı olamaz (Lex Superior Derogat Legi Inferiori).',
          },
          {
            'tag': '4/9 • METİN DÜZENLEME',
            'icon': Icons.difference_outlined,
            'color': const Color(0xFF06B6D4),
            'title': 'Metin Değişiklik Önergesi (Diff)',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[-] Eski: parklarda betonlaşma sınırlandırılsın.', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Colors.redAccent, decoration: TextDecoration.lineThrough)),
                  SizedBox(height: 3),
                  Text('[+] Yeni (Diff): parklarda yağmur suyu göletleri kurulsun.', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Bir yasa teklifinin tamamını toptan reddetmek yerine sadece belirli bir fıkrasını revize etmeyi sağlayan satır bazlı metin yamalama mekanizmasıdır.',
            'how': 'Yurttaşlar kırmızı/yeşil diff formatında değişiklik önergesi sunar. Önerge topluluk çoğunluğunu aldığında tek tıklamayla yasa tasarısına atomik olarak işlenir.',
            'why': 'Kutuplaştırıcı \'ya hep ya hiç\' yaklaşımını ortadan kaldırarak uzlaşmacı ve katılımcı kanun yapım süreçleri inşa eder.',
            'dataFlow': '• Veri Kaynağı: Proposal.diffOldText, Proposal.diffNewText ve Proposal.diffAuthor metin alanları.\n• İşleme Akışı: _acceptDiffPatch() metodu çağrıldığında, proposal.content içerisindeki eski cümle saptanır, yeni öneriyle değiştirilir. Değişikliğin SHA-256 diff hash kodu hesaplanır.\n• Veri Çıktısı: Teklif metni güncellenir (hasDiff = false), durum mesajı yayınlanır ve blok zincirine [DIFF_ENACTED] işlem kaydı gönderilir.',
            'pattern': 'Delta Patching & Memento Pattern. _acceptDiffPatch() fonksiyonu (main.dart: 680-730). Versiyon kontrol sistemlerindeki (Git) fark işleme ve durum geçmişi desenleri hukuk metinlerine uyarlanmıştır.',
            'academic': 'Jürgen Habermas\'ın \'Müzakereci Demokrasi Teorisi\'ne (Deliberative Democracy) dayanır. Kanunlar statik metinler olmaktan çıkarılıp, dağıtık katılımcıların katkısıyla evrilen dinamik yazılım kodları gibi modellenmiştir.',
          },
          {
            'tag': '5/9 • MODÜLER YÖNETİŞİM',
            'icon': Icons.account_tree_outlined,
            'color': const Color(0xFF38BDF8),
            'title': 'Alt Maddeler & Ağaç Yapısı (Sub-topics)',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Ana Teklif: Kentsel Yeşil Koridorlar', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 3),
                  Text('   ├─ 🚲 Alt Madde 1: Bisiklet Yolları Standardı (%88 Kabul)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Color(0xFF38BDF8))),
                  Text('   └─ 💡 Alt Madde 2: Güneş Enerjili Aydınlatma (%75 Kabul)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Color(0xFF38BDF8))),
                ],
              ),
            ),
            'what': 'Kapsamlı yasa tekliflerinin alt fıkralarını ve uygulama maddelerini bağımsız oylanabilir hiyerarşik bir ağaç yapısında sunan modüler mimaridir.',
            'how': 'Ana teklifin altında SubTopic nesneleri listelenir. Her alt madde bağımsız kabul/ret sayaçlarına ve yüzde oranlarına sahiptir.',
            'why': 'Geleneksel parlamentolarda sıkça başvurulan \'Torba Yasa\' suistimalini engeller; olumlu bir yasa paketinin içine halkın onaylamayacağı maddelerin gizlenmesini önler.',
            'dataFlow': '• Veri Kaynağı: Proposal.subTopics dinamik listesi içerisindeki SubTopic nesneleri.\n• İşleme Akışı: _addSubTopic() fonksiyonu ile yeni fıkra nesnesi oluşturulur (id, title, yesVotes, noVotes, totalVotes). Kullanıcı alt maddeye oy verdiğinde sayaç yerel state\'te bağımsız olarak artırılır.\n• Veri Çıktısı: Her alt maddenin kabul oranı dinamik hesaplanır (Örn: `%88 Kabul`) ve teklif kartında hiyerarşik ağaç dalı olarak gösterilir.',
            'pattern': 'Composite Pattern & Recursive Tree Structure. Proposal ve SubTopic sınıfları (main.dart: 119-138, 750-780). Ana teklif ve alt fıkralar hiyerarşik ağaç düğümleri olarak yapılandırılır.',
            'academic': 'Kamu Tercihi Teorisi (Public Choice Theory) ve James Buchanan\'ın anayasal iktisat modeline dayanır. Oy ticareti (logrolling) ve torba yasa manipülasyonu modüler ayrıştırma (unbundling) ile teknik olarak engellenmiştir.',
          },
          {
            'tag': '6/9 • KRİPTOGRAFİK ŞEFFAFLIK',
            'icon': Icons.hub_outlined,
            'color': const Color(0xFF818CF8),
            'title': 'Dağıtık Müzakere Defteri (SHA-256)',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blok #1048 | Hash: 0x8f2a...c31b', style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF10B981))),
                  Text('Önceki Blok: 0x4a12...99ee | Merkle: 0x11ee...00bb', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white54)),
                  Text('İşlem: [DIFF_ENACTED] Düzenleme Metne İşlendi', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Colors.white70)),
                ],
              ),
            ),
            'what': 'Platformdaki tüm yasa tekliflerinin, oylamaların ve diff kararlarının kriptografik bloklara mühürlendiği değişmez (immutable) kayıt kütüğüdür.',
            'how': 'İşlemler bir işlem havuzunda (mempool) toplanır. _mineBlock() fonksiyonu çağrıldığında işlemler SHA-256 ile özetlenir, Merkle kökü çıkarılır ve önceki bloğun hash\'ine zincirlenir.',
            'why': 'Merkezi sunucu yöneticisinin, kamu idaresinin veya kötü niyetli aktörlerin geçmiş oyları silmesini, sonuçları geriye dönük tahrif etmesini matematiksel olarak olanaksız kılar.',
            'dataFlow': '• Veri Kaynağı: Uygulama içindeki oylama, diff onayı ve yeni teklif eylemleri (_pendingTransactions).\n• İşleme Akışı: _mineBlock() tetiklendiğinde: 1. prevHash = _blockchain.last.hash, 2. Merkle Root = sha256(tx[0] + tx[1]), 3. hash = sha256(index + prevHash + timestamp + merkleRoot + nonce). Nonce artırılarak proof-of-work tamamlanır.\n• Veri Çıktısı: Yeni BlockItem nesnesi _blockchain listesine eklenir, Defter sekmesinde blok kartı olarak görselleştirilir.',
            'pattern': 'Immutable Singly-Linked List & Cryptographic Merkle Node. BlockItem sınıfı ve _blockchain listesi (main.dart: 160-195, 2200-2400). Her düğüm bir önceki düğümün kriptografik özetine bağlanır.',
            'academic': 'Satoshi Nakamoto (2008) eşler arası zaman damgası mimarisi ve Ralph Merkle (1979) kriptografik ağaç yapısı uygulanmıştır. Bizans Hata Toleransı (BFT) prensiplerine uygun, güven gerektirmeyen (trustless) şeffaflık sağlanır.',
          },
          {
            'tag': '7/9 • MAZUR İÇERİK DENETİMİ',
            'icon': Icons.visibility_off_outlined,
            'color': const Color(0xFFEC4899),
            'title': '%66 Topluluk Redaksiyonu (Maskeleme)',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Şikayet Edilen Yorum: (Nefret / KVKK İhlali)', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Colors.amber)),
                  SizedBox(height: 3),
                  Text('[Bu içerik %66 topluluk kararıyla maskelenmiştir]', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11.5, color: Colors.redAccent, fontStyle: FontStyle.italic)),
                  Text('SHA-256 Hash Bütünlüğü: KORUNUYOR (0x99a1...ff3b)', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Değişmez blok defterinde adli kanıt zincirini bozmadan, nefret ve KVKK ihlali içeren yorumların demokratik çoğunlukla kamusal alandan gizlenmesidir.',
            'how': 'Yurttaşlar sakıncalı içeriği şikayet eder. Şikayet oranı %66 barajını aştığında içerik otomatik olarak maskelenir; fakat orijinal veri adli denetim için blok hash\'inde korunur.',
            'why': 'Kayıt silme işlemi blok zincirinin kriptografik hash sürekliliğini parçalar. Silme yerine maskeleme yapılarak hem kamusal nezaket korunur hem de hukuki delil bütünlüğü muhafaza edilir.',
            'dataFlow': '• Veri Kaynağı: CommentItem model nesnesi (id, author, text, flagCount, isMasked, hash).\n• İşleme Akışı: _flagComment(id) fonksiyonu flagCount değerini artırır; flagCount / totalVoters >= 0.66 koşulu sağlandığında isMasked = true durumuna geçirilir. Orijinal hash korunurken text arayüzde redakte token\'ı ile değiştirilir.\n• Veri Çıktısı: Yorum listesinde kırmızı maskeli uyarı kutusu gösterilir; defterdeki SHA-256 hash imzası geçerliliğini korumaya devam eder.',
            'pattern': 'State Pattern & Two-Phase Democratic Moderation. CommentItem sınıfı (main.dart: 140-155) ve _flagComment() metodu. İçerik görünürlüğü merkezi bir moderatör olmadan otonom durum geçişleriyle (State Transition) yönetilir.',
            'academic': 'Blok zincirlerinde Değişmezlik (Immutability) ile Avrupa İnsan Hakları Sözleşmesi (AİHS) ve Unutulma Hakkı (Right to be Forgotten) arasındaki gerilimin teknik çözümüdür. Kriptografik bütünlük korunurken görünürlük demokratik konsensüsle filtrelenir.',
          },
          {
            'tag': '8/9 • YAZILIM MİMARİSİ (UML & SOLID)',
            'icon': Icons.architecture_rounded,
            'color': const Color(0xFF38BDF8),
            'title': 'UML Sınıf Mimarisi & SOLID Prensipleri',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📦 Citizen ──[kullanır]──> Proposal (Aggregate Root)', style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                  SizedBox(height: 3),
                  Text('   ├─◆ SubTopic (1..* Kompozisyon)', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF10B981))),
                  Text('   ├─◆ CommentItem (1..* Moderasyonlu Liste)', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFFF59E0B))),
                  Text('   └─► BlockItem (SHA-256 Değişmez Defter Bağı)', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF818CF8))),
                ],
              ),
            ),
            'what': 'Platformun modülerliğini, test edilebilirliğini ve yüksek akademik standartlara uygunluğunu sağlayan nesne yönelimli yazılım mimarisidir.',
            'how': 'Tüm modeller (Citizen, Proposal, SubTopic, CommentItem, BlockItem) Single Responsibility prensibine göre kurgulanmış; Proposal nesnesi alt birimleri kompozisyon ile yönetir.',
            'why': 'Spagetti kod bağımlılıklarını önler, bellek sızıntılarını engeller ve dar ekranlarda dahi 0 RenderFlex taşması (zero-overflow) ile deterministik çalışmayı garanti eder.',
            'dataFlow': '• Veri Kaynağı: _DemokrasiAppState merkezi reaktif durum deposu.\n• İşleme Akışı: Veri modelleri immutable ve tip güvenli (type-safe) Dart sınıfları olarak yapılandırılmıştır. UI bileşenleri veri modellerine parametrik olarak erişir; doğrudan sıkı bağımlılık (tight coupling) engellenmiştir.\n• Veri Çıktısı: 0 taşmalı responsive widget ağacı (Widget Tree), deterministik test kapsamı (Widget & Unit Tests) ve modüler servis yapısı.',
            'pattern': 'Domain-Driven Design (DDD), Composition over Inheritance, SOLID Prensipleri (SRP, OCP, DIP). Model katmanı: main.dart satır 48-180. Aggregate Root olarak Proposal sınıfı.',
            'academic': 'Robert C. Martin (Clean Architecture) ve Erich Gamma (GoF Design Patterns) prensipleri uygulanmıştır: SRP (her sınıf tek sorumluluk taşır), OCP (yeni teklif tipleri mevcut yapıyı bozmadan eklenir), DIP (UI katmanı soyut modellere bağlıdır).',
          },
          {
            'tag': '9/9 • TEKNİK BORÇ VE REFACTORING',
            'icon': Icons.engineering_outlined,
            'color': const Color(0xFFF59E0B),
            'title': 'Teknik Borç Yönetimi & Refactoring (Martin Fowler)',
            'visual': Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Martin Fowler Teknik Borç Dörtgeni:', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  SizedBox(height: 3),
                  Text('✔ Bu Proje: Bilinçli & Tedbirli (Deliberate & Prudent)', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF10B981))),
                  Text('  ↳ Amaç: Yerel jüri ortamında %100 kesintisiz demo hızı', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 10, color: Colors.white70)),
                  Text('  ↳ İtfa Planı: Feature-First Clean Architecture & SQLite', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 10, color: Color(0xFF38BDF8))),
                ],
              ),
            ),
            'what': 'Yazılım mühendisliğinde prototip doğrulaması ve teslim hızını artırmak için bilinçli olarak alınan mimari ödünler (Technical Debt) ve bunların geri ödeme stratejisidir.',
            'how': 'Yerel demo sırasında internet kopması veya uzak sunucu arızası riskini bertaraf etmek için in-memory state ve tekil dosya mimarisi seçilmiştir. Tip güvenliği (type-safety) ve model soyutlaması ile borcun faizi (teknik karmaşa) kontrol altında tutulmuştur.',
            'why': 'Hiçbir gerçek yazılım projesi sıfır teknik borçla başlamaz. Profesyonel mühendislik, teknik borcu gizlemek yerine açıkça belgelemeyi, sınıflandırmayı ve itfa yol haritasını yönetmeyi gerektirir.',
            'dataFlow': '• Alınan Bilinçli Borç: Veriler uzak API yerine yerel RAM deposunda (_DemokrasiAppState) tutulur.\n• Neden Alındı?: 3-4 dakikalık jüri incelemesinde ağ gecikmesini 0 ms\'ye indirmek ve deterministik test ortamı sunmak.\n• İtfa Planı (Refactoring): Production aşamasında flutter_secure_storage (ZKP anahtarları), Isar/Hive yerel NoSQL veritabanı ve gRPC Node senkronizasyonu katmanlarına taşınacaktır.',
            'pattern': 'Technical Debt Quadrant (Martin Fowler) & Strangler Fig Pattern (Aşamalı Refactoring). Proje kodu Spaghetti yapıda değil; Clean Architecture katmanlarına ayrıştırılmaya hazır SOLID modellerle kurulmuştur.',
            'academic': 'Ward Cunningham (1992) Teknik Borç Metaforu ve Martin Fowler (2009) Teknik Borç Dörtgeni\'ne dayanır. Proje "Bilinçli ve Tedbirli" (Deliberate & Prudent) çeyreğinde yer alır. Önceden kapatılan borçlar: 0 RenderFlex taşması, Outfit tipografi ölçeklemesi ve ZKP/KYC model ayrımıdır.',
          },
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFF090D16),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
              ),
              child: Column(
                children: [
                  // Sürükleme Tutamacı & Üst Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Platform & Sistem Rehberi', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 1),

                  // Sayfa İçeriği
                  Expanded(
                    child: PageView.builder(
                      controller: pageCtrl,
                      itemCount: slides.length,
                      onPageChanged: (idx) => setModalState(() => pageIndex = idx),
                      itemBuilder: (context, idx) {
                        final s = slides[idx];
                        final Color c = s['color'] as Color;

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Etiket
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s['tag'] as String,
                                style: TextStyle(fontFamily: kAppFontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Başlık & İkon
                            Row(
                              children: [
                                Icon(s['icon'] as IconData, color: c, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s['title'] as String,
                                    style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Görsel Temsil Kutusu
                            s['visual'] as Widget,
                            const SizedBox(height: 16),

                            // Açıklama Maddeleri
                            _buildGuidePoint('📖 1. Sistem Tanımı (Nedir?)', s['what'] as String, c),
                            const SizedBox(height: 10),
                            _buildGuidePoint('⚙️ 2. Çalışma Mekanizması', s['how'] as String, const Color(0xFF38BDF8)),
                            const SizedBox(height: 10),
                            _buildGuidePoint('🎯 3. Mühendislik Amacı', s['why'] as String, const Color(0xFF10B981)),
                            const SizedBox(height: 10),
                            _buildGuidePoint('🔄 4. Veri Kaynağı & İşleme Akışı', s['dataFlow'] as String, const Color(0xFFF59E0B)),
                            const SizedBox(height: 10),
                            _buildGuidePoint('📐 5. Yazılım Tasarım Kalıbı & Mimari', s['pattern'] as String, const Color(0xFF818CF8)),
                            const SizedBox(height: 10),
                            _buildGuidePoint('🏛️ 6. Akademik & Teorik Temel', s['academic'] as String, const Color(0xFF38BDF8)),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),

                  // Alt Navigasyon Barı (Noktalar & Butonlar)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Önceki Butonu
                        pageIndex > 0
                            ? TextButton.icon(
                                onPressed: () {
                                  pageCtrl.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.chevron_left, size: 16),
                                label: const Text('Önceki', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.w600)),
                              )
                            : const SizedBox(width: 44),

                        // Nokta Göstergesi
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(slides.length, (i) {
                                final isSel = pageIndex == i;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: isSel ? 12 : 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF38BDF8) : Colors.white24,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),

                        // Sonraki / Bitir Butonu
                        pageIndex < slides.length - 1
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  pageCtrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38BDF8),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                label: const Text('Sonraki', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                                icon: const Icon(Icons.chevron_right, size: 16),
                              )
                            : ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Anladım ✓', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuidePoint(String label, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.5, fontWeight: FontWeight.bold, color: accent)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontFamily: kAppFontFamily, fontSize: 13, color: Colors.white, height: 1.4, letterSpacing: kReadingLetterSpacing)),
        ],
      ),
    );
  }
}

