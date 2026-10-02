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
      title: 'Demokrasi Platformu',
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
                width: 22,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'DEMOKRASİ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          // Ses Kredisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 11),
                const SizedBox(width: 2),
                Text(
                  '${activeCitizen.availableCredits} VC',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Sunum Senaryoları & Rehber Menüsü
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
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
                    Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 14),
                    SizedBox(width: 6),
                    Text('Platform Rehberi (Nasıl Çalışır?)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 1, child: Text('1. Kentsel Dönüşüm & Karesel Oylama', style: TextStyle(fontSize: 11))),
              const PopupMenuItem(value: 2, child: Text('2. Anayasaya Aykırı Teklif (Veto Örneği)', style: TextStyle(fontSize: 11))),
              const PopupMenuItem(value: 3, child: Text('3. KVKK İhlali & Sansür Oylaması', style: TextStyle(fontSize: 11))),
              const PopupMenuItem(value: 4, child: Text('4. Yürürlükteki Resmi Mevzuat', style: TextStyle(fontSize: 11))),
              const PopupMenuItem(value: 5, child: Text('5. Sıfırdan Boş Başlangıç', style: TextStyle(fontSize: 11))),
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
        content: Text('✅ Senaryo $id yüklendi.', style: const TextStyle(fontSize: 11, color: Colors.white)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                      size: 20,
                      color: isSel ? const Color(0xFF38BDF8) : Colors.white38,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      it['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
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
            InkWell(
              onTap: _showCreateProposalDialog,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.white),
                    SizedBox(width: 2),
                    Text('Teklif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
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
              child: Text('Bu filtreye uygun yasa teklifi bulunamadı.', style: TextStyle(fontSize: 11, color: Colors.white38)),
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
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: prop.status == 'KABUL_EDILDI'
                            ? const Color(0xFF10B981)
                            : (isVetoed ? Colors.redAccent : const Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isVetoed ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF818CF8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '%${prop.ontologyScore} Uyum',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),

              // Gerekçe Özeti
              Text(
                prop.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
              ),

              // Veto Uyarısı Varsa
              if (isVetoed && prop.vetoReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gavel, color: Colors.redAccent, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          prop.vetoReason!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Oylama Oranı Çubuğu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Evet: %${prop.approvalRate.toStringAsFixed(1)} (${prop.yesVotes})', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  Text('Hayır: ${prop.noVotes}', style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: prop.approvalRate / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 8),

              // Alt Bilgiler ve Detay Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (prop.hasAmendment)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.difference_outlined, size: 12, color: Color(0xFF06B6D4)),
                              SizedBox(width: 3),
                              Text('Diff Aktif', style: TextStyle(fontSize: 9, color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_tree_outlined, size: 12, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 3),
                            Text('${prop.subTopics.length} Alt Madde', style: const TextStyle(fontSize: 9, color: Color(0xFF38BDF8))),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 12, color: Colors.white54),
                            const SizedBox(width: 3),
                            Text('${prop.comments.length} Görüş', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('İncele & Oyla', style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, size: 14, color: Color(0xFF38BDF8)),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVetoed ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prop.status == 'KABUL_EDILDI' ? '✓ Yürürlükte' : (isVetoed ? 'Veto' : 'Oylamada'),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // 1. Yasa Başlığı ve Metni
                  Text(prop.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text('Öneren: ${prop.author}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yasa Metni & Gerekçe:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                        const SizedBox(height: 6),
                        Text(prop.content, style: const TextStyle(fontSize: 11, color: Colors.white, height: 1.4)),
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
      padding: const EdgeInsets.all(12),
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
                    Icon(Icons.difference_outlined, size: 14, color: Color(0xFF06B6D4)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Metin Değişiklik Önergesi (Diff)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4))),
                    ),
                  ],
                ),
              ),
              if (!prop.hasAmendment)
                TextButton.icon(
                  onPressed: () => _showAddAmendmentDialog(prop, setDetailState),
                  icon: const Icon(Icons.edit_note, size: 14),
                  label: const Text('Önerge Ver', style: TextStyle(fontSize: 10)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (prop.hasAmendment) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('[-] Yürürlükteki Madde (Eski):', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  const SizedBox(height: 2),
                  Text(prop.amendmentOldText ?? '', style: const TextStyle(fontSize: 10, color: Colors.redAccent, decoration: TextDecoration.lineThrough)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('[+] Teklif Edilen Düzenleme (Diff):', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  const SizedBox(height: 2),
                  Text(prop.amendmentNewText ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text('Önerge: ${prop.amendmentYes} Kabul / ${prop.amendmentNo} Red', style: const TextStyle(fontSize: 9, color: Colors.white70)),
                ElevatedButton(
                  onPressed: () {
                    setDetailState(() {
                      prop.content = prop.content.replaceFirst(prop.amendmentOldText ?? '', prop.amendmentNewText ?? prop.content);
                      prop.hasAmendment = false;
                    });
                    setState(() {});
                    _addBlock('DIFF_ENACTED: Düzenleme Kabul Edildi & Metne İşlendi');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                  child: const Text('✓ Kabul Et & Metne İşle', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ] else ...[
            const Text('Şu an aktif bir değişiklik önerisi bulunmuyor. Dilerseniz yukarıdan madde düzenleme teklifi verebilirsiniz.', style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ],
      ),
    );
  }

  // --- BÖLÜM: ALT KONULAR (SUB-TOPICS) ---
  Widget _buildSubTopicsSection(Proposal prop, StateSetter setDetailState) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                    const Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Bağlı Alt Maddeler (${prop.subTopics.length})', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: () => _showAddSubTopicDialog(prop, setDetailState),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Alt Madde Ekle', style: TextStyle(fontSize: 10)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (prop.subTopics.isEmpty)
            const Text('Bu teklife henüz bir alt madde eklenmemiş.', style: TextStyle(fontSize: 10, color: Colors.white54))
          else
            ...prop.subTopics.map((sub) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
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
                            Text(sub.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Öneren: ${sub.proposer} | %${sub.approvalRate.toStringAsFixed(0)} Evet (${sub.yesVotes}/${sub.yesVotes + sub.noVotes})', style: const TextStyle(fontSize: 8, color: Colors.white54)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      sub.status == 'KABUL_EDILDI'
                          ? const Text('✓ Kabul', style: TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold))
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
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                              child: const Text('+1 Oy', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(12),
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
                    Icon(Icons.gavel_outlined, size: 14, color: Color(0xFF818CF8)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Hukuki Denetim & Normlar Hiyerarşisi', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF818CF8))),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isVetoed ? Colors.red.withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isVetoed ? 'VETO' : '%${prop.ontologyScore} UYUMLU',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hiyerarşi Katmanları
          _buildNormStep('1. Anayasa Katmanı (Üst Norm)', 'Madde 56: Çevre hakkı / Madde 43: Kıyılar kamu yararınadır.', isVetoed ? Colors.redAccent : const Color(0xFF10B981)),
          _buildNormStep('2. Kanun Katmanı', 'İlgili Çevre ve Şehircilik Kanunları standartları.', const Color(0xFF10B981)),
          _buildNormStep('3. Yerel Yönetmelik', 'Teklif edilen yerel düzenleme metni.', const Color(0xFF38BDF8)),

          if (isVetoed) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
              child: Text(
                'Bilirkişi Veto Kararı: ${prop.vetoReason ?? "Üst norm ihlali nedeniyle teklif düşürülmüştür."}',
                style: const TextStyle(fontSize: 9, color: Colors.redAccent, height: 1.3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNormStep(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$title: ',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                children: [
                  TextSpan(text: desc, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white70)),
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
      padding: const EdgeInsets.all(12),
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
                    const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Müzakere Defteri (${prop.comments.length} Görüş)', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text('SHA-256', style: TextStyle(fontSize: 8, fontFamily: 'monospace', color: Color(0xFF38BDF8))),
            ],
          ),
          const SizedBox(height: 8),

          ...prop.comments.map((com) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: com.isUnderRedaction ? Colors.amber.withValues(alpha: 0.08) : const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: com.isUnderRedaction ? Colors.amber.withValues(alpha: 0.5) : const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(com.author, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(com.txHash, style: const TextStyle(fontSize: 8, fontFamily: 'monospace', color: Color(0xFF38BDF8))),
                      ],
                    ),
                    const SizedBox(height: 3),
                    com.isMasked
                        ? const Text('[Bu içerik %66 Topluluk Kararıyla Maskelenmiştir - Hash Bütünlüğü Korunmaktadır]', style: TextStyle(fontSize: 9, color: Colors.redAccent, fontStyle: FontStyle.italic))
                        : Text(com.text, style: const TextStyle(fontSize: 10, color: Colors.white70)),

                    // Redaksiyon / Sansürleme Oylaması
                    if (com.isUnderRedaction && !com.isMasked) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Şikayet: ${com.redactionReason} (%${com.deleteRate.toStringAsFixed(0)} Silinsin)', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.amber)),
                            ),
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
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3)),
                              child: const Text('Maskele Oyu Ver', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )),

          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Deftere silinemez bir görüş yazın...',
                    hintStyle: TextStyle(fontSize: 10, color: Colors.white38),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
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
      padding: const EdgeInsets.all(12),
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
                child: Text('Karesel Oylama & Karar', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
              ),
              const SizedBox(width: 6),
              Text('Kullanılan: $userVote Oy (${userVote * userVote} VC)', style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
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
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$userVote Oy', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _castQuadraticVote(prop, true);
                      setDetailState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('+1 Oy Ver ($nextCost VC)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.check, size: 14),
                label: const Text('Oylamayı Sonuçlandır & Yürürlüğe Al', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
          title: const Text('Yeni Yasa Teklifi Sun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Yasa Başlığı', labelStyle: TextStyle(fontSize: 10)),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: const Color(0xFF0F172A),
                  decoration: const InputDecoration(labelText: 'Mevzuat Alanı', labelStyle: TextStyle(fontSize: 10)),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                  items: ['Çevre & Şehircilik', 'Ulaşım & Sosyal Haklar', 'Kıyı Mevzuatı', 'Enerji & Çevre', 'Genel Yönetişim']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => category = val);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Gerekçe ve Yasa Metni', labelStyle: TextStyle(fontSize: 10)),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Expanded(child: Text('AI Mevzuat Ontolojisi teklifi otomatik analiz eder.', style: TextStyle(fontSize: 9, color: Color(0xFF10B981)))),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: const Text('Teklifi Sun', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(fontSize: 10))),
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
        title: const Text('Düzenleme Önergesi Hazırla (Diff)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                decoration: const InputDecoration(labelText: 'Değiştirilmek İstenen Kısım', labelStyle: TextStyle(fontSize: 10)),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newCtrl,
                decoration: const InputDecoration(labelText: 'Önerilen Yeni Hüküm', labelStyle: TextStyle(fontSize: 10)),
                style: const TextStyle(fontSize: 10, color: Colors.white),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4), foregroundColor: Colors.black),
            child: const Text('Önergeyi Sun', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(fontSize: 9))),
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
        title: const Text('Yeni Alt Madde / Konu Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Alt Madde Başlığı', labelStyle: TextStyle(fontSize: 10)),
          style: const TextStyle(fontSize: 10, color: Colors.white),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
            child: const Text('Alt Maddeyi Kaydet', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(fontSize: 9))),
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
        const Text('Normlar Hiyerarşisi & Bilirkişi Katmanı', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Hiyerarşide alt norm (yönetmelik), üst norma (Anayasa) aykırı olamaz. Çoğunluk oyu çıksa dahi anayasal haklar gasp edilemez.', style: TextStyle(fontSize: 10, color: Colors.white54, height: 1.35)),
        const SizedBox(height: 12),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHierarchyCardItem('1. T.C. Anayasası (En Üst Norm)', 'Madde 43: Kıyılar kamu yararına açıktır.\nMadde 56: Herkes sağlıklı ve dengeli bir çevrede yaşama hakkına sahiptir.', const Color(0xFFEF4444)),
                const SizedBox(height: 8),
                _buildHierarchyCardItem('2. Kanunlar', 'Çevre Kanunu, İmar Kanunu, Yenilenebilir Enerji Kanunu.', const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _buildHierarchyCardItem('3. Yerel Yönetmelikler', 'Belediye meclisi ve mahalle konseyleri kararları.', const Color(0xFF10B981)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF1E293B))),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kayıtlı Bilirkişiler ve Oy Ağırlıkları', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 16, backgroundColor: Color(0xFF2563EB), child: Text('İA', style: TextStyle(color: Colors.white, fontSize: 10))),
                  title: Text('Prof. Dr. İlker Akman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('Anayasa Hukuku Bilirkişisi', style: TextStyle(fontSize: 9, color: Colors.white54)),
                  trailing: Text('2.2x Oy Çarpanı', style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(text, style: const TextStyle(fontSize: 9, color: Colors.white70)),
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
              child: Text('Dağıtık Defter (Ledger Explorer)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                _addBlock('MANUAL_MINE: Blok #${ledger.length + 1045} Kazıldı');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni blok başarıyla kazıldı ve zincire eklendi!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              icon: const Icon(Icons.add_box, size: 12),
              label: const Text('Yeni Blok Kaz', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Yapılan tüm yasa teklifleri, oylar ve kararlar kriptografik olarak zincire işlenir. Geriye dönük silinemez.', style: TextStyle(fontSize: 10, color: Colors.white54)),
        const SizedBox(height: 12),

        ...ledger.reversed.map((block) => Card(
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
                    Text('Hash: ${block.hash}', style: const TextStyle(fontSize: 8, fontFamily: 'monospace', color: Color(0xFF10B981))),
                    Text('Önceki: ${block.prevHash} | Merkle: ${block.merkleRoot}', style: const TextStyle(fontSize: 8, fontFamily: 'monospace', color: Colors.white38)),
                    const Divider(color: Color(0xFF1E293B), height: 10),
                    Text('• ${block.summary}', style: const TextStyle(fontSize: 9, color: Colors.white70)),
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
                              const Text('Platform Rehberi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF38BDF8),
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                                child: const Text('7 Sistem', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Karesel oylama, normlar ontolojisi, diff ve kimlik sistemlerini sayfa sayfa öğrenin.',
                            style: TextStyle(fontSize: 9, color: Colors.white70, height: 1.3),
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
                    Icon(Icons.lock, color: Color(0xFFF59E0B), size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Sistem Katmanı: Doğrulanmış Gerçek Kimlik (KYC)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFF59E0B))),
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
                const Text('Kamusal Katman: Sıfır Bilgi İspatı (ZKP Rumuzu)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF38BDF8))),
                const SizedBox(height: 6),
                Text(activeCitizen.pseudonym, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Kayıtlı Bölge: ${activeCitizen.district} | İtibar Skoru: ${activeCitizen.reputation}/100', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                const SizedBox(height: 6),
                const Text('Halka açık defterde ve oylamalarda ad, soyad ve TC asla görünmez; yalnızca ZKP rumuzunuz yer alır.', style: TextStyle(fontSize: 9, color: Colors.white38, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text('Profil Değiştir (Bilirkişi veya Diğer Yurttaş Olarak Test Et):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 8),
        ...citizens.map((c) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${c.pseudonym} (${c.role})', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('${c.fullName} - ${c.district} | ${c.availableCredits} VC', style: const TextStyle(fontSize: 9, color: Colors.white54)),
              trailing: activeCitizen.id == c.id ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16) : null,
              onTap: () => setState(() => activeCitizen = c),
            )),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
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
            'tag': '1/7 • GİZLİLİK VE KİMLİK',
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
                        Text('Sistem Katmanı (KYC)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                        SizedBox(height: 2),
                        Text('T.C. No, Ad, İkametgah', style: TextStyle(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white38, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Kamusal Alan (ZKP)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        SizedBox(height: 2),
                        Text('@AdaletSavunucusu', style: TextStyle(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            'what': 'Sistemde gerçek kimliğiniz doğrulanır ama oylamalarda ve açık defterde asla ifşa edilmez.',
            'how': 'Her yurttaş T.C. kimliğiyle 1 tekil hak alır; fakat halka açık defterde yalnızca Sıfır Bilgi İspatı (ZKP) ile üretilen anonim rumuz görünür.',
            'why': 'Hem sahte bot hesapların ve mükerrer oyların önüne geçilir hem de yurttaşın siyasi baskı veya fişlenme korkusu yaşamadan oy kullanması sağlanır.',
          },
          {
            'tag': '2/7 • OYLAMA MODELİ',
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
                  Text('1 Oy = 1 VC', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  Text('2 Oy = 4 VC', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  Text('3 Oy = 9 VC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  Text('4 Oy = 16 VC', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
            'what': 'Kullanılan oy adedinin maliyetinin karesel (Maliyet = Oy²) olarak arttığı adil bir oylama sistemidir.',
            'how': 'Her yurttaşa 100 Ses Kredisi (Voice Credit - VC) verilir. Bir teklife 1 oy vermek 1 VC, 2 oy vermek 4 VC, 3 oy vermek 9 VC tutar.',
            'why': 'Zenginlerin veya azınlık grupların tüm kredilerini tek bir konuya yığarak sonucu manipüle etmesini engeller. Yurttaş sadece hayatını derinden etkileyen konulara yüksek maliyet ödeyerek oy verir.',
          },
          {
            'tag': '3/7 • HUKUK GÜVENCESİ',
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
                  Text('1. T.C. Anayasası (En Üst Norm)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  SizedBox(height: 2),
                  Text('   ↳ 2. Kanunlar', style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B))),
                  SizedBox(height: 2),
                  Text('      ↳ 3. Yerel Yönetmelikler & Kararlar', style: TextStyle(fontSize: 9, color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Halk oylamasından çoğunluk çıksa dahi temel anayasal normlara aykırı tekliflerin engellenmesidir.',
            'how': 'AI Ontolojisi ve Anayasa Bilirkişisi teklifi denetler. Örneğin halkın %80\'i "kıyılar özelleşsin" dese bile, Anayasa Madde 43 (kıyılar kamu yararınadır) uyarınca teklif derhal VETO edilir.',
            'why': 'Çoğunluğun tiranlığını (çoğunluk oyuyla temel insan ve çevre haklarının gasp edilmesini) önler.',
          },
          {
            'tag': '4/7 • METİN DÜZENLEME',
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
                  Text('[-] Eski: parklarda betonlaşma sınırlandırılsın.', style: TextStyle(fontSize: 9, color: Colors.redAccent, decoration: TextDecoration.lineThrough)),
                  SizedBox(height: 3),
                  Text('[+] Yeni (Diff): parklarda yağmur suyu göletleri kurulsun.', style: TextStyle(fontSize: 9, color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Bir yasa teklifinin tamamını toptan reddetmek yerine sadece belirli bir fıkrasını revize etme mekanizmasıdır.',
            'how': 'Herhangi bir yurttaş kırmızı/yeşil diff önergesi sunar. Topluluk kabul ettiğinde "✓ Kabul Et & Metne İşle" butonuyla yasa tasarısına otomatik eklenir.',
            'why': 'Kutuplaşmış "evet/hayır" kavgaları yerine yapıcı ve uzlaşmacı kanun yapım süreçleri sağlar.',
          },
          {
            'tag': '5/7 • MODÜLER YÖNETİŞİM',
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
                  Text('📋 Ana Teklif: Kentsel Yeşil Koridorlar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 3),
                  Text('   ├─ 🚲 Alt Madde 1: Bisiklet Yolları Standardı (%88 Kabul)', style: TextStyle(fontSize: 9, color: Color(0xFF38BDF8))),
                  Text('   └─ 💡 Alt Madde 2: Güneş Enerjili Aydınlatma (%75 Kabul)', style: TextStyle(fontSize: 9, color: Color(0xFF38BDF8))),
                ],
              ),
            ),
            'what': 'Geniş kapsamlı bir yasanın altındaki özel uygulamaların bağımsız maddeler halinde yapılandırılmasıdır.',
            'how': 'Yurttaşlar ana yasanın altına diledikleri alt maddeyi ekleyebilir. Her alt madde bağımsız oylanır.',
            'why': 'Torba yasa suistimalini önler; iyi bir yasanın içine halkın istemediği bir maddenin gizlice sızdırılması engellenir.',
          },
          {
            'tag': '6/7 • KRİPTOGRAFİK ŞEFFAFLIK',
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
                  Text('Blok #1048 | Hash: 0x8f2a...c31b', style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: Color(0xFF10B981))),
                  Text('Önceki Blok: 0x4a12...99ee | Merkle: 0x11ee...00bb', style: TextStyle(fontSize: 8, fontFamily: 'monospace', color: Colors.white54)),
                  Text('İşlem: [DIFF_ENACTED] Düzenleme Metne İşlendi', style: TextStyle(fontSize: 9, color: Colors.white70)),
                ],
              ),
            ),
            'what': 'Platformda gerçekleşen her teklifin, oyun ve yorumun kriptografik bloklara mühürlendiği değişmez kayıt kütüğüdür.',
            'how': 'Her yeni işlem blok zincirine eklenir. Bir blok madenciliği simülasyonuyla yeni bloklar zincire eklenir.',
            'why': 'Merkezi bir otoritenin, belediyenin veya yöneticinin geçmişe dönük oyları silmesini veya sonuçları tahrif etmesini imkansız kılar.',
          },
          {
            'tag': '7/7 • MAZUR İÇERİK DENETİMİ',
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
                  Text('Şikayet Edilen Yorum: (Nefret / KVKK İhlali)', style: TextStyle(fontSize: 9, color: Colors.amber)),
                  SizedBox(height: 3),
                  Text('[Bu içerik %66 topluluk kararıyla maskelenmiştir]', style: TextStyle(fontSize: 9, color: Colors.redAccent, fontStyle: FontStyle.italic)),
                  Text('SHA-256 Hash Bütünlüğü: KORUNUYOR (0x99a1...ff3b)', style: TextStyle(fontSize: 8, fontFamily: 'monospace', color: Color(0xFF10B981))),
                ],
              ),
            ),
            'what': 'Değişmez blok zincirinde hakaret, nefret veya KVKK ihlali içeren yorumların demokratik denetimidir.',
            'how': 'Bir içerik şikayet edildiğinde topluluk oylamasına girer. %66 oy oranına ulaştığında içerik maskelenir.',
            'why': 'Blok zincirinde kayıt silmek zinciri kıracağı için silme yerine maskeleme yapılır; böylece hem nefret söylemi kamudan saklanır hem de adli kanıt bütünlüğü korunur.',
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
                              Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Platform & Sistem Rehberi', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.5),
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
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Görsel Temsil Kutusu
                            s['visual'] as Widget,
                            const SizedBox(height: 16),

                            // Açıklama Maddeleri
                            _buildGuidePoint('1. Nedir?', s['what'] as String, c),
                            const SizedBox(height: 10),
                            _buildGuidePoint('2. Nasıl Çalışır?', s['how'] as String, const Color(0xFF38BDF8)),
                            const SizedBox(height: 10),
                            _buildGuidePoint('3. Neden Gereklidir?', s['why'] as String, const Color(0xFF10B981)),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),

                  // Alt Navigasyon Barı (Noktalar & Butonlar)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
                                icon: const Icon(Icons.chevron_left, size: 16),
                                label: const Text('Önceki', style: TextStyle(fontSize: 11)),
                              )
                            : const SizedBox(width: 60),

                        // Nokta Göstergesi
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(slides.length, (i) {
                            final isSel = pageIndex == i;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: isSel ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF38BDF8) : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                                label: const Text('Sonraki', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                icon: const Icon(Icons.chevron_right, size: 16),
                              )
                            : ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Anladım ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accent)),
          const SizedBox(height: 3),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.white, height: 1.35)),
        ],
      ),
    );
  }
}

