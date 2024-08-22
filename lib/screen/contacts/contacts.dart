import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/contact_provider.dart';
import 'package:coaching_admin/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _loadMoreContacts();
        }
      });
  }

  Future<void> _loadMoreContacts() async {
    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);
    if (contactProvider.isInitialized && contactProvider.hasMoreContacts) {
      await contactProvider.fetchContacts(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        if (!contactProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (contactProvider.contacts.isEmpty) {
          return const Center(
            child: Text('No contacts available'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: contactProvider.contacts.length +
              (contactProvider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == contactProvider.contacts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              );
            }
            Student student = contactProvider.contacts[index];
            return StudentCard(student: student);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
