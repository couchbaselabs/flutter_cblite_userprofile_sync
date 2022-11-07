import 'package:cbl/cbl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cblite_userprofile_sync/CbLiteManager.dart';
import 'package:flutter_cblite_userprofile_sync/screens/UserProfile.dart';

import '../CurrentData.dart';

class UniversitySelect extends StatefulWidget {
  UniversitySelect({Key? key}) : super(key: key);

  static String id = 'university_select';

  @override
  _UniversitySelectState createState() => _UniversitySelectState();
}

class _UniversitySelectState extends State<UniversitySelect> {
  List<Map<String, String>> data = [];
  String? name;
  String? country;
  final title = 'Select University';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          buildUniversitySearch(),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text((data[index]['name'] ?? "") + " - " +
                      (data[index]['country'] ?? "")),
                  subtitle: Text(data[index]['web_pages'] ?? ""),
                  onTap: () {
                    CurrentData.sharedData.university = data[index]['name'];
                    Navigator.pushNamed(context, UserProfile.id);
                  },
                );
              })),
        ],
      ),
    );
  }

  Widget buildUniversitySearch() => Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "University Name",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(
          height: 1,
        ),
        Container(
          width: 350,
          height: 40,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ))),
          child: TextFormField(
            style: TextStyle(fontSize: 16, height: 1.4),
            onChanged: (value) {
              name = value;
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "University Country",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Container(
          width: 350,
          height: 40,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ))),
          child: TextFormField(
            style: TextStyle(fontSize: 16, height: 1.4),
            onChanged: (value) {
              country = value;
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextButton(
            onPressed: () async {
              data = await fetchUniversities(name ?? "", country) ?? data;
              setState(() {});
            },
            child: Text(
              'Search',
              style: TextStyle(
                  fontSize: 20, color: Colors.red, fontWeight: FontWeight.w700),
            )),
      ]));

  Future<List<Map<String, String>>?> fetchUniversities(
      String name, String? country) async {
    Database database = CbLiteManager.getSharedInstance().universityDatabase!;

    ExpressionInterface whereQueryExpression = Function_.lower(Expression.property("name"))
        .like(Expression.string("%" + name.toLowerCase() + "%"));

    if (country != null && country.isNotEmpty) {
      ExpressionInterface countryQueryExpression =
          Function_.lower(Expression.property("country"))
              .like(Expression.string("%" + country.toLowerCase() + "%"));

      whereQueryExpression = whereQueryExpression.and(countryQueryExpression);
    }

    Query query = QueryBuilder.createSync()
        .select(SelectResult.all())
        .from(DataSource.database(database))
        .where(whereQueryExpression);

    ResultSet? rows;

    try {
      rows = await query.execute();
    } on CouchbaseLiteException catch (e) {
      print(e);
      return null;
    }

    List<Map<String, String>> data = [];

    await rows.asStream().forEach((row) {
      // tag::university[]
      Map<String, String> properties = {};
      properties["name"] = row.dictionary("universities")!.string("name")!;
      properties["country"] =
          row.dictionary("universities")!.string("country")!;
      properties["web_pages"] =
          row.dictionary("universities")!.array("web_pages")!.join(" ");
      // end::university[]

      data.add(properties);
    });

    return data;
  }

}
