import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/product_list_screen.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final int index;
  /// Optional hero photo (e.g. mens / womens / kids / sports).
  final String? heroImageAsset;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.index,
    this.heroImageAsset,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFF1C1F26), Color(0xFF3A3F4D)],
    [Color(0xFF2B2622), Color(0xFF4A4238)],
    [Color(0xFF1E2832), Color(0xFF3D4F5C)],
    [Color(0xFF232828), Color(0xFF3D4545)],
  ];

  @override
  Widget build(BuildContext context) {
    final g = _gradients[index % _gradients.length];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductListScreen(category: name)),
        );
      },
      child: Container(
        width: 92,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (heroImageAsset != null)
                    Image.asset(
                      heroImageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _gradientFill(g),
                    )
                  else
                    _gradientFill(g),
                  if (heroImageAsset != null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                  if (heroImageAsset == null)
                    Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientFill(List<Color> g) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: g,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
