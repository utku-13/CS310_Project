import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class DailyTipsPage extends StatefulWidget {
  const DailyTipsPage({super.key});

  @override
  State<DailyTipsPage> createState() => _DailyTipsPageState();
}

class _DailyTipsPageState extends State<DailyTipsPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'Sabah Farkındalığı',
      'description': 'Gününüze 5 dakikalık farkındalık nefesi ile başlayın. Sakin bir yer bulun, rahatça oturun ve nefesinize odaklanın. Bu pratik gün boyunca stresi azaltmaya ve odaklanmayı artırmaya yardımcı olabilir.',
      'category': 'Farkındalık',
      'duration': '5 dakika',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFFFFB74D),
      'isExpanded': false,
    },
    {
      'title': 'Şükran Günlüğü',
      'description': 'Bugün için minnettar olduğunuz üç şeyi yazmak için bir an ayırın. Bu basit pratik, odaklanmanızı hayatın olumlu yönlerine kaydırmanıza ve genel refahınızı artırmanıza yardımcı olabilir.',
      'category': 'Kendine Bakım',
      'duration': '10 dakika',
      'icon': Icons.favorite_outline,
      'color': Color(0xFFE57373),
      'isExpanded': false,
    },
    {
      'title': 'Dijital Detoks',
      'description': 'Ekransız 30 dakika ayırın. Bu süreyi doğayla bağlantı kurmak, kitap okumak veya yaratıcı bir aktiviteye katılmak için kullanın. Dijital uyarıcılardan bu mola, kaygıyı azaltmaya ve uyku kalitesini artırmaya yardımcı olabilir.',
      'category': 'Dijital Sağlık',
      'duration': '30 dakika',
      'icon': Icons.phone_android,
      'color': Color(0xFF81C784),
      'isExpanded': false,
    },
    {
      'title': 'Progresif Kas Gevşetmesi',
      'description': 'Vücudunuzdaki her kas grubunu gererek ve sonra gevşeterek progresif kas gevşetmesi pratiği yapın. Ayak parmaklarınızdan başlayıp başınıza doğru ilerleyin. Bu teknik fiziksel gerginliği azaltmaya ve gevşemeyi teşvik etmeye yardımcı olabilir.',
      'category': 'Stres Yönetimi',
      'duration': '15 dakika',
      'icon': Icons.spa_outlined,
      'color': Color(0xFF64B5F6),
      'isExpanded': false,
    },
    {
      'title': 'Derin Nefes Egzersizi',
      'description': '4-7-8 nefes tekniğini deneyin: 4 saniye nefes alın, 7 saniye tutun, 8 saniye verin. Bu basit egzersiz sinir sisteminizi sakinleştirmeye ve uykuya dalmanıza yardımcı olabilir.',
      'category': 'Nefes Teknikleri',
      'duration': '5 dakika',
      'icon': Icons.air,
      'color': Color(0xFFBA68C8),
      'isExpanded': false,
    },
    {
      'title': 'Günlük Yürüyüş',
      'description': 'Günde en az 20 dakika yürüyüş yapın. Doğada yapılan yürüyüşler özellikle faydalıdır ve ruh halinizi iyileştirmeye, stresi azaltmaya yardımcı olabilir.',
      'category': 'Fiziksel Aktivite',
      'duration': '20 dakika',
      'icon': Icons.directions_walk,
      'color': Color(0xFF4DB6AC),
      'isExpanded': false,
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTip(int index) {
    setState(() {
      _tips[index]['isExpanded'] = !_tips[index]['isExpanded'];
    });
  }

  void _saveToFavorites(int index) {
    final tip = _tips[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${tip['title']} favorilere eklendi'),
          ],
        ),
        backgroundColor: AppStyles.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
        ),
      ),
    );
  }

  void _shareTip(int index) {
    final tip = _tips[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text('Paylaşım özelliği henüz eklenmedi'),
          ],
        ),
        backgroundColor: AppStyles.infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppStyles.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Günlük İpuçları',
              style: AppStyles.headingSmallStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppStyles.accentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.largePadding),
                decoration: BoxDecoration(
                  gradient: AppStyles.accentGradient,
                  borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
                  boxShadow: AppStyles.elevatedShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bugünün İpucu',
                                style: AppStyles.headingSmallStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Ruh sağlığınızı destekleyen pratik öneriler',
                                style: AppStyles.bodyStyle.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Her gün yeni bir ipucu keşfedin ve kendinizi daha iyi hissedin',
                      style: AppStyles.bodyMediumStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppStyles.largePadding),
              
              // Tips Section
              Text(
                'Önerilen İpuçları',
                style: AppStyles.headingMediumStyle,
              ),
              const SizedBox(height: AppStyles.defaultPadding),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  final tip = _tips[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.1;
                      final animation = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(delay, delay + 0.6, curve: Curves.easeOutCubic),
                      ));
                      
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - animation.value)),
                        child: Opacity(
                          opacity: animation.value,
                          child: _buildTipCard(tip, index),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip, int index) {
    final isExpanded = tip['isExpanded'] as bool;
    final icon = tip['icon'] as IconData;
    final color = tip['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      decoration: AppStyles.elevatedCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTip(index),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'] as String,
                            style: AppStyles.headingSmallStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tip['category'] as String,
                                  style: AppStyles.captionStyle.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppStyles.textLightColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: AppStyles.textLightColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tip['duration'] as String,
                                      style: AppStyles.captionStyle.copyWith(
                                        color: AppStyles.textLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppStyles.textSecondaryColor,
                    ),
                  ],
                ),
                
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppStyles.textLightColor.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip['description'] as String,
                    style: AppStyles.bodyStyle.copyWith(
                      color: AppStyles.textPrimaryColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppStyles.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            color: AppStyles.primaryColor,
                          ),
                          onPressed: () => _saveToFavorites(index),
                          tooltip: 'Favorilere Ekle',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppStyles.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: AppStyles.infoColor,
                          ),
                          onPressed: () => _shareTip(index),
                          tooltip: 'Paylaş',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 