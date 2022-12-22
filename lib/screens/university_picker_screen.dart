import 'package:flutter/material.dart';

import '../common.dart';
import '../data/university.dart';
import '../data/user_data.dart';
import '../widgets/big_button.dart';

class UniversityPickerScreen extends StatefulWidget {
  const UniversityPickerScreen({Key? key}) : super(key: key);

  static String id = 'university_picker';

  @override
  State createState() => _UniversityPickerScreenState();
}

class _UniversityPickerScreenState extends State<UniversityPickerScreen> {
  var _name = '';
  var _country = '';
  var _universities = <University>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select University'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildUniversitySearch(),
          const Divider(),
          if (_universities.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No universities found.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _universities.length,
                itemBuilder: (context, index) {
                  final university = _universities[index];

                  return ListTile(
                    title: Text('${university.name} - ${university.country}'),
                    subtitle: Text(university.webPages.join(' ')),
                    onTap: () {
                      UserData.instance.university = university.name;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUniversitySearch() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: AppTheme.inputDecoration(label: 'Name'),
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: (value) => _country = value,
              decoration: AppTheme.inputDecoration(label: 'Country'),
            ),
            const SizedBox(height: 20),
            BigButton(
              label: 'Search',
              onPressed: _searchUniversities,
            ),
          ],
        ),
      ),
    );
  }

  void _searchUniversities() {
    runActionGuarded(context, () async {
      final universities = await University.search(
        name: _name.isEmpty ? null : _name,
        country: _country.isEmpty ? null : _country,
      );

      if (mounted) {
        setState(() {
          _universities = universities;
        });
      }
    });
  }
}
