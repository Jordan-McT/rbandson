import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'settings_model.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? userRole;
  String? userName;
  String? userEmail;
  bool _isDarkMode = FlutterFlowTheme.themeMode == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('USER').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get('display_name') ?? 'Unknown User';
          userEmail = userDoc.get('email') ?? 'No email available';
          userRole = userDoc.get('role') ?? 'User';
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).alternate,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_ios,
              color: FlutterFlowTheme.of(context).primary,
              size: 24.0,
            ),
            onPressed: () async {
              context.pushNamed('Landing');
            },
          ),
          title: Text(
            'Settings',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Work Sans',
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/RB_&_Son_Fleet.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // User Information Section
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12.0),
                            Text(
                              '${userName ?? 'Loading...'} (${userRole ?? 'Loading...'})',
                              style: FlutterFlowTheme.of(context).headlineMedium.override(
                                    fontFamily: 'Work Sans',
                                    color: FlutterFlowTheme.of(context).white,
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              '${userEmail ?? 'Loading...'}',
                              style: FlutterFlowTheme.of(context).headlineMedium.override(
                                    fontFamily: 'Work Sans',
                                    color: FlutterFlowTheme.of(context).white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 20.0, thickness: 1.0),

                      // Dark Mode Toggle
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          title: const Text(
                            'Dark Mode',
                            style: TextStyle(
                              color: Colors.white, // Set the text color to white
                            ),
                          ),
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                                final newThemeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
                                setDarkModeSetting(context, newThemeMode);
                              });
                            },
                          ),
                        ),
                      ),


                      // "Authenticate User" Button (Visible for Admins Only)
                      if (userRole == 'Admin')
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(
                                'AuthenticateUser',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType: PageTransitionType.rightToLeft,
                                  ),
                                },
                              );
                            },
                            text: 'Authenticate User',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 40.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Work Sans',
                                    color: FlutterFlowTheme.of(context).alternate,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    await signOut();
                    context.goNamed('Login');
                  },
                  text: 'Sign Out',
                  options: FFButtonOptions(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    color: Colors.red,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Work Sans',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
