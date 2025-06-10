import 'package:wanikani_app/domain/entities/pagination/pagination_entity.dart';

class CollectionEntity<T> {
  final String object;
  final String url;
  final PaginationEntity pages;
  final int totalCount;
  final DateTime dataUpdatedAt;
  final List<T> data;

  CollectionEntity({
    required this.object,
    required this.url,
    required this.pages,
    required this.totalCount,
    required this.dataUpdatedAt,
    required this.data,
  });
}
