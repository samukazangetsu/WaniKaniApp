import 'package:wanikani_app/domain/entities/assignments/assignemnt_data_entity.dart';

class AssignmentEntity {
  final int id;
  final String object;
  final String url;
  final DateTime dataUpdatedAt;
  final AssignmentDataEntity data;
  const AssignmentEntity({
    required this.id,
    required this.object,
    required this.url,
    required this.dataUpdatedAt,
    required this.data,
  });
}
