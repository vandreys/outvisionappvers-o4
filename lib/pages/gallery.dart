import 'package:flutter/material.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHIHARU SHIOTA – 塩田千春", 
        style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ))
              ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/shiota1.webp",
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "CHIHARU SHIOTA – 塩田千春",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Shiota’s inspiration often emerges from a personal experience or emotion which she expands into universal human concerns such as life, death and relationships. She has redefined the concept of memory and consciousness by collecting ordinary objects such as shoes, keys, beds, chairs and dresses, and engulfing them in immense thread structures. She explores this sensation of a "presence in the absence" with her installations, but also presents intangible emotions in her sculptures, drawings, performance videos, photographs and canvases.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            const Text(
              "Explore their work",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _carouselButton(
                    context: context,
                    imagePath: "assets/images/shiota4.webp",
                    label: "'searching for the destination'",
                    subtitle: "See it in AR",
                  ),
                  _carouselButton(
                    context: context,
                    imagePath: "assets/images/shiota5.webp",
                    label: "'in the hand'",
                    subtitle: "See it in AR",
                  ),
                  _carouselButton(
                    context: context,
                    imagePath: "assets/images/shiota6.webp",
                    label: "'relationality'",
                    subtitle: "See it in AR",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "More Images",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/shiota2.webp",
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/shiota3.webp",
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _carouselButton({
    required BuildContext context,
    required String imagePath,
    required String label,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}