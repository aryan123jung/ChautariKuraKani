import 'package:chautari_kurakani/features/chautari/presentation/pages/chautari_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/feed_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/friend_feed_screen.dart';
import 'package:chautari_kurakani/features/notification/presentation/pages/notification_screen.dart';
import 'package:chautari_kurakani/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:chautari_kurakani/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _lastNotificationCount = 0;
  ProviderSubscription? _notificationSubscription;
  bool _suppressInitialNotificationPopup = true;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = ref.listenManual(
      notificationViewModelProvider,
      (previous, next) {
        if (_suppressInitialNotificationPopup) {
          _lastNotificationCount = next.notifications.length;
          return;
        }

        final prevCount =
            previous?.notifications.length ?? _lastNotificationCount;
        final nextCount = next.notifications.length;

        if (nextCount > prevCount && next.notifications.isNotEmpty && mounted) {
          final newest = next.notifications.first;
          _showTopSnack(newest.title.isEmpty ? newest.message : newest.title);
        }

        _lastNotificationCount = nextCount;
      },
    );

    Future.microtask(() async {
      await ref
          .read(notificationViewModelProvider.notifier)
          .fetchNotifications();
      await ref.read(notificationViewModelProvider.notifier).connectRealtime();
      if (!mounted) return;
      _lastNotificationCount = ref
          .read(notificationViewModelProvider)
          .notifications
          .length;
      _suppressInitialNotificationPopup = false;
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.close();
    _notificationSubscription = null;
    super.dispose();
  }

  void _showTopSnack(String text) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(text),
          leading: const Icon(Icons.notifications_active_outlined),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      messenger.hideCurrentMaterialBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final unreadCount = notificationState.unreadCount;
    final isTablet = context.isTablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const brandGreen = Color(0XFF76C05D);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.scale(12),
        isTablet ? 0 : context.scale(12),
        context.scale(12),
        context.scale(12),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/green_half_logo.png',
                    height: context.scale(isTablet ? 96 : 72),
                  ),
                  SizedBox(width: context.scale(8)),
                  Text(
                    'ChautariKuraKani',
                    style: TextStyle(
                      fontFamily: 'OpenSans Bold',
                      fontSize: context.fs(isTablet ? 40 : 28),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                0,
                isTablet ? 0 : context.scale(8),
                0,
                0,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scale(isTablet ? 48 : 4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        indicatorColor: brandGreen,
                        indicatorWeight: 2,
                        labelColor: brandGreen,
                        unselectedLabelColor: isDark
                            ? Colors.white60
                            : Colors.grey[700],
                        labelStyle: TextStyle(
                          fontSize: context.fs(15.5),
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Feed'),
                          Tab(text: 'Friends'),
                          Tab(text: 'Chautari'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                      iconSize: context.scale(30),
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none),
                          if (unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.fs(10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.scale(8)),
            const Expanded(
              child: TabBarView(
                children: [FeedScreen(), FriendsFeedScreen(), ChautariScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
