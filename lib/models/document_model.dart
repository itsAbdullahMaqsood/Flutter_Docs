import 'package:json_annotation/json_annotation.dart';
part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel {
  DocumentModel(this.createdAt, this.uid, this.id, this.title, this.content);
  final DateTime createdAt;
  final String uid;
  final String id;
  final String title;
  final List<dynamic> content;
  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}
