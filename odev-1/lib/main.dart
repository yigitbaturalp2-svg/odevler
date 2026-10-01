import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const DemokrasiApp());
}

class DemokrasiApp extends StatelessWidget {
  const DemokrasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demokrasi & Yönetişim Ontolojisi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        cardColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF38BDF8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF818CF8),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// VERİ MODELLERİ
// ---------------------------------------------------------------------------

class Citizen {
  final String id;
  final String fullName;
  final String tcNo;
  final String birthDate;
  final String city;
  final String district;
  final String pseudonym;
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
}

class SubTopic {
  final String id;
  final String title;
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

class Topic {
  final String id;
  String title;
  String content;
  final String author;
  final String category;
  int yesVotes;
  int noVotes;
  final int quorumRequired;
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

  Topic({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    this.yesVotes = 340,
    this.noVotes = 110,
    this.quorumRequired = 200,
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

  int get totalVotes => yesVotes + noVotes;
  double get approvalRate => (yesVotes / (totalVotes > 0 ? totalVotes : 1)) * 100;
}

class Block {
  final int index;
  final String timestamp;
  final String hash;
  final String prevHash;
  final String merkleRoot;
  final int nonce;
  final List<String> transactions;

  Block({
    required this.index,
    required this.timestamp,
    required this.hash,
    required this.prevHash,
    required this.merkleRoot,
    required this.nonce,
    required this.transactions,
  });
}

// ---------------------------------------------------------------------------
// ANA EKRAN (STATE & CLEAN MODERN UI)
// ---------------------------------------------------------------------------

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _activeScenarioId = 1;
  String _activeScenarioName = 'Senaryo 1: Kentsel Dönüşüm & Karesel Oylama';
  String _selectedFilter = 'Tümü'; // Tümü, Oylamada, Yürürlükte, Veto

  late Citizen activeCitizen;
  late List<Citizen> citizens;
  late List<Topic> topics;
  late List<Block> blockchain;
  Map<String, int> userTopicVotes = {}; // topicId -> voteCount

  @override
  void initState() {
    super.initState();
    _initCitizens();
    _loadScenario(1, showFeedback: false);
  }

  void _initCitizens() {
    citizens = [
      Citizen(
        id: 'cit-1',
        fullName: 'Yiğit Özdemir',
        tcNo: '38291048291',
        birthDate: '14.05.1998',
        city: 'İstanbul',
        district: 'Kadıköy',
        pseudonym: '@AdaletSavunucusu',
        reputation: 98,
        role: 'Yurttaş',
        expertMultiplier: 1.0,
        voiceCredits: 100,
        spentCredits: 25,
      ),
      Citizen(
        id: 'cit-2',
        fullName: 'Prof. Dr. İlker Akman',
        tcNo: '48201948210',
        birthDate: '02.04.1972',
        city: 'Ankara',
        district: 'Çankaya',
        pseudonym: '@IlkerHukuk',
        reputation: 99,
        role: 'Bilirkişi (Anayasa Hukuku)',
        expertMultiplier: 2.2,
        voiceCredits: 250,
        spentCredits: 40,
      ),
      Citizen(
        id: 'cit-3',
        fullName: 'Zeynep Aksoy',
        tcNo: '19482019482',
        birthDate: '23.11.1995',
        city: 'İzmir',
        district: 'Karşıyaka',
        pseudonym: '@GelecekOncusu',
        reputation: 94,
        role: 'Mahalle Meclisi Temsilcisi',
        expertMultiplier: 1.5,
        voiceCredits: 150,
        spentCredits: 36,
      ),
    ];
    activeCitizen = citizens[0];
  }

  void _loadScenario(int scenarioId, {bool showFeedback = true}) {
    setState(() {
      _activeScenarioId = scenarioId;
      userTopicVotes.clear();

      if (scenarioId == 1) {
        _activeScenarioName = 'Senaryo 1: Kentsel Dönüşüm & Karesel Oylama (Azınlık Hakları)';
        topics = [
          Topic(
            id: 'top-1',
            title: 'Kentsel Yeşil Koridorların Korunması ve Yapılaşma Yasağı',
            content: 'İl sınırları içerisindeki tüm tescilli park ve korularda kalıcı ticari yapı inşa edilemez. Çevre düzenlemelerinde betonlaşma yerine geçirgen zemin mecburidir.',
            author: '@AdaletSavunucusu',
            category: 'Çevre & Şehircilik (Md. 56)',
            yesVotes: 342,
            noVotes: 114,
            status: 'OYLAMADA',
            ontologyScore: 96,
            hasAmendment: true,
            amendmentOldText: 'çevre düzenlemelerinde betonlaşma yerine geçirgen zemin mecburidir.',
            amendmentNewText: 'çevre düzenlemelerinde betonlaşma yerine geçirgen zemin mecburidir. Ayrıca park alanlarında yağmur suyu hasadı göletleri kurulması zorunludur.',
            amendmentYes: 45,
            amendmentNo: 12,
            subTopics: [
              SubTopic(
                id: 'sub-1',
                title: 'Park İçi Bisiklet ve Yürüyüş Yolları Standardı',
                proposer: '@GelecekOncusu',
                yesVotes: 280,
                noVotes: 40,
                status: 'KABUL_EDILDI',
              ),
              SubTopic(
                id: 'sub-2',
                title: 'Gece Park Aydınlatmalarının Güneş Enerjisine Geçirilmesi',
                proposer: '@DemokrasiBekcisi',
                yesVotes: 195,
                noVotes: 65,
                status: 'OYLAMADA',
              ),
            ],
            comments: [
              CommentItem(
                id: 'com-1',
                author: '@EkolojikDenge',
                text: 'Gelecek kuşaklar için betonlaşmayı engelleyen 2. madde çok hayati.',
                timestamp: '14:22',
                txHash: '0x8f192b001a4c',
              ),
              CommentItem(
                id: 'com-2',
                author: '@TrollProvokator',
                text: 'Bu tasarıyı destekleyenler şu adresteki (...şahsi adres ifşası...) derneğe hesap versin!',
                timestamp: '09:12',
                txHash: '0x33e410f881ab',
                isUnderRedaction: true,
                redactionReason: 'KVKK İhlali (Adres İfşası) & Nefret Söylemi',
                deleteVotes: 142,
                keepVotes: 18,
              ),
            ],
          ),
          Topic(
            id: 'top-2',
            title: 'Toplu Taşımada 24 Saat Kesintisiz Gece Seferleri',
            content: 'Metro ve ana otobüs hatlarında Cuma ve Cumartesi geceleri kesintisiz ulaşım sağlanacaktır. 25 yaş altı gençlere %50 sübvansiyon uygulanacaktır.',
            author: '@GelecekOncusu',
            category: 'Ulaşım & Sosyal Haklar',
            yesVotes: 890,
            noVotes: 98,
            status: 'KABUL_EDILDI',
            ontologyScore: 91,
            subTopics: [],
            comments: [],
          ),
        ];
      } else if (scenarioId == 2) {
        _activeScenarioName = 'Senaryo 2: Anayasaya Aykırı Teklif & Normlar Hiyerarşisi (Kural 6)';
        topics = [
          Topic(
            id: 'top-s2-1',
            title: 'Kıyı Şeridi ve Sahil Plajlarının Özel İşletmelere Devri & Ücretlendirilmesi',
            content: 'Belediye sınırları içindeki tüm doğal plaj alanları gelir artırımı amacıyla özel işletmelere devredilecek ve halktan giriş ücreti alınacaktır.',
            author: '@RantMerkezi',
            category: 'Kıyı Mevzuatı & Özelleştirme',
            yesVotes: 520,
            noVotes: 130,
            status: 'REDDEDILDI',
            ontologyScore: 18,
            vetoReason: 'ANAYASAL VETO: T.C. Anayasası Madde 43 uyarınca kıyılardan yararlanmada kamu yararı esastır. Normlar Hiyerarşisi gereği yerel yönetmelik Anayasaya aykırı olamaz.',
            normViolation: 'T.C. Anayasası Madde 43 (Kıyıların Korunması) & Madde 56 İhlali',
            hasAmendment: false,
            subTopics: [],
            comments: [
              CommentItem(
                id: 'com-s2-1',
                author: '@IlkerHukuk',
                text: 'Bilirkişi Veto Kararı: Normlar hiyerarşisinin tepesindeki Anayasa Madde 43 çiğnenemez. Çoğunluk oyu olsa dahi anayasal haklar oylamayla gasp edilemez.',
                timestamp: '11:05',
                txHash: '0x44c19b02ef01',
              ),
            ],
          ),
          Topic(
            id: 'top-s2-2',
            title: 'Orman Sınırları Koruma ve Ağaçlandırma Seferberliği',
            content: 'Anayasa Madde 169 gereğince devlet ormanlarının mülkiyeti devrolunamaz. Yanan sahalar derhal ağaçlandırılacaktır.',
            author: '@IlkerHukuk',
            category: 'Anayasa Madde 169',
            yesVotes: 940,
            noVotes: 25,
            status: 'KABUL_EDILDI',
            ontologyScore: 99,
            subTopics: [],
            comments: [],
          ),
        ];
      } else if (scenarioId == 3) {
        _activeScenarioName = 'Senaryo 3: KVKK İhlali & Defterde Sansür Oylaması (Kural 7 & 8)';
        topics = [
          Topic(
            id: 'top-s3-1',
            title: 'Üniversite Kampüslerinde Gece Güvenlik ve Kimlik Kontrolü Protokolü',
            content: 'Kampüs içi yurt bölgelerinde saat 23:00\'ten sonra biyometrik turnike sistemi kurulacak, güvenlik personeli sayısı iki katına çıkarılacaktır.',
            author: '@OgrenciTemsilcisi',
            category: 'Öğrenci Hakları & İç Güvenlik',
            yesVotes: 410,
            noVotes: 160,
            status: 'OYLAMADA',
            ontologyScore: 92,
            hasAmendment: false,
            subTopics: [
              SubTopic(
                id: 'sub-s3-1',
                title: 'Öğrenci Konseyi Güvenlik Denetim Komisyonu',
                proposer: '@GelecekOncusu',
                yesVotes: 320,
                noVotes: 15,
                status: 'KABUL_EDILDI',
              ),
            ],
            comments: [
              CommentItem(
                id: 'com-s3-1',
                author: '@KampusGuvenlik',
                text: 'Yurt çevresindeki aydınlatma yetersiz, öncelikle direkler dikilmeli.',
                timestamp: '19:10',
                txHash: '0xbb11029c91ff',
              ),
              CommentItem(
                id: 'com-s3-2',
                author: '@AnonimProvokator',
                text: 'Bu protokole karşı çıkan öğrenci temsilcisi Ayşe K. (TC: 10492819401, Tel: 0532XXXXXXX, Adres: Gül Mah. No:4) hesabını verecek!',
                timestamp: '20:15',
                txHash: '0xcc994812a1ef',
                isUnderRedaction: true,
                redactionReason: 'Ağır KVKK İhlali (TC Kimlik & Şahsi Telefon/Adres İfşası)',
                deleteVotes: 188,
                keepVotes: 12,
                isMasked: false,
              ),
              CommentItem(
                id: 'com-s3-3',
                author: '@AdaletSavunucusu',
                text: 'Kural 7 & 8 devrede: Yukarıdaki ifşa yorumu defterde SHA-256 ile kayıtlı olduğu için direkt silinemez! %66 topluluk sansür oylaması açılmıştır.',
                timestamp: '20:25',
                txHash: '0xee882104ab90',
              ),
            ],
          ),
        ];
      } else if (scenarioId == 4) {
        _activeScenarioName = 'Senaryo 4: Oybirliğiyle Kabul Edilmiş Resmi Kanun (Kural 1, 4, 5)';
        topics = [
          Topic(
            id: 'top-s4-1',
            title: 'Yenilenebilir Enerji ve Çatı Tipi Güneş Santralleri Teşvik Kanunu',
            content: 'Tüm konut ve sanayi çatılarında güneş paneli kurulumları bürokratik izinlerden muaf tutulacak; üretilen ihtiyaç fazlası elektrik devlet tarafından satın alınacaktır.',
            author: '@YesilEnerji',
            category: 'Enerji & Çevre',
            yesVotes: 1420,
            noVotes: 85,
            status: 'KABUL_EDILDI',
            ontologyScore: 99,
            hasAmendment: false,
            subTopics: [
              SubTopic(
                id: 'sub-s4-1',
                title: 'Apartman Ortak Alanlarında Elektrik Mahsuplaşması Standardı',
                proposer: '@AdaletSavunucusu',
                yesVotes: 1200,
                noVotes: 40,
                status: 'KABUL_EDILDI',
              ),
              SubTopic(
                id: 'sub-s4-2',
                title: 'Yerli Güneş Hücresi Üreticilerine %25 Vergi Muafiyeti',
                proposer: '@SanayiMeclisi',
                yesVotes: 980,
                noVotes: 60,
                status: 'KABUL_EDILDI',
              ),
            ],
            comments: [
              CommentItem(
                id: 'com-s4-1',
                author: '@EnerjiBakanligi',
                text: 'Kural 4 tamamlandı: Teklif çoğunluk nisabını (%94.3) aşarak resmi kanun statüsüne geçti ve Blok #1050\'ye mühürlendi.',
                timestamp: '12:00',
                txHash: '0x9948c201fa00',
              ),
            ],
          ),
        ];
      } else {
        _activeScenarioName = 'Senaryo 5: Sıfırdan Canlı Sunum Modu (Boş Taslak)';
        topics = [
          Topic(
            id: 'top-s5-1',
            title: 'Hocanın Belirleyeceği Örnek Yasa Teklifi (Taslak)',
            content: 'Bu alana sunum sırasında hocanızın derste söyleyeceği yasa tasarısı metnini girebilir, canlı olarak karesel oylama ve alt konuları test edebilirsiniz.',
            author: activeCitizen.pseudonym,
            category: 'Genel Yönetişim',
            yesVotes: 10,
            noVotes: 2,
            status: 'OYLAMADA',
            ontologyScore: 90,
            hasAmendment: false,
            subTopics: [],
            comments: [],
          ),
        ];
      }

      blockchain = [
        Block(
          index: 1045,
          timestamp: '2026-10-01 10:15',
          hash: '0x0000e84b12f990ac',
          prevHash: '0x0000a4b91f08e41c',
          merkleRoot: '0x3f9a88c21e01',
          nonce: 74912,
          transactions: ['GENESIS_STATE: Senaryo #$scenarioId Yüklendi', 'ZK_VERIFY: ${activeCitizen.pseudonym}'],
        ),
        Block(
          index: 1046,
          timestamp: '2026-10-01 10:30',
          hash: '0x00003b7194f109de',
          prevHash: '0x0000e84b12f990ac',
          merkleRoot: '0x99a1bc4028fa',
          nonce: 41289,
          transactions: ['TOPIC_SYNC: ${topics.first.title.substring(0, min(24, topics.first.title.length))}', 'CONSENSUS_RULE: Karesel Oylama & Normlar Hiyerarşisi'],
        ),
      ];
    });

    if (showFeedback && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E293B),
          content: Text('✅ $_activeScenarioName yüklendi!', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addBlock(String txSummary) {
    final last = blockchain.last;
    final newHash = '0x0000${sha256.convert(utf8.encode(DateTime.now().toIso8601String() + txSummary)).toString().substring(0, 12)}';
    setState(() {
      blockchain.add(Block(
        index: last.index + 1,
        timestamp: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        hash: newHash,
        prevHash: last.hash,
        merkleRoot: '0x${Random().nextInt(999999).toRadixString(16)}',
        nonce: Random().nextInt(90000) + 10000,
        transactions: [txSummary],
      ));
    });
  }

  void _castQuadraticVote(Topic topic, bool isIncrement) {
    int current = userTopicVotes[topic.id] ?? 0;
    int target = isIncrement ? current + 1 : current - 1;
    if (target < 0) return;

    int costCurrent = current * current;
    int costTarget = target * target;
    int diffCost = costTarget - costCurrent;

    int available = activeCitizen.voiceCredits - activeCitizen.spentCredits;
    if (isIncrement && diffCost > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yetersiz Ses Kredisi! Gereken: $diffCost VC, Mevcut: $available VC')),
      );
      return;
    }

    setState(() {
      userTopicVotes[topic.id] = target;
      activeCitizen.spentCredits += diffCost;
      topic.yesVotes += isIncrement ? 1 : -1;
    });

    _addBlock('VOTE_CAST_QV: ${activeCitizen.pseudonym} -> ${topic.title.substring(0, min(15, topic.title.length))} ($target Oy, $diffCost VC)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon/app_logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'DEMOKRASİ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
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
                const SizedBox(width: 2),
                Text(
                  '${activeCitizen.voiceCredits - activeCitizen.spentCredits} VC',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Ayarlar & Senaryo İkonu
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF818CF8), size: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            tooltip: 'Senaryolar & Ayarlar',
            onPressed: () => _showSettingsAndScenariosSheet(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTopicsTab(),
          _buildGraphTab(),
          _buildOntologyExpertTab(),
          _buildLedgerTab(),
          _buildKYCTab(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // -------------------------------------------------------------------------
  // ÖZEL, MİNİMALİST VE ŞIK BOTTOM NAVIGATION BAR
  // -------------------------------------------------------------------------

  Widget _buildCustomBottomNav() {
    final navItems = [
      {'icon': Icons.how_to_vote_outlined, 'activeIcon': Icons.how_to_vote, 'label': 'Konular'},
      {'icon': Icons.hub_outlined, 'activeIcon': Icons.hub, 'label': 'İnsan Grafı'},
      {'icon': Icons.gavel_outlined, 'activeIcon': Icons.gavel, 'label': 'Bilirkişi'},
      {'icon': Icons.account_tree_outlined, 'activeIcon': Icons.account_tree, 'label': 'Defter'},
      {'icon': Icons.badge_outlined, 'activeIcon': Icons.badge, 'label': 'Kimlik'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1D),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (idx) {
            final item = navItems[idx];
            final isSelected = _currentIndex == idx;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = idx),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? (item['activeIcon'] as IconData) : (item['icon'] as IconData),
                        size: 20,
                        color: isSelected ? const Color(0xFF38BDF8) : Colors.white38,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 1. SEKME: KONULAR VE OYLAMA (FERAH & MODERN TASARIM)
  // -------------------------------------------------------------------------

  Widget _buildTopicsTab() {
    // Filtreleme mantığı
    List<Topic> filtered = topics;
    if (_selectedFilter == 'Oylamada') {
      filtered = topics.where((t) => t.status == 'OYLAMADA').toList();
    } else if (_selectedFilter == 'Yürürlükte') {
      filtered = topics.where((t) => t.status == 'KABUL_EDILDI').toList();
    } else if (_selectedFilter == 'Veto') {
      filtered = topics.where((t) => t.status == 'REDDEDILDI' || t.ontologyScore < 50).toList();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // 1. Üst Kimlik & Rol Çubuğu
        _buildUserRoleBar(),
        const SizedBox(height: 10),

        // 2. Felsefi Soru & Çözüm Hero Kartı (Kompakt ve Şık)
        _buildTyrannyCompactHero(),
        const SizedBox(height: 10),

        // 3. Filtreleme ve Yeni Teklif Çubuğu
        Row(
          children: [
            // Filtre Hapları (Yatay Kaydırılabilir - Asla Taşmaz)
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFF38BDF8) : Colors.transparent),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
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
            // Yeni Teklif Butonu (Kompakt)
            ElevatedButton.icon(
              onPressed: () => _showCreateTopicDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Yeni Yasa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 4. Konu Kartları
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text('Bu filtrede gösterilecek yasa konusu bulunamadı.', style: TextStyle(fontSize: 11, color: Colors.white38)),
            ),
          )
        else
          ...filtered.map((t) => _buildTopicCard(t)),
      ],
    );
  }

  Widget _buildUserRoleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _currentIndex = 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                    child: const Icon(Icons.verified, color: Color(0xFF10B981), size: 13),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${activeCitizen.pseudonym} (${activeCitizen.role})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showSettingsAndScenariosSheet(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.swap_horiz, size: 13, color: Color(0xFF818CF8)),
                SizedBox(width: 3),
                Text('Senaryo Değiştir', style: TextStyle(fontSize: 10, color: Color(0xFF818CF8), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyrannyCompactHero() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.5),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: Color(0xFFF59E0B), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Çoğunluk Azınlığı Tüketebilir Mi?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 2),
                Text('Karesel Oylama (Maliyet = Oy²) ve %30 Azınlık Rıza Eşiği Çözümü.', style: TextStyle(fontSize: 9, color: Colors.white70)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showTyrannyTestbench(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Deneyi Gör', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Topic topic) {
    int userVotes = userTopicVotes[topic.id] ?? 0;
    int nextCost = (userVotes + 1) * (userVotes + 1) - (userVotes * userVotes);
    final bool isVetoed = topic.status == 'REDDEDILDI' || topic.ontologyScore < 50;

    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isVetoed ? Colors.redAccent.withValues(alpha: 0.5) : const Color(0xFF1E293B),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori, Durum Rozeti ve Hızlı Ayar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    topic.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Durum Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: topic.status == 'KABUL_EDILDI'
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : (isVetoed ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        topic.status == 'KABUL_EDILDI'
                            ? '✓ Yürürlükte'
                            : (isVetoed ? '✕ Veto Edildi' : '🗳️ Oylamada'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: topic.status == 'KABUL_EDILDI'
                              ? const Color(0xFF10B981)
                              : (isVetoed ? Colors.redAccent : const Color(0xFFF59E0B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Ontoloji Skoru
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVetoed ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF818CF8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '%${topic.ontologyScore}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isVetoed ? Colors.redAccent : const Color(0xFF818CF8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Manuel Düzenle İkonu
                    InkWell(
                      onTap: () => _showQuickTopicEditSheet(topic),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.tune, size: 14, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Başlık
            Text(
              topic.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 3),

            // İçerik Özeti
            Text(
              topic.content,
              style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
            ),

            // Kural 6: Veto Uyarısı Varsa
            if (isVetoed && topic.vetoReason != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.gavel, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(topic.vetoReason!, style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),

            // Kural 1: Diff Kutusu Varsa
            if (topic.hasAmendment)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '⚡ Aktif Düzenleme Teklifi (Diff)',
                        style: TextStyle(fontSize: 10, color: Color(0xFF06B6D4), fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showAmendmentDiffDialog(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF06B6D4), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Farkı Gör', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Oylama Çubuğu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Evet: %${topic.approvalRate.toStringAsFixed(1)} (${topic.yesVotes})', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                Text('Hayır: ${topic.noVotes}', style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: topic.approvalRate / 100,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                minHeight: 4,
              ),
            ),

            // Karesel Oylama Alanı (Sadece OYLAMADA ise)
            if (topic.status == 'OYLAMADA') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text(
                      'Karesel: $userVotes Oy (${userVotes * userVotes} VC)',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: userVotes > 0 ? () => _castQuadraticVote(topic, false) : null,
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('$userVotes', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () => _castQuadraticVote(topic, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text('+1 ($nextCost VC)', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          topic.status = topic.approvalRate >= 50 ? 'KABUL_EDILDI' : 'REDDEDILDI';
                        });
                        _addBlock('TOPIC_ENACTED: ${topic.title} -> ${topic.status}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Sonuçlandır', style: TextStyle(fontSize: 9, color: Color(0xFF818CF8), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 6),
            const Divider(color: Color(0xFF1E293B), height: 12),

            // Alt Butonlar: Alt Konular ve Müzakere
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showSubTopicsDialog(topic),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_tree_outlined, size: 12, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Alt Konular (${topic.subTopics.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDiscussionDialog(topic),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Müzakere (${topic.comments.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ÇOĞUNLUK VS AZINLIK SİMÜLATÖR MODALI
  // -------------------------------------------------------------------------

  void _showTyrannyTestbench() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        int majorityCount = 70;
        int minorityCount = 15;
        int minorityVoteLevel = 8;

        int tradMaj = majorityCount;
        int tradMin = minorityCount;
        int qvMaj = majorityCount * 1;
        int qvMin = (minorityCount * minorityVoteLevel * 1.8).round();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Çoğunluk Azınlığı Tüketebilir Mi? Çözüm Simülasyonu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                const Text('70 Yüzeysel Çoğunluk Seçmeni vs 15 Hayati Haklarını Savunan Azınlık Seçmeni:', style: TextStyle(fontSize: 10, color: Colors.white70)),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4))),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geleneksel Çoğunlukçuluk (1 Kişi = 1 Oy):\nÇoğunluk: $tradMaj Oy > Azınlık: $tradMin Oy (AZINLIK EZİLDİ)',
                          style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4))),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bizim Karesel Oylama & Bilirkişi Protokolümüz:\nAzınlık Tercih Yoğunluğu: $qvMin Oy > Çoğunluk: $qvMaj Oy (AZINLIK HAKKINI KORUDU)',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), minimumSize: const Size.fromHeight(36)),
                  child: const Text('Anladım, Kapat', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // 2. SEKME: İNSAN GRAFI (Web of Trust - Canvas CustomPainter)
  // -------------------------------------------------------------------------

  Widget _buildGraphTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: const Color(0xFF0F172A),
          child: const Row(
            children: [
              Icon(Icons.hub, color: Color(0xFF38BDF8), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hocanın "İnsanları grafta tut" kuralı: Yurttaşlar, Bilirkişiler ve Mevzuat düğümleri arasındaki güven bağı.',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Düğüm Seçildi: Güven Skoru 0.94, ZKP Doğrulaması Aktif'), duration: Duration(milliseconds: 1000)),
              );
            },
            child: CustomPaint(
              painter: TrustGraphPainter(
                citizens: citizens,
                onNodeTap: (name) {},
              ),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 3. SEKME: BİLİRKİŞİ VE YÖNETMELİK ONTOLOJİSİ (Kural 6)
  // -------------------------------------------------------------------------

  Widget _buildOntologyExpertTab() {
    final activeTopic = topics.isNotEmpty ? topics.first : null;
    final isVetoed = activeTopic != null && (activeTopic.status == 'REDDEDILDI' || activeTopic.ontologyScore < 50);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Kural 6: Normlar Hiyerarşisi Ontolojisi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF818CF8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVetoed ? Colors.red.withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVetoed ? 'VETO / AYKIRI' : 'UYUMLU',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHierarchyLayer('1. Anayasa (Temel Haklar)', 'Madde 56: Çevre hakkı / Madde 43: Kıyılar kamu yararına açıktır.', const Color(0xFFEF4444)),
                _buildHierarchyLayer('2. Kanun (Üst Norm)', 'Çevre Kanunu Madde 9: Yeşil alanların imara açılması sınırlandırılmıştır.', const Color(0xFFF59E0B)),
                _buildHierarchyLayer('3. Yönetmelik (Yerel Karar)', 'Belediye Park ve Bahçeler Uygulama Yönetmeliği', const Color(0xFF10B981)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Yapay Zeka Ontoloji Denetim Motoru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF38BDF8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeTopic != null ? '%${activeTopic.ontologyScore} Uyum' : '%96 Uyum',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isVetoed
                      ? '⚠️ KRİTİK UYARISI: Teklif edilen yönetmelik Anayasa Madde 43 hükmüyle doğrudan çatışmaktadır. Yerel yönetmelik üst normu kısıtlayamayacağı için Bilirkişi Veto kararı verilmiştir.'
                      : '✓ SEMANTİK ANALİZ: Teklif edilen yönetmelik Anayasa Madde 56 ve Çevre Kanunu ile %96 uyumludur. Hiyerarşik çelişki bulunmamıştır.',
                  style: TextStyle(fontSize: 10, color: isVetoed ? Colors.redAccent : Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bilirkişi Entegrasyonu & Kararları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF59E0B))),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(radius: 16, backgroundColor: Color(0xFF2563EB), child: Text('İA', style: TextStyle(color: Colors.white, fontSize: 11))),
                  title: const Text('Prof. Dr. İlker Akman (Anayasa Hukukçusu)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isVetoed ? 'Karar: RED & VETO (Hiyerarşik norm ihlali)' : 'Görüş: UYGUNDUR. Üst norm hiyerarşisi korunmuştur.',
                    style: TextStyle(fontSize: 9, color: isVetoed ? Colors.redAccent : const Color(0xFF10B981), fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: const Text('2.2x Çarpan', style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHierarchyLayer(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 9, color: Colors.white70)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 4. SEKME: DAĞITIK DEFTER (Blockchain Explorer)
  // -------------------------------------------------------------------------

  Widget _buildLedgerTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Dağıtık Defter & Blok Gezgini',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                _addBlock('MANUAL_MINE: Blok #${blockchain.length + 1045} Kazıldı');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni blok başarıyla kazıldı ve deftere eklendi!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_box, size: 12),
              label: const Text('Yeni Blok Kaz', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('Her oy, teklif ve yorum kriptografik özetle zincire işlenir. Geriye dönük silinemez.', style: TextStyle(fontSize: 10, color: Colors.white54)),
        const SizedBox(height: 10),
        ...blockchain.reversed.map((block) => Card(
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Blok #${block.index}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF38BDF8))),
                        Text(block.timestamp, style: const TextStyle(fontSize: 9, color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Hash: ${block.hash}', style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Color(0xFF10B981))),
                    Text('Önceki: ${block.prevHash} | Merkle: ${block.merkleRoot}', style: const TextStyle(fontSize: 8, fontFamily: 'monospace', color: Colors.white38)),
                    const Divider(color: Color(0xFF1E293B), height: 10),
                    ...block.transactions.map((tx) => Text('• $tx', style: const TextStyle(fontSize: 9, color: Colors.white70))),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // 5. SEKME: KİMLİK / KYC & ZKP (Kural 3)
  // -------------------------------------------------------------------------

  Widget _buildKYCTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
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
                    Icon(Icons.lock, color: Color(0xFFF59E0B), size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kural 3: Sistem Tarafında Tutulan Gerçek Kimlik',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFF59E0B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildKYCRow('Adı Soyadı:', activeCitizen.fullName),
                _buildKYCRow('T.C. Kimlik No:', '${activeCitizen.tcNo.substring(0, 3)}*****${activeCitizen.tcNo.substring(8)}'),
                _buildKYCRow('Doğum Tarihi:', activeCitizen.birthDate),
                _buildKYCRow('İkametgah Adresi:', '${activeCitizen.district} / ${activeCitizen.city}'),
                _buildKYCRow('Rol & Yetki:', activeCitizen.role),
                _buildKYCRow('Oy Ağırlığı:', '${activeCitizen.expertMultiplier}x'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halka Açık Kamusal Kimlik (ZKP Katmanı)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF38BDF8))),
                const SizedBox(height: 6),
                Text(activeCitizen.pseudonym, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Kayıtlı Bölge: ${activeCitizen.district} | İtibar Skoru: ${activeCitizen.reputation}/100', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                const SizedBox(height: 6),
                const Text('Sıfır Bilgi İspatı (ZKP) ile ad ve adres asla halka açık deftere yansıtılmaz.', style: TextStyle(fontSize: 9, color: Colors.white38, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () => _showSettingsAndScenariosSheet(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.tune, size: 16),
          label: const Text('⚙️ Sunum Senaryoları & Manuel Ayarlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        const SizedBox(height: 12),

        const Text('Farklı Bir Yurttaş Profili Seç:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 6),
        ...citizens.map((c) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${c.pseudonym} (${c.role})', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('${c.fullName} - ${c.district} | ${c.voiceCredits} VC', style: const TextStyle(fontSize: 9, color: Colors.white54)),
              trailing: activeCitizen.id == c.id ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16) : null,
              onTap: () => setState(() => activeCitizen = c),
            )),
      ],
    );
  }

  Widget _buildKYCRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SENARYOLAR VE MANUEL AYARLAR MODAL BOTTOM SHEET
  // -------------------------------------------------------------------------

  void _showSettingsAndScenariosSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const TabBar(
                  indicatorColor: Color(0xFF818CF8),
                  labelColor: Color(0xFF818CF8),
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(text: '🎭 Hoca Senaryoları'),
                    Tab(text: '🛠️ Manuel Kontroller'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: 5 HAZIR HOCA SUNUM SENARYOSU
                      ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          const Text('Sunum Sırasında Tek Tıkla Yüklenebilen Senaryolar:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                          const SizedBox(height: 8),
                          _buildScenarioCard(
                            id: 1,
                            title: '1. Çoğunluk vs Azınlık & Karesel Oylama',
                            badge: 'Azınlık Koruma & Kural 1-2-5',
                            badgeColor: const Color(0xFFF59E0B),
                            desc: 'Kentsel Dönüşüm tasarısı. 15 kişilik mahalle azınlığı Karesel Oylama ile haklarını koruyor. Yağmur suyu diff önergesi ve bisiklet yolu alt konusu aktif.',
                          ),
                          _buildScenarioCard(
                            id: 2,
                            title: '2. Anayasaya Aykırı Teklif & Normlar Hiyerarşisi',
                            badge: 'Kural 6 (Ontoloji Veto)',
                            badgeColor: Colors.redAccent,
                            desc: 'Kıyı şeritlerinin özelleştirilmesi teklifi. Anayasa Madde 43 ihlali nedeniyle AI ontoloji skoru %18\'e düşmüş ve Prof. Dr. İlker Akman tarafından VETO edilmiştir.',
                          ),
                          _buildScenarioCard(
                            id: 3,
                            title: '3. KVKK İhlali & Defterde Sansür Oylaması',
                            badge: 'Kural 7 & 8 (Defter & Sansür)',
                            badgeColor: const Color(0xFF06B6D4),
                            desc: 'Öğrenci temsilcisinin şahsi telefon ve adresi sızdırılmış. Kural 7 gereği defterden silinemez, Kural 8 gereği %66 topluluk oylaması ile maskelenir.',
                          ),
                          _buildScenarioCard(
                            id: 4,
                            title: '4. Kabul Edilmiş Resmi Kanun & Alt Başlıklar',
                            badge: 'Kural 4 & 5 (Yürürlük)',
                            badgeColor: const Color(0xFF10B981),
                            desc: 'Yenilenebilir Enerji Kanunu. %94 oyla yürürlüğe girmiş, alt konularıyla birlikte resmi deftere mühürlenmiştir.',
                          ),
                          _buildScenarioCard(
                            id: 5,
                            title: '5. Sıfırdan Canlı / Boş Başlangıç',
                            badge: 'Manuel Sunum',
                            badgeColor: const Color(0xFF818CF8),
                            desc: 'Hocanın o an derste belirleyeceği herhangi bir yasa teklifini sıfırdan girip gösterebilmeniz için boş taslak modu.',
                          ),
                        ],
                      ),

                      // TAB 2: CANLI MANUEL KONTROLLER
                      StatefulBuilder(
                        builder: (context, setSheetState) {
                          final curTopic = topics.isNotEmpty ? topics.first : null;

                          return ListView(
                            padding: const EdgeInsets.all(14),
                            children: [
                              if (curTopic != null) ...[
                                Card(
                                  color: const Color(0xFF090D16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Seçili Konu: ${curTopic.title}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Evet: ${curTopic.yesVotes}', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle, color: Colors.white54, size: 16),
                                                  onPressed: () {
                                                    setSheetState(() => curTopic.yesVotes = max(0, curTopic.yesVotes - 20));
                                                    setState(() {});
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 16),
                                                  onPressed: () {
                                                    setSheetState(() => curTopic.yesVotes += 20);
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Hayır: ${curTopic.noVotes}', style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle, color: Colors.white54, size: 16),
                                                  onPressed: () {
                                                    setSheetState(() => curTopic.noVotes = max(0, curTopic.noVotes - 20));
                                                    setState(() {});
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle, color: Colors.redAccent, size: 16),
                                                  onPressed: () {
                                                    setSheetState(() => curTopic.noVotes += 20);
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const Divider(color: Color(0xFF1E293B)),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setSheetState(() => curTopic.status = 'OYLAMADA');
                                                  setState(() {});
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: curTopic.status == 'OYLAMADA' ? const Color(0xFFF59E0B) : Colors.white10, foregroundColor: curTopic.status == 'OYLAMADA' ? Colors.black : Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 4)),
                                                child: const Text('Oylamada', style: TextStyle(fontSize: 9)),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setSheetState(() => curTopic.status = 'KABUL_EDILDI');
                                                  setState(() {});
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: curTopic.status == 'KABUL_EDILDI' ? const Color(0xFF10B981) : Colors.white10, foregroundColor: curTopic.status == 'KABUL_EDILDI' ? Colors.black : Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 4)),
                                                child: const Text('Kabul Et', style: TextStyle(fontSize: 9)),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setSheetState(() {
                                                    curTopic.status = 'REDDEDILDI';
                                                    curTopic.vetoReason ??= 'Normlar Hiyerarşisi İhlali Nedeniyle Reddedildi';
                                                  });
                                                  setState(() {});
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: curTopic.status == 'REDDEDILDI' ? Colors.redAccent : Colors.white10, foregroundColor: Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 4)),
                                                child: const Text('Veto / Red', style: TextStyle(fontSize: 9)),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Ontoloji Uyumu:', style: TextStyle(fontSize: 10, color: Colors.white70)),
                                            Text('%${curTopic.ontologyScore}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: curTopic.ontologyScore < 50 ? Colors.redAccent : const Color(0xFF818CF8))),
                                          ],
                                        ),
                                        Slider(
                                          value: curTopic.ontologyScore.toDouble(),
                                          min: 0,
                                          max: 100,
                                          divisions: 20,
                                          activeColor: curTopic.ontologyScore < 50 ? Colors.redAccent : const Color(0xFF818CF8),
                                          onChanged: (val) {
                                            setSheetState(() => curTopic.ontologyScore = val.round());
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // Ses Kredisi Yönetimi
                              Card(
                                color: const Color(0xFF090D16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ses Kredisi: ${activeCitizen.voiceCredits - activeCitizen.spentCredits} VC', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setSheetState(() => activeCitizen.voiceCredits += 50);
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 5)),
                                              child: const Text('+50 VC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setSheetState(() => activeCitizen.spentCredits = 0);
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 5)),
                                              child: const Text('Sıfırla', style: TextStyle(fontSize: 9)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Aktif Yurttaş Değiştir
                              Card(
                                color: const Color(0xFF090D16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Aktif Yurttaşı Değiştir:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                                      const SizedBox(height: 4),
                                      ...citizens.map((c) => ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text('${c.pseudonym} (${c.role})', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                            trailing: activeCitizen.id == c.id ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14) : null,
                                            onTap: () {
                                              setSheetState(() => activeCitizen = c);
                                              setState(() {});
                                            },
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScenarioCard({
    required int id,
    required String title,
    required String badge,
    required Color badgeColor,
    required String desc,
  }) {
    final bool isSelected = _activeScenarioId == id;

    return Card(
      color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFF090D16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF1E293B),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(badge, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: badgeColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 9, color: Colors.white70, height: 1.3)),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _loadScenario(id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? const Color(0xFF818CF8) : const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(isSelected ? '✓ Aktif' : 'Yükle', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickTopicEditSheet(Topic topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manuel Ayarla: ${topic.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => topic.yesVotes += 25);
                      setSheetState(() {});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    child: const Text('+25 Evet', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => topic.noVotes += 25);
                      setSheetState(() {});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    child: const Text('+25 Hayır', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        minimumSize: Size.zero,
                        side: const BorderSide(color: Color(0xFF10B981)),
                      ),
                      onPressed: () {
                        setState(() => topic.status = 'KABUL_EDILDI');
                        Navigator.pop(ctx);
                      },
                      child: const Text('✓ Kabul Et', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Color(0xFF10B981))),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        minimumSize: Size.zero,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        setState(() {
                          topic.status = 'REDDEDILDI';
                          topic.vetoReason ??= 'Normlar hiyerarşisi aykırılığı nedeniyle veto edildi.';
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('✕ Veto / Red', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        minimumSize: Size.zero,
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                      ),
                      onPressed: () {
                        setState(() => topic.status = 'OYLAMADA');
                        Navigator.pop(ctx);
                      },
                      child: const Text('🗳️ Oylamada', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MODALLAR (Diff, Subtopics, Discussion, Create)
  // -------------------------------------------------------------------------

  void _showAmendmentDiffDialog(Topic topic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Kural 1: Düzenleme Teklifi (Diff Görünümü)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('- Yürürlükteki Hüküm (Eski):', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
              Text(topic.amendmentOldText ?? '', style: const TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.redAccent)),
              const SizedBox(height: 10),
              const Text('+ Teklif Edilen Yeni Hüküm (Diff):', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              Text(topic.amendmentNewText ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
              const SizedBox(height: 10),
              Text('Oylama: ${topic.amendmentYes} Evet / ${topic.amendmentNo} Hayır', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                topic.content = topic.amendmentNewText!;
                topic.hasAmendment = false;
              });
              _addBlock('AMENDMENT_ADOPTED: ${topic.title}');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
            child: const Text('✓ Kabul Et & Metne İşle', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat', style: TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  void _showSubTopicsDialog(Topic topic) {
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: MediaQuery.of(ctx).viewInsets.bottom + 14),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kural 5: Alt Konular (${topic.title})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Expanded(
                    child: topic.subTopics.isEmpty
                        ? const Center(
                            child: Text('Henüz bir alt konu önerilmemiş.', style: TextStyle(fontSize: 10, color: Colors.white54)),
                          )
                        : ListView(
                            children: topic.subTopics.map((sub) => Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFF090D16), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E293B))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(sub.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                            Text('Öneren: ${sub.proposer} | Evet: ${sub.yesVotes} - Hayır: ${sub.noVotes}', style: const TextStyle(fontSize: 8, color: Colors.white54)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      sub.status == 'KABUL_EDILDI'
                                          ? const Text('✓ Kabul', style: TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold))
                                          : ElevatedButton(
                                              onPressed: () {
                                                setModalState(() {
                                                  sub.yesVotes += 1;
                                                  if (sub.approvalRate >= 50 && sub.yesVotes > 150) {
                                                    sub.status = 'KABUL_EDILDI';
                                                  }
                                                });
                                                setState(() {});
                                                _addBlock('SUBTOPIC_VOTE: ${sub.title}');
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), minimumSize: Size.zero),
                                              child: const Text('+1 Oy', style: TextStyle(fontSize: 8)),
                                            ),
                                    ],
                                  ),
                                )).toList(),
                          ),
                  ),
                  const Divider(color: Color(0xFF1E293B)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(hintText: 'Yeni alt konu önerisi...', hintStyle: TextStyle(fontSize: 10)),
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) return;
                          final newSub = SubTopic(
                            id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
                            title: titleCtrl.text.trim(),
                            proposer: activeCitizen.pseudonym,
                            yesVotes: 1,
                            noVotes: 0,
                          );
                          setModalState(() => topic.subTopics.add(newSub));
                          setState(() {});
                          _addBlock('SUBTOPIC_PROPOSED: ${newSub.title}');
                          titleCtrl.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDiscussionDialog(Topic topic) {
    final textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: MediaQuery.of(ctx).viewInsets.bottom + 14),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kural 7 & 8: Silinemez Müzakere Defteri (SHA-256)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView(
                      children: topic.comments.map((com) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: com.isUnderRedaction ? Colors.amber.withValues(alpha: 0.08) : const Color(0xFF090D16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: com.isUnderRedaction ? Colors.amber : const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(com.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                Text(com.txHash, style: const TextStyle(fontSize: 8, fontFamily: 'monospace', color: Color(0xFF38BDF8))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            com.isMasked
                                ? const Text('[Bu içerik %66 Topluluk Oylaması Kararıyla Maskelenmiştir - Hash Korunmaktadır]', style: TextStyle(fontSize: 9, color: Colors.redAccent, fontStyle: FontStyle.italic))
                                : Text(com.text, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                            if (com.isUnderRedaction && !com.isMasked) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('Kural 8: Silme Oylaması (%${com.deleteRate.toStringAsFixed(0)} Silinsin)', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.amber)),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    onPressed: () {
                                      setModalState(() {
                                        com.deleteVotes += 1;
                                        if (com.deleteRate >= 66) {
                                          com.isMasked = true;
                                        }
                                      });
                                      setState(() {});
                                      _addBlock('REDACTION_VOTE: ${com.txHash}');
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), minimumSize: Size.zero),
                                    child: const Text('Silinsin Oyu Ver', style: TextStyle(fontSize: 8)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textCtrl,
                          decoration: const InputDecoration(hintText: 'Silinemez bir görüş yazın...', hintStyle: TextStyle(fontSize: 10)),
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
                        onPressed: () {
                          if (textCtrl.text.trim().isEmpty) return;
                          final newCom = CommentItem(
                            id: 'com-${DateTime.now().millisecondsSinceEpoch}',
                            author: activeCitizen.pseudonym,
                            text: textCtrl.text.trim(),
                            timestamp: '${DateTime.now().hour}:${DateTime.now().minute}',
                            txHash: '0x${sha256.convert(utf8.encode(textCtrl.text)).toString().substring(0, 8)}',
                          );
                          setModalState(() => topic.comments.add(newCom));
                          setState(() {});
                          _addBlock('COMMENT_IMMUTABLE: ${newCom.txHash}');
                          textCtrl.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateTopicDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Kural 1 & 4: Yeni Konu Aç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Konu Başlığı', labelStyle: TextStyle(fontSize: 10)), style: const TextStyle(fontSize: 10, color: Colors.white)),
              TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Gerekçe Metni', labelStyle: TextStyle(fontSize: 10)), style: const TextStyle(fontSize: 10, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('AI ontoloji motoru anayasal uyumu %94 olarak denetledi.', style: TextStyle(fontSize: 9, color: Color(0xFF818CF8))),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
              final newTopic = Topic(
                id: 'top-${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                content: contentCtrl.text.trim(),
                author: activeCitizen.pseudonym,
                category: 'Genel Yönetişim',
                subTopics: [],
                comments: [],
              );
              setState(() => topics.insert(0, newTopic));
              _addBlock('TOPIC_CREATE: ${newTopic.title}');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Oylamaya Aç', style: TextStyle(fontSize: 10)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// İNTERAKTİF İNSAN GRAFI ÇİZİCİSİ (CustomPainter)
// ---------------------------------------------------------------------------

class TrustGraphPainter extends CustomPainter {
  final List<Citizen> citizens;
  final Function(String) onNodeTap;

  TrustGraphPainter({required this.citizens, required this.onNodeTap});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintLine = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)..strokeWidth = 1.2;

    final nodes = [
      Offset(center.dx - 85, center.dy - 60),
      Offset(center.dx + 85, center.dy - 60),
      Offset(center.dx, center.dy + 80),
      Offset(center.dx - 110, center.dy + 55),
      Offset(center.dx + 110, center.dy + 55),
    ];

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        canvas.drawLine(nodes[i], nodes[j], paintLine);
      }
    }

    final colors = [
      const Color(0xFF38BDF8),
      const Color(0xFFF59E0B),
      const Color(0xFF818CF8),
      const Color(0xFF38BDF8),
      const Color(0xFF10B981),
    ];

    final labels = ['@Adalet', 'Prof. İlker (Uzman)', 'Mevzuat Düğümü', '@Gelecek', '@Bekçi'];

    for (int i = 0; i < nodes.length; i++) {
      final pNode = Paint()..color = colors[i];
      canvas.drawCircle(nodes[i], 16, pNode);
      canvas.drawCircle(nodes[i], 20, Paint()..color = colors[i].withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 2);

      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(nodes[i].dx - textPainter.width / 2, nodes[i].dy + 23));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
