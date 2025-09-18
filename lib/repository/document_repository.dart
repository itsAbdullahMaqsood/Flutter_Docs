import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:http/http.dart';

class DocumentRepository {
  const DocumentRepository(this._client);
  final Client _client;

  createDocument(String token) async {
    try {
      final res = await _client.post(
        Uri.parse('${dotenv.env['API_HOST']}/doc/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
        }),
      );

      print("Document Response: ${res.statusCode}");

      if (res.statusCode == 200) {
        return DocumentModel.fromJson(jsonDecode(res.body));
      } else {
        print(res.body);
      }
    } catch (e) {
      print(e);
    }
  }

  getDocuments(String token) async {
    try {
      final res = await _client.get(
        Uri.parse('${dotenv.env['API_HOST']}/doc/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      print("Document Response: ${res.statusCode}");

      if (res.statusCode == 200) {
        List<DocumentModel> documents = [];
        for (final doc in jsonDecode(res.body)) {
          documents.add(DocumentModel.fromJson(doc));
        }
        return documents;
      } else {
        print(res.body);
      }
    } catch (e) {
      print(e);
    }
  }

  updateTitle(String token, String id, String title) async {
    final res = await _client.post(
      Uri.parse('${dotenv.env['API_HOST']}/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({"id": id, "title": title}),
    );

    print("Document Response: ${res.statusCode}");
  }

  getDocumentByID(String token, String id) async {
    final res = await _client.get(
      Uri.parse('${dotenv.env['API_HOST']}/doc/title/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );
    if (res.statusCode == 200) {
      return DocumentModel.fromJson(jsonDecode(res.body));
    } else {
      print("This Document does not exist, please create a new one.");
    }
  }
}
