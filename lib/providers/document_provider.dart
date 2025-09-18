import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:http/http.dart';

final documentProvider = StateProvider<DocumentRepository>(
  (ref) => DocumentRepository(Client()),
);
