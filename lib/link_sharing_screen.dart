import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LinkSharingScreen extends StatelessWidget {
  const LinkSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      {'title': 'First Screen', 'path': 'https://heystyle.chottu.link/first'},
      {'title': 'Second Screen', 'path': 'https://heystyle.chottu.link/second'},
      {'title': 'Third Screen', 'path': 'https://heystyle.chottu.link/third'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Link Sharing Screen')),
      body: ListView.builder(
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return ListTile(
            title: Text('Share ${link['title']} Link'),
            onTap: () => _shareLink(context, link['path']!),
          );
        },
      ),
    );
  }

  void _shareLink(BuildContext context, String path) {
 Share.share('Check out this link: $path');
  }
}