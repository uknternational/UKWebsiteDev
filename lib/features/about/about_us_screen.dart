import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/about_us_model.dart';
import '../admin/about_us_repository.dart';
import '../../core/constants/app_constants.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  AboutUsContent? aboutUsContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAboutUsContent();
  }

  Future<void> _loadAboutUsContent() async {
    try {
      final content = await AboutUsRepository().fetchActiveAboutUsContent();
      setState(() {
        aboutUsContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF0C1B33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : aboutUsContent == null
          ? _buildDefaultAboutUs()
          : _buildAboutUsContent(aboutUsContent!),
    );
  }

  Widget _buildDefaultAboutUs() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          _buildMainContent(),
          _buildFeaturesSection(),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildAboutUsContent(AboutUsContent content) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSectionWithContent(content),
          _buildMainContentWithData(content),
          _buildFeaturesSectionWithData(content),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C1B33), Color(0xFFA9744F)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Padding(
            padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: isMobile ? 80 : 120),
                const SizedBox(height: 24),
                Text(
                  'About UK International',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Crafting Luxury Fragrances for the Modern World',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSectionWithContent(AboutUsContent content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final maxHeight = isMobile ? 180.0 : 350.0;
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 120),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0C1B33), Color(0xFFA9744F)],
            ),
            image: content.heroImageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(content.heroImageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF0C1B33).withOpacity(0.7),
                      BlendMode.overlay,
                    ),
                  )
                : null,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content.subtitle,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final contentPadding = isMobile
            ? 24.0
            : isTablet
            ? 48.0
            : 120.0;

        return Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'Our Story',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C1B33),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'UK International Perfumes is a premium fragrance house dedicated to creating exceptional scents that capture the essence of luxury and sophistication. Our journey began with a passion for authentic fragrances and a commitment to quality that transcends trends.',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (!isMobile) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildMissionVisionCard(
                        'Our Mission',
                        'To create exceptional fragrances that inspire confidence and evoke emotions, while maintaining the highest standards of quality and authenticity.',
                        Icons.flag,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildMissionVisionCard(
                        'Our Vision',
                        'To become the leading destination for luxury fragrances, known for our commitment to quality, innovation, and customer satisfaction.',
                        Icons.visibility,
                        isMobile,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildMissionVisionCard(
                  'Our Mission',
                  'To create exceptional fragrances that inspire confidence and evoke emotions, while maintaining the highest standards of quality and authenticity.',
                  Icons.flag,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildMissionVisionCard(
                  'Our Vision',
                  'To become the leading destination for luxury fragrances, known for our commitment to quality, innovation, and customer satisfaction.',
                  Icons.visibility,
                  isMobile,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContentWithData(AboutUsContent content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final contentPadding = isMobile
            ? 24.0
            : isTablet
            ? 48.0
            : 120.0;
        final maxTeamImgHeight = isMobile ? 180.0 : 320.0;
        final maxTeamImgWidth = isMobile ? double.infinity : 600.0;

        return Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                content.title,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C1B33),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                content.mainDescription,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (!isMobile) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildMissionVisionCard(
                        'Our Mission',
                        content.mission,
                        Icons.flag,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildMissionVisionCard(
                        'Our Vision',
                        content.vision,
                        Icons.visibility,
                        isMobile,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildMissionVisionCard(
                  'Our Mission',
                  content.mission,
                  Icons.flag,
                  isMobile,
                ),
                const SizedBox(height: 24),
                _buildMissionVisionCard(
                  'Our Vision',
                  content.vision,
                  Icons.visibility,
                  isMobile,
                ),
              ],
              // Team/Vision Image Section
              if (content.teamImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Our Team',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0C1B33),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxTeamImgHeight,
                            maxWidth: maxTeamImgWidth,
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                content.teamImageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionVisionCard(
    String title,
    String description,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1B33).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: isMobile ? 32 : 40,
              color: const Color(0xFF0C1B33),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0C1B33),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final contentPadding = isMobile
            ? 24.0
            : isTablet
            ? 48.0
            : 120.0;

        final features = [
          {
            'icon': '👑',
            'title': 'Premium Quality',
            'description': 'Only the finest ingredients',
          },
          {
            'icon': '🌱',
            'title': 'Cruelty Free',
            'description': 'Ethical and sustainable practices',
          },
          {
            'icon': '💎',
            'title': 'Luxury Experience',
            'description': 'Sophisticated packaging and presentation',
          },
          {
            'icon': '🌸',
            'title': 'Unique Fragrances',
            'description': 'Exclusive and distinctive scents',
          },
        ];

        return Container(
          padding: EdgeInsets.all(contentPadding),
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'Why Choose Us',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C1B33),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile
                      ? 1
                      : isTablet
                      ? 2
                      : 4,
                  childAspectRatio: isMobile ? 3 : 1.2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFECD9B0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C1B33),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feature['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSectionWithData(AboutUsContent content) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final contentPadding = isMobile
            ? 24.0
            : isTablet
            ? 48.0
            : 120.0;

        return Container(
          padding: EdgeInsets.all(contentPadding),
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'Our Values',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0C1B33),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                content.values,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (content.features.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile
                        ? 1
                        : isTablet
                        ? 2
                        : 3,
                    childAspectRatio: isMobile ? 3 : 1.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: content.features.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5EF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFECD9B0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 32,
                            color: const Color(0xFFA9744F),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            content.features[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C1B33),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(48),
      color: const Color(0xFF0C1B33),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          final contentPadding = isMobile
              ? 24.0
              : isTablet
              ? 48.0
              : 120.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: contentPadding),
            child: Column(
              children: [
                Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ready to experience luxury fragrances? Contact us today.',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!isMobile) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactCard(
                        Icons.email,
                        'Email',
                        AppConstants.businessEmail,
                        _launchEmail,
                        isMobile,
                      ),
                      _buildContactCard(
                        Icons.phone,
                        'WhatsApp',
                        '+91 ${AppConstants.whatsappNumber}',
                        _launchWhatsApp,
                        isMobile,
                      ),
                      _buildContactCard(
                        FontAwesomeIcons.instagram,
                        'Instagram',
                        '@${AppConstants.instagramHandle}',
                        _launchInstagram,
                        isMobile,
                      ),
                    ],
                  ),
                ] else ...[
                  _buildContactCard(
                    Icons.email,
                    'Email',
                    AppConstants.businessEmail,
                    _launchEmail,
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    Icons.phone,
                    'WhatsApp',
                    '+91 ${AppConstants.whatsappNumber}',
                    _launchWhatsApp,
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    FontAwesomeIcons.instagram,
                    'Instagram',
                    '@${AppConstants.instagramHandle}',
                    _launchInstagram,
                    isMobile,
                  ),
                ],
                const SizedBox(height: 48),
                Text(
                  '© 2025, UKInternational. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isMobile ? 24 : 32,
              color: const Color(0xFFECD9B0),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final url = 'mailto:${AppConstants.businessEmail}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchWhatsApp() async {
    final url = AppConstants.whatsappUrl;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchInstagram() async {
    final url = 'https://instagram.com/${AppConstants.instagramHandle}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
