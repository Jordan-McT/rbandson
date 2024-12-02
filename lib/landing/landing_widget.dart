import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_model.dart';
export 'landing_model.dart';

class LandingWidget extends StatefulWidget {
  const LandingWidget({super.key});

  @override
  State<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget>
    with TickerProviderStateMixin {
  late LandingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LandingModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0.6, 1.0),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently signed-in user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect to a login page or show a message if no user is signed in
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: Text(
            'No user signed in. Please log in.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
      );
    }

    return StreamBuilder<UserRecord>(
      // Fetch the document based on the current user's UID
      stream: UserRecord.getDocument(UserRecord.collection.doc(user.uid)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final landingUserRecord = snapshot.data;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/RB_&_Son_Fleet.jpg',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.5), // Dim the background
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Logo at the top
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 150.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage('assets/images/RB&Son_Logo.jpg'),
                            ),
                          ),
                        ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation']!,
                        ),
                      ),
                      const Spacer(),
                      // Welcome Message at the bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome',
                              style: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    fontFamily: 'Work Sans',
                                    color: FlutterFlowTheme.of(context).secondary,
                                    fontSize: 40.0,
                                  ),
                            ),
                            Text(
                              landingUserRecord?.displayName ?? 'User',
                              style: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    fontFamily: 'Work Sans',
                                    color: FlutterFlowTheme.of(context).secondary,
                                    fontSize: 32.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
