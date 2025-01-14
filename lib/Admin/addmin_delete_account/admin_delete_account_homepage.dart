import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminDeleteAccountHomePage extends StatefulWidget {
  static const routeName = '/admin_delete_account_homepage';
  const AdminDeleteAccountHomePage({super.key});

  @override
  State<AdminDeleteAccountHomePage> createState() =>
      _AdminDeleteAccountHomePageState();
}

class _AdminDeleteAccountHomePageState
    extends State<AdminDeleteAccountHomePage> {
  late CollectionReference _clients;
  late CollectionReference _technicians;

  @override
  void initState() {
    super.initState();
    _clients = FirebaseFirestore.instance.collection('Clients');
    _technicians = FirebaseFirestore.instance.collection('Technicians');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make status bar transparent
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accounts List'),
          backgroundColor: Colors.orange,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Client Account List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildAccountList(_clients),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Technician Account List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildAccountList(_technicians),
          ),
        ]),
      ),
    );
  }

  Widget _buildAccountList(CollectionReference collection) {
    return StreamBuilder(
      stream: collection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (streamSnapshot.hasError) {
          return Center(
            child: Text('Error: ${streamSnapshot.error}'),
          );
        }
        if (streamSnapshot.hasData) {
          return ListView.builder(
            itemCount: streamSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
              return _buildAccountTile(documentSnapshot, collection);
            },
          );
        }
        return Center(
          child: Text('No accounts found.'),
        );
      },
    );
  }

  Widget _buildAccountTile(
      DocumentSnapshot documentSnapshot, CollectionReference collection) {
    String fullName = collection == _clients
        ? 'Client Full Name: ${documentSnapshot['clientFullName']}'
        : 'Technician Full Name: ${documentSnapshot['techFullName']}';

    return Card(
      color: Color.fromARGB(220, 250, 149, 34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office Building: ${documentSnapshot['OfficeBuilding']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Office Number: ${documentSnapshot['OfficeNumber']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            _deleteAccount(documentSnapshot.id, documentSnapshot.reference);
          },
          icon: Icon(Icons.delete),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(
      String documentId, DocumentReference reference) async {
    await reference.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account successfully deleted!',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
