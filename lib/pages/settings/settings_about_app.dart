import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.aboutApp),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const FlutterLogo(size: 80),
            const SizedBox(height: 20),
            const Text(
              'Outvision XR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '...';
                return Text(
                  'v$version',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                );
              },
            ),
            const Spacer(),
            Text(
              context.t.about.copyright,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
