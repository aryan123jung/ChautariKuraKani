import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/chautari_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/feed_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/friend_feed_screen.dart';
import 'package:chautari_kurakani/features/notification/presentation/pages/notification_screen.dart';
import 'package:chautari_kurakani/features/notification/presentation/view_model/notification_view_model.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(15, isTablet ? 0 : 15, 15, 15),
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
                    height: isTablet ? 100 : 80,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ChautariKuraKani',
                    style: TextStyle(
                      fontFamily: 'OpenSans Bold',
                      fontSize: isTablet ? 45 : 30,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, isTablet ? 0 : 10, 0, 0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 5),
                child: Row(
                  children: [
                    const Expanded(
                      child: TabBar(
                        indicatorColor: Colors.black,
                        indicatorWeight: 2,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
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
                      iconSize: 33,
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
            SizedBox(height: isTablet ? 10 : 10),
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
