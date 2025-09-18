import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/providers/auth_provider.dart';
import 'package:google_docs/providers/document_provider.dart';
import 'package:google_docs/repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen(this.id, {super.key});
  final String id;

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController = TextEditingController(
    text: 'Untitled Document',
  );
  quill.QuillController? controller;
  SocketRepository socketRepo = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepo.joinRoom(widget.id);
    socketRepo.changeListener((data) {
      controller?.compose(
        Delta.fromJson(data['delta']),
        controller!.selection,
        quill.ChangeSource.remote,
      );
      setState(() {});
    });
    fetchDocumentData();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  updateTitle(WidgetRef ref, String value) {
    ref
        .read(documentProvider)
        .updateTitle(ref.read(userProvider)!.token!, widget.id, value);
  }

  fetchDocumentData() async {
    DocumentModel document = await ref
        .read(documentProvider)
        .getDocumentByID(ref.read(userProvider)!.token!, widget.id);

    if (document != null) {
      titleController = TextEditingController(text: document.title);
      controller = quill.QuillController(
        document: document.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(Delta.fromJson(document.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }
    controller!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
  'room': widget.id,
  'delta': event.change.toJson(), // <-- convert to JSON
};
socketRepo.typing(map);

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigator = GoRouter.of(context);

    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  navigator.replace('/');
                },
                child: Image.asset('assets/images/docs-logo.png', height: 40),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillSimpleToolbar(
              controller: controller!,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: controller!,
                      config: const quill.QuillEditorConfig(
                        padding: EdgeInsets.zero,
                        scrollable: true,
                        autoFocus: true,
                        expands: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
