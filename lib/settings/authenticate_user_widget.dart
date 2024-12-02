import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class AuthenticateUserWidget extends StatefulWidget {
  const AuthenticateUserWidget({super.key});

  @override
  _AuthenticateUserWidgetState createState() => _AuthenticateUserWidgetState();
}

class _AuthenticateUserWidgetState extends State<AuthenticateUserWidget> {
  bool _isLoading = true;
  List<DocumentSnapshot> _unauthorizedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUnauthorizedUsers();
  }

  Future<void> _fetchUnauthorizedUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .where('authorized', isEqualTo: false)
          .get();
      
      setState(() {
        _unauthorizedUsers = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  Future<void> _authorizeUser(DocumentSnapshot userDoc) async {
    try {
      await FirebaseFirestore.instance
          .collection('USER')
          .doc(userDoc.id)
          .update({'authorized': true});

      // Remove the user from the displayed list
      setState(() {
        _unauthorizedUsers.remove(userDoc);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User authorized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error authorizing user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Authenticate Users',
          style: FlutterFlowTheme.of(context).titleLarge,
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unauthorizedUsers.isEmpty
              ? Center(
                  child: Text(
                    'No unauthenticated users found.',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _unauthorizedUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = _unauthorizedUsers[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    
                    return ListTile(
                      title: Text(
                        userData['display_name'] ?? 'Unknown User',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      subtitle: Text(
                        'Email: ${userData['email'] ?? 'No Email'}',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      trailing: FFButtonWidget(
                        onPressed: () => _authorizeUser(userDoc),
                        text: 'Authorize',
                        options: FFButtonOptions(
                          width: 100,
                          height: 40,
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.white,
                              ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
