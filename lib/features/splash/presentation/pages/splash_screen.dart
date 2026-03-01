import 'dart:async';

import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/call/presentation/view_model/call_view_model.dart';
import 'package:chautari_kurakani/features/chautari/domain/usecases/chautari_usecases.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:chautari_kurakani/features/message/presentation/view_model/message_view_model.dart';
import 'package:chautari_kurakani/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _loadingController = AnimationController(vsync: this);

    _logoController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();
    final currentUserId = (userSessionService.getCurrentUserId() ?? '').trim();

    final warmupFuture = (isLoggedIn && currentUserId.isNotEmpty)
        ? _warmupLoggedInSession(currentUserId)
        : Future<void>.value();

    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      warmupFuture.timeout(const Duration(seconds: 3), onTimeout: () {}),
    ]);

    if (!mounted) return;

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const DashboardScreen());
    } else {
      AppRoutes.push(context, const OnboardingOne());
    }
  }

  Future<void> _warmupLoggedInSession(String currentUserId) async {
    final authNotifier = ref.read(authViewModelProvider.notifier);
    final postNotifier = ref.read(postViewModelProvider.notifier);
    final messageNotifier = ref.read(messageViewModelProvider.notifier);
    final callNotifier = ref.read(callViewModelProvider.notifier);
    final notificationNotifier = ref.read(
      notificationViewModelProvider.notifier,
    );
    final getMyChautariUsecase = ref.read(getMyChautariUsecaseProvider);
    final getChautariCountUsecase = ref.read(
      getUserChautariCountUsecaseProvider,
    );

    messageNotifier.setCurrentUserId(currentUserId);
    callNotifier.setCurrentUserId(currentUserId);

    Future<void> safe(Future<void> future) async {
      try {
        await future.timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    await Future.wait([
      safe(authNotifier.getCurrentUser(userId: currentUserId)),
      safe(postNotifier.fetchPosts()),
      safe(messageNotifier.loadConversations()),
      safe(callNotifier.loadCallHistory()),
      safe(notificationNotifier.fetchNotifications()),
      safe(
        getMyChautariUsecase(
          const MyChautariParams(page: 1, size: 20),
        ).then((_) {}),
      ),
      safe(
        getChautariCountUsecase(
          UserChautariCountParams(currentUserId),
        ).then((_) {}),
      ),
    ]);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isTablet = width >= 700;

            final logoSize = isTablet ? width * 0.24 : width * 0.34;
            final titleSize = isTablet
                ? 44.0
                : (width * 0.105).clamp(28.0, 40.0);
            final subtitleSize = isTablet
                ? 24.0
                : (width * 0.055).clamp(14.0, 22.0);
            final contentTop = isTablet ? height * 0.17 : height * 0.19;
            final handSize = isTablet ? width * 0.34 : width * 0.42;

            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: contentTop),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 26,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/white_half_logo.png',
                              height: logoSize,
                              width: logoSize,
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 18 : 12),
                        Text(
                          "ChautariKuraKani",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                        Text(
                          "Chautarimah Sabai Kura",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isTablet ? 18 : 10),
                    child: SizedBox(
                      width: handSize,
                      height: handSize,
                      child: Lottie.asset(
                        'assets/lottie/loading_hand2.json',
                        controller: _loadingController,
                        onLoaded: (composition) {
                          _loadingController
                            ..duration = composition.duration
                            ..repeat();
                        },
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
