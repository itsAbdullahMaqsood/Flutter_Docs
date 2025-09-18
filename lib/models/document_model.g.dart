// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['createdAt'] as String),
      ),
      json['uid'] as String,
      json['_id'] as String,
      json['title'] as String,
      json['content'] as List<dynamic>,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'uid': instance.uid,
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
    };
