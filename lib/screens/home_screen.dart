import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/providers/auth_provider.dart';
import 'package:google_docs/providers/document_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

void signOut(ref) async {
  final userService = ref.watch(userServiceProvider);
  GoogleSignIn signInService = ref.read(googleSignInProvider);
  await signInService.signOut();
  userService.signOutUser();
  ref.read(userProvider.notifier).state = null;
}

void createDocument(BuildContext context, WidgetRef ref) async {
  String token = ref.read(userProvider)!.token!;
  final navigator = GoRouter.of(context);
  final snackbar = ScaffoldMessenger.of(context);

  final docProvider = ref.read(documentProvider);
  final newDoc = await docProvider.createDocument(token);

  if (newDoc != null) {
    navigator.push('/document/${newDoc.id}');
  } else {
    snackbar.showSnackBar(
      SnackBar(content: Text("Document is not made correctly!")),
    );
  }
}

void getDocument(BuildContext context, WidgetRef ref) async {}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final navigator = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              signOut(ref);
            },
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: ref
              .watch(documentProvider)
              .getDocuments(ref.read(userProvider)!.token!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              final data = (snapshot.data as List<DocumentModel>?) ?? [];
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final doc = data[index];

                  return SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: InkWell(
                      onTap: () => navigator.push('/document/${doc.id}'),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            doc.title,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Text("No Documents Found");
          },
        ),
      ),
    );
  }
}
