import 'package:cbl/cbl.dart';

import 'couchbase_lite_manager.dart';

class University {
  University({
    required this.name,
    required this.country,
    required this.webPages,
  });

  factory University.fromJson(Map<String, Object?> map) {
    return University(
      name: map['name']! as String,
      country: map['country']! as String,
      webPages: (map['web_pages']! as List).cast<String>(),
    );
  }

  final String name;
  final String country;
  final List<String> webPages;

  static Future<List<University>> search({
    String? name,
    String? country,
  }) async {
    final database = CouchbaseLiteManager.instance.universitiesDatabase!;

    final whereExpressions = [
      if (name != null)
        Function_.lower(Expression.property('name'))
            .like(Expression.string('${name.toLowerCase()}%')),
      if (country != null)
        Function_.lower(Expression.property('country'))
            .like(Expression.string('${country.toLowerCase()}%')),
    ];

    if (whereExpressions.isEmpty) {
      return [];
    }

    final whereExpression = whereExpressions.reduce((a, b) => a.and(b));

    final query = const QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(database))
        .where(whereExpression);

    final queryExplanation = await query.explain();
    print('University search query explanation:\n$queryExplanation');

    final resultSet = await query.execute();
    return resultSet
        .asStream()
        .map((result) => result.dictionary(0)!.toPlainMap())
        .map(University.fromJson)
        .toList();
  }
}
