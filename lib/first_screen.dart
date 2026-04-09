import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/dynamic_link/cl_dynamic_link_behaviour.dart';
import 'package:chottu_link/dynamic_link/cl_dynamic_link_parameters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Screen')),
      body: Column(
        children: [
          const Center(child: Text('This is the first screen')),
          ElevatedButton(
            onPressed: () => context.push('/second'),
            child: const Text('Go to Second Screen'),
          ),
          ElevatedButton(
            onPressed: () => context.push('/third'),
            child: const Text('Go to Third Screen'),
          ),
          ElevatedButton(
            onPressed: () => chottuLinkCration('/second'),
            child: const Text('Create Second Screen Deep Link'),
          ),
          ElevatedButton(
            onPressed: () => chottuLinkCration('/third'),
            child: const Text('Create Third Screen Deep Link'),
          ),
        ],
      ),
    );
  }
}

void chottuLinkCration(String path) {
  final parameters = CLDynamicLinkParameters(
    link: Uri.parse('https://heystyle.chottu.link$path'),
    domain: 'heystyle.chottu.link',
    androidBehaviour: CLDynamicLinkBehaviour.app,
    iosBehaviour: CLDynamicLinkBehaviour.app,
    utmCampaign: 'exampleCampaign',
    utmMedium: 'exampleMedium',
    utmSource: 'exampleSource',
    utmContent: 'exampleContent',
    utmTerm: 'exampleTerm',
    linkName: 'linkname',
    selectedPath: path,
    socialTitle: 'Social Title',
    socialDescription: 'Description to show when shared',
  );

  ChottuLink.createDynamicLink(
    parameters: parameters,
    onSuccess: (link) {
      debugPrint('✅ Shared Link: $link');
    },
    onError: (error) {
      debugPrint('❌ Error creating link: ${error.description}');
    },
  );
}
