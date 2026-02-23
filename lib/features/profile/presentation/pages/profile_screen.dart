import 'dart:io';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:chautari_kurakani/features/addPost/presentation/pages/add_post_screen.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/presentation/state/friend_request_state.dart';
import 'package:chautari_kurakani/features/friend_request/presentation/view_model/friend_request_view_model.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/friend_card_widget.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/edit_profile_widget.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/side_nav_widget.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:chautari_kurakani/features/search/domain/usecases/search_users_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final AuthEntity userEntity;
  final int refreshTick;
  final bool isReadOnly;
  const ProfileScreen({
    super.key,
    required this.userEntity,
    this.refreshTick = 0,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  File? _selectedProfileImage;
  File? _selectedCoverImage;

  late String _fullName;
  late String _bio;

  bool _isAppBarVisible = false;
  double _lastScrollOffset = 0;
  bool _isScrollingDown = false;
  List<PostEntity> _userPosts = [];
  bool _isLoadingPosts = true;
  List<SearchUserEntity> _friends = [];
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _fullName = '${widget.userEntity.fName} ${widget.userEntity.lName}';
    _bio = widget.userEntity.bio ?? 'No bio yet';
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadUserPosts();
    _loadFriends();
    _loadFriendStatusForReadOnly();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUserId = oldWidget.userEntity.authId ?? '';
    final newUserId = widget.userEntity.authId ?? '';
    final userChanged =
        oldWidget.userEntity.email != widget.userEntity.email ||
        oldWidget.userEntity.username != widget.userEntity.username;

    if (oldUserId != newUserId ||
        userChanged ||
        oldWidget.refreshTick != widget.refreshTick) {
      _fullName = '${widget.userEntity.fName} ${widget.userEntity.lName}';
      _bio = widget.userEntity.bio ?? 'No bio yet';
      _loadUserPosts();
      _loadFriends();
      _loadFriendStatusForReadOnly();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;

    // Determine scroll direction
    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      if (!_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
          _isAppBarVisible = true;
        });
      }
    } else if (currentOffset < _lastScrollOffset) {
      if (_isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
        });
      }

      // Show app bar when scrolling up, but not at the very top
      if (currentOffset > 10 && !_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = true;
        });
      } else if (currentOffset <= 10 && _isAppBarVisible) {
        setState(() {
          _isAppBarVisible = false;
        });
      }
    }

    _lastScrollOffset = currentOffset;
  }

  Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      setState(() {
        if (isProfile) {
          _selectedProfileImage = imageFile;
        } else {
          _selectedCoverImage = imageFile;
        }
      });

      if (isProfile) {
        await ref
            .read(authViewModelProvider.notifier)
            .uploadProfileImage(imageFile);
      } else {
        await ref
            .read(authViewModelProvider.notifier)
            .uploadCoverImage(imageFile);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, "Failed to pick image");
    }
  }

  void _showImageSourceDialog({required bool isProfile}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isProfile ? 'Change Profile Photo' : 'Change Cover Photo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfile: isProfile);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: Colors.green.shade700),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfile: isProfile);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await ref.read(authViewModelProvider.notifier).logout();
  }

  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (context) => EditProfileWidget(
        fullName: _fullName,
        bio: _bio,
        profilePicture: widget.userEntity.profilePicture,
        onSave: (newName, newBio, newImage) {
          setState(() {
            _fullName = newName;
            _bio = newBio;
            if (newImage != null) {
              _selectedProfileImage = newImage;
              // garnabaki:Upload new profile image
            }
          });

          // garnabaki: Update user data in backend

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    //garnabaki: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings screen coming soon')),
    );
  }

  void _showHelp() {
    // garnabaki: Navigate to help screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Help screen coming soon')));
  }

  void _showPrivacyPolicy() {
    // garnabaki: Navigate to privacy policy screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Privacy policy coming soon')));
  }

  String getFullName() {
    return _fullName;
  }

  String getProfilePictureUrl() {
    if (_selectedProfileImage != null) {
      return ''; // Will be handled by FileImage
    }
    return widget.userEntity.profilePicture ?? '';
  }

  Future<void> _onRefresh() async {
    await _loadUserPosts();
    await _loadFriends();
    await _loadFriendStatusForReadOnly();
  }

  bool _isOwnReadOnlyProfile(AuthState authState) {
    if (!widget.isReadOnly) return false;
    final currentId = _normalizeId(authState.authEntity?.authId ?? '');
    final targetId = _normalizeId(widget.userEntity.authId ?? '');
    return currentId.isNotEmpty && targetId.isNotEmpty && currentId == targetId;
  }

  Future<void> _loadFriendStatusForReadOnly() async {
    if (!widget.isReadOnly) return;
    final targetId = widget.userEntity.authId;
    if (targetId == null || targetId.trim().isEmpty) return;
    final normalizedTarget = _normalizeId(targetId);
    final currentState = ref.read(friendRequestViewModelProvider);
    final alreadyLoadedForTarget =
        currentState.statusUserId == normalizedTarget &&
        currentState.friendStatus != null &&
        currentState.status == FriendRequestStatusUi.loaded;
    if (alreadyLoadedForTarget) return;
    await ref
        .read(friendRequestViewModelProvider.notifier)
        .loadStatus(targetId);
  }

  Future<void> _handleFriendPrimaryAction({
    required String? currentStatus,
    required String? currentRequestId,
  }) async {
    final targetId = widget.userEntity.authId;
    if (targetId == null || targetId.trim().isEmpty) return;

    final notifier = ref.read(friendRequestViewModelProvider.notifier);
    final normalizedTarget = _normalizeId(targetId);

    // Revalidate the latest status from backend before taking action.
    await notifier.loadStatus(targetId);
    final latestScoped = ref.read(friendRequestViewModelProvider);
    final scopedStatus = latestScoped.statusUserId == normalizedTarget
        ? latestScoped.friendStatus
        : null;

    final status = scopedStatus?.status ?? currentStatus ?? 'NONE';
    final requestId = scopedStatus?.requestId ?? currentRequestId;

    bool success = false;

    if (status == 'NONE') {
      success = await notifier.sendRequest(targetId);
    } else if (status == 'PENDING_OUTGOING') {
      success = await notifier.cancelRequest(targetId);
    } else if (status == 'PENDING_INCOMING') {
      if (requestId == null || requestId.isEmpty) return;
      success = await notifier.acceptRequest(requestId);
    } else if (status == 'FRIEND') {
      success = await notifier.unfriend(targetId);
    } else if (status == 'SELF') {
      return;
    }

    if (!mounted) return;

    final latest = ref.read(friendRequestViewModelProvider);
    if (!success && latest.errorMessage != null) {
      final err = latest.errorMessage!.toLowerCase();
      if (err.contains('friendship not found')) {
        await notifier.loadStatus(targetId);
        return;
      }
      SnackbarUtils.showError(context, latest.errorMessage!);
      return;
    }

    if (status == 'PENDING_INCOMING' && requestId != null) {
      await notifier.loadIncoming();
    }

    await notifier.loadStatus(targetId);
  }

  Future<void> _handleFriendRejectAction({required String? requestId}) async {
    final targetId = widget.userEntity.authId;
    if (requestId == null || requestId.isEmpty || targetId == null) return;

    final success = await ref
        .read(friendRequestViewModelProvider.notifier)
        .rejectRequest(requestId);

    if (!mounted) return;
    if (!success) {
      final latest = ref.read(friendRequestViewModelProvider);
      if (latest.errorMessage != null) {
        SnackbarUtils.showError(context, latest.errorMessage!);
      }
      return;
    }

    await ref
        .read(friendRequestViewModelProvider.notifier)
        .loadStatus(targetId);
  }

  Future<void> _loadUserPosts() async {
    final candidateUserIds = widget.isReadOnly
        ? _readOnlyTargetIdCandidates()
        : await _waitForUserIdCandidates();
    final normalizedCurrentName = _normalizeName(_fullName);

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      await ref
          .read(postViewModelProvider.notifier)
          .fetchPosts()
          .timeout(const Duration(seconds: 2), onTimeout: () {});
      final allPosts = ref.read(postViewModelProvider).posts;
      final posts = allPosts
          .where(
            (post) =>
                candidateUserIds.contains(_normalizeId(post.authorId)) ||
                (normalizedCurrentName.isNotEmpty &&
                    _normalizeName(post.name) == normalizedCurrentName),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _userPosts = posts;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _loadFriends() async {
    if (widget.isReadOnly) {
      if (!mounted) return;
      setState(() {
        _friends = [];
        _isLoadingFriends = false;
      });
      return;
    }

    setState(() {
      _isLoadingFriends = true;
    });

    try {
      final currentId = _normalizeId(
        widget.userEntity.authId ??
            ref.read(userSessionServiceProvider).getCurrentUserId() ??
            '',
      );
      if (currentId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _friends = [];
          _isLoadingFriends = false;
        });
        return;
      }

      final usersResult = await ref.read(searchUsersUsecaseProvider)(
        const SearchUsersParams(query: '', page: 1, size: 100),
      );

      final users = usersResult.fold(
        (_) => <SearchUserEntity>[],
        (data) => data,
      );
      final candidates = users
          .where((user) => _normalizeId(user.id) != currentId)
          .toList();

      final friendRepo = ref.read(friendRequestRepositoryProvider);
      final checked = await Future.wait(
        candidates.map((user) async {
          final statusResult = await friendRepo.getStatus(user.id);
          return statusResult.fold(
            (_) => null,
            (status) => status.status == 'FRIEND' ? user : null,
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _friends = checked.whereType<SearchUserEntity>().toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _friends = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFriends = false;
        });
      }
    }
  }

  Future<void> _openFriendProfile(SearchUserEntity user) async {
    if (!mounted) return;
    var loaderOpen = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    loaderOpen = true;

    try {
      AuthEntity freshUser = AuthEntity(
        authId: user.id,
        fName: user.firstName,
        lName: user.lastName,
        email: user.email,
        username: user.username,
        profilePicture: user.profileUrl,
        coverPicture: user.coverUrl,
      );

      final profileResult = await ref.read(getCurrentUserUsecaseProvider)(
        GetCurrentUsecaseParams(userId: user.id),
      );

      profileResult.fold((_) {}, (entity) {
        freshUser = entity;
      });

      // Preload friend status before opening profile so action button is ready.
      await ref
          .read(friendRequestViewModelProvider.notifier)
          .loadStatus(user.id);

      await ref.read(postViewModelProvider.notifier).fetchPosts();
      if (!mounted) return;

      if (loaderOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderOpen = false;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProfileScreen(isReadOnly: true, userEntity: freshUser),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      if (loaderOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderOpen = false;
      }
      SnackbarUtils.showError(context, 'Failed to load friend profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final postState = ref.watch(postViewModelProvider);
    final friendState = ref.watch(friendRequestViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwnReadOnlyProfile = _isOwnReadOnlyProfile(authState);
    final targetProfileId = _normalizeId(widget.userEntity.authId ?? '');
    final scopedFriendStatus =
        widget.isReadOnly &&
            targetProfileId.isNotEmpty &&
            friendState.statusUserId == targetProfileId
        ? friendState.friendStatus
        : null;
    final readOnlyDerivedPosts = widget.isReadOnly
        ? _filterPostsForProfile(postState.posts)
        : <PostEntity>[];
    final displayPosts = widget.isReadOnly ? readOnlyDerivedPosts : _userPosts;
    final isLoadingPostsView = _isLoadingPosts;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (widget.isReadOnly) return;
      final previousId = previous?.authEntity?.authId;
      final nextId = next.authEntity?.authId;
      if (nextId != null && nextId.isNotEmpty && previousId != nextId) {
        _loadUserPosts();
      }

      if (next.status == AuthStatus.unauthenticated) {
        SnackbarUtils.showSuccess(context, "Logged out successfully");
        AppRoutes.pushReplacement(context, const LoginScreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    if (authState.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.isReadOnly
          ? null
          : SideNavigationDrawer(
              fullName: _fullName,
              email: widget.userEntity.email,
              profilePicture: getProfilePictureUrl(),
              onLogout: _handleLogout,
              onEditProfile: _showEditProfile,
              onSettings: _showSettings,
              onHelp: _showHelp,
              onPrivacyPolicy: _showPrivacyPolicy,
            ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Top App Bar with ChautariKuraKani text
              SliverAppBar(
                expandedHeight: _isAppBarVisible ? kToolbarHeight : 0,
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                leading: widget.isReadOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                title: _isAppBarVisible
                    ? const Text(
                        'ChautariKuraKani',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
                centerTitle: false,
                elevation: _isAppBarVisible ? 4 : 0,
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Cover Image
                    GestureDetector(
                      onTap: widget.isReadOnly
                          ? null
                          : () => _showImageSourceDialog(isProfile: false),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[300],
                          image: _selectedCoverImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedCoverImage!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.userEntity.coverPicture != null &&
                                    widget.userEntity.coverPicture!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(
                                    ApiEndpoints.coverImageUrl(
                                      widget.userEntity.coverPicture!,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            _selectedCoverImage == null &&
                                (widget.userEntity.coverPicture == null ||
                                    widget.userEntity.coverPicture!.isEmpty)
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Profile Image
                    Positioned(
                      left: 20,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: widget.isReadOnly
                            ? null
                            : () => _showImageSourceDialog(isProfile: true),
                        child: Stack(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[400],
                                backgroundImage: _selectedProfileImage != null
                                    ? FileImage(_selectedProfileImage!)
                                    : (widget.userEntity.profilePicture !=
                                              null &&
                                          widget
                                              .userEntity
                                              .profilePicture!
                                              .isNotEmpty)
                                    ? NetworkImage(
                                            ApiEndpoints.profileImageUrl(
                                              widget.userEntity.profilePicture!,
                                            ),
                                          )
                                          as ImageProvider
                                    : null,
                                child:
                                    _selectedProfileImage == null &&
                                        (widget.userEntity.profilePicture ==
                                                null ||
                                            widget
                                                .userEntity
                                                .profilePicture!
                                                .isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            if (!widget.isReadOnly)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User Info
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              getFullName(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!widget.isReadOnly) ...[
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AddPostScreen(popOnSuccess: true),
                                  ),
                                );
                                if (result == true) {
                                  await _loadUserPosts();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFF76C05D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Add Post"),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _showEditProfile,
                              color: const Color(0XFF76C05D),
                            ),
                          ] else if (!isOwnReadOnlyProfile) ...[
                            _buildFriendActionButtons(
                              friendState: friendState,
                              friendStatus: scopedFriendStatus,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bio,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.userEntity.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
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

              // Stats
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Posts', '${displayPosts.length}'),
                      _buildStatColumn('Friends', '${_friends.length}'),
                      _buildStatColumn('Following', '345'),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: isDark
                        ? Colors.grey
                        : Colors.grey[600],
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                      Tab(icon: Icon(Icons.people), text: 'Connection'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Posts Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: isLoadingPostsView
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : displayPosts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.post_add,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: displayPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: displayPosts[index],
                            currentUserId:
                                authState.authEntity?.authId ??
                                widget.userEntity.authId,
                            currentUserProfileUrl:
                                widget.userEntity.profilePicture,
                            currentUserName: _fullName,
                            postAuthorProfileUrl:
                                widget.userEntity.profilePicture,
                            onPostChanged: _loadUserPosts,
                          );
                        },
                      ),
              ),

              // Friends Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: widget.isReadOnly
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 36),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: _buildReadOnlyConnectionPanel(
                              scopedFriendStatus?.status,
                              isDark,
                            ),
                          ),
                        ],
                      )
                    : _isLoadingFriends
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : _friends.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No friends yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return FriendCard(
                            friend: friend,
                            onView: () => _openFriendProfile(friend),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyConnectionPanel(String? status, bool isDark) {
    final normalized = status ?? 'NONE';
    final Color accent;
    final IconData icon;
    final String title;
    final String subtitle;

    switch (normalized) {
      case 'FRIEND':
        accent = const Color(0XFF76C05D);
        icon = Icons.handshake_rounded;
        title = 'You are friends';
        subtitle = 'You can see each other as connections on ChautariKuraKani.';
        break;
      case 'PENDING_OUTGOING':
        accent = Colors.orange.shade700;
        icon = Icons.schedule_rounded;
        title = 'Request pending';
        subtitle = 'You sent a friend request. Waiting for acceptance.';
        break;
      case 'PENDING_INCOMING':
        accent = Colors.blue.shade700;
        icon = Icons.mark_email_unread_rounded;
        title = 'Incoming request';
        subtitle = 'This user sent you a friend request.';
        break;
      default:
        accent = Colors.grey.shade700;
        icon = Icons.person_search_rounded;
        title = 'Not connected';
        subtitle = 'Send a friend request to connect with this user.';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFFF8FBF6), const Color(0xFFEAF5E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    normalized,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                height: 1.35,
                fontSize: 14.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Set<String> _currentUserIdCandidates() {
    final authId = ref.read(authViewModelProvider).authEntity?.authId;
    final widgetId = widget.userEntity.authId;
    final sessionId = ref.read(userSessionServiceProvider).getCurrentUserId();

    return {
      if (authId != null && authId.trim().isNotEmpty) _normalizeId(authId),
      if (widgetId != null && widgetId.trim().isNotEmpty)
        _normalizeId(widgetId),
      if (sessionId != null && sessionId.trim().isNotEmpty)
        _normalizeId(sessionId),
    };
  }

  Set<String> _readOnlyTargetIdCandidates() {
    final id = widget.userEntity.authId;
    if (id == null || id.trim().isEmpty) return {};
    return {_normalizeId(id)};
  }

  Future<Set<String>> _waitForUserIdCandidates() async {
    var ids = _currentUserIdCandidates();
    var retries = 0;

    while (ids.isEmpty && retries < 8) {
      await Future.delayed(const Duration(milliseconds: 150));
      ids = _currentUserIdCandidates();
      retries++;
    }

    return ids;
  }

  String _normalizeId(String id) => id.trim().toLowerCase();

  String _normalizeName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  List<PostEntity> _filterPostsForProfile(List<PostEntity> allPosts) {
    final candidateUserIds = widget.isReadOnly
        ? _readOnlyTargetIdCandidates()
        : _currentUserIdCandidates();
    final normalizedCurrentName = _normalizeName(_fullName);

    return allPosts
        .where(
          (post) =>
              candidateUserIds.contains(_normalizeId(post.authorId)) ||
              (normalizedCurrentName.isNotEmpty &&
                  _normalizeName(post.name) == normalizedCurrentName),
        )
        .toList();
  }

  Widget _buildFriendActionButtons({
    required FriendRequestState friendState,
    required FriendStatusEntity? friendStatus,
  }) {
    final status = friendStatus?.status;
    final requestId = friendStatus?.requestId;
    final isBusy = friendState.status == FriendRequestStatusUi.submitting;

    if (status == null &&
        (friendState.status == FriendRequestStatusUi.loading ||
            friendState.status == FriendRequestStatusUi.initial)) {
      return const SizedBox(
        height: 36,
        width: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final normalizedStatus = status ?? 'NONE';

    String label;
    IconData icon;

    switch (normalizedStatus) {
      case 'PENDING_OUTGOING':
        label = 'Cancel Request';
        icon = Icons.person_remove_alt_1_outlined;
        break;
      case 'PENDING_INCOMING':
        label = 'Accept Request';
        icon = Icons.person_add_alt_1;
        break;
      case 'FRIEND':
        label = 'Remove Friend';
        icon = Icons.person_off_outlined;
        break;
      default:
        label = 'Add Friend';
        icon = Icons.person_add_alt;
    }

    final primary = ElevatedButton.icon(
      onPressed: isBusy
          ? null
          : () => _handleFriendPrimaryAction(
              currentStatus: status,
              currentRequestId: requestId,
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0XFF76C05D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: isBusy
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 16),
      label: Text(label),
    );

    if (normalizedStatus != 'PENDING_INCOMING') {
      return primary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        primary,
        const SizedBox(width: 6),
        OutlinedButton(
          onPressed: isBusy
              ? null
              : () => _handleFriendRejectAction(requestId: requestId),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

// Helper class for sliver app bar delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
