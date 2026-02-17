// import 'dart:io';

// import 'package:chautari_kurakani/core/api/api_endpoints.dart';
// import 'package:chautari_kurakani/core/routes/app_routes.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   final AuthEntity userEntity;
//   const ProfileScreen({super.key, required this.userEntity});

//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   final ImagePicker _picker = ImagePicker();

//   File? _selectedProfileImage;
//   File? _selectedCoverImage;

//   Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile == null) return;

//       final imageFile = File(pickedFile.path);

//       setState(() {
//         if (isProfile) {
//           _selectedProfileImage = imageFile;
//         } else {
//           _selectedCoverImage = imageFile;
//         }
//       });

//       // 🔥 Upload to backend
//       if (isProfile) {
//         await ref
//             .read(authViewModelProvider.notifier)
//             .uploadProfileImage(imageFile);
//       } else {
//         await ref
//             .read(authViewModelProvider.notifier)
//             .uploadCoverImage(imageFile);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       SnackbarUtils.showError(context, "Failed to pick image");
//     }
//   }

//   void _showImageSourceDialog({required bool isProfile}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take Photo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera, isProfile: isProfile);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery, isProfile: isProfile);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _handleLogout() async {
//     await ref.read(authViewModelProvider.notifier).logout();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.unauthenticated) {
//         SnackbarUtils.showSuccess(context, "Logged out successfully");
//         AppRoutes.pushReplacement(context, const LoginScreen());
//       } else if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(context, next.errorMessage!);
//       }
//     });

//     if (authState.status == AuthStatus.loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: () => _showImageSourceDialog(isProfile: false),
//               child: Container(
//                 height: 140,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: const Color(0xFFE3E3E3),
//                   image: _selectedCoverImage != null
//                       ? DecorationImage(
//                           image: FileImage(_selectedCoverImage!),
//                           fit: BoxFit.cover,
//                         )
//                       : (widget.userEntity.coverPicture != null &&
//                             widget.userEntity.coverPicture!.isNotEmpty)
//                       ? DecorationImage(
//                           image: NetworkImage(
//                             ApiEndpoints.coverImageUrl(
//                               widget.userEntity.coverPicture!,
//                             ),
//                           ),
//                           fit: BoxFit.cover,
//                         )
//                       : null,
//                 ),
//                 child:
//                     _selectedCoverImage == null &&
//                         (widget.userEntity.coverPicture == null ||
//                             widget.userEntity.coverPicture!.isEmpty)
//                     ? const Icon(Icons.camera_alt, size: 40)
//                     : null,
//               ),
//             ),

//             const SizedBox(height: 40),

//             GestureDetector(
//               onTap: () => _showImageSourceDialog(isProfile: true),
//               child: Container(
//                 height: 140,
//                 width: 140,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: const Color(0xFFE3E3E3),
//                   image: _selectedProfileImage != null
//                       ? DecorationImage(
//                           image: FileImage(_selectedProfileImage!),
//                           fit: BoxFit.cover,
//                         )
//                       : (widget.userEntity.profilePicture != null &&
//                             widget.userEntity.profilePicture!.isNotEmpty)
//                       ? DecorationImage(
//                           image: NetworkImage(
//                             ApiEndpoints.profileImageUrl(
//                               widget.userEntity.profilePicture!,
//                             ),
//                           ),
//                           fit: BoxFit.cover,
//                         )
//                       : null,
//                 ),
//                 child:
//                     _selectedProfileImage == null &&
//                         (widget.userEntity.profilePicture == null ||
//                             widget.userEntity.profilePicture!.isEmpty)
//                     ? const Icon(Icons.person, size: 50)
//                     : null,
//               ),
//             ),

//             const SizedBox(height: 20),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.grey.shade100,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Email',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.userEntity.email,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             ElevatedButton(
//               onPressed: _handleLogout,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Logout',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/dashboard/data/models/post_model.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/friend_card_widget.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/edit_profile_widget.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/side_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final AuthEntity userEntity;
  const ProfileScreen({super.key, required this.userEntity});

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

  @override
  void initState() {
    super.initState();
    _fullName = '${widget.userEntity.fName} ${widget.userEntity.lName}';
    _bio = widget.userEntity.bio ?? 'No bio yet';
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
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
    // Add your refresh logic here
    // For example, fetch updated user data, posts, friends, etc.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
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

    // Sample user posts - replace with actual data from your backend
    List<PostModel> _userPosts = [
      PostModel(
        name: _fullName,
        profileUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        hoursAgo: '2 hours ago',
        caption: 'This is my first post on my profile! 🎉',
        imageUrl:
            'https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L25zODIzMC1pbWFnZS5qcGc.jpg',
        isPoll: false,
      ),
      PostModel(
        name: _fullName,
        profileUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        hoursAgo: '5 hours ago',
        caption: 'Just finished this amazing project!',
        imageUrl: null,
        isPoll: true,
      ),
    ];

    // Sample friends list - replace with actual data
    final List<Map<String, String>> _friends = [
      {
        'name': 'Friend 1',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '10 mutual friends',
      },
      {
        'name': 'Friend 2',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '5 mutual friends',
      },
      {
        'name': 'Friend 3',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '15 mutual friends',
      },
      {
        'name': 'Friend 4',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '3 mutual friends',
      },
      {
        'name': 'Friend 5',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '8 mutual friends',
      },
      {
        'name': 'Friend 6',
        'profileUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'mutualFriends': '12 mutual friends',
      },
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideNavigationDrawer(
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
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
                      onTap: () => _showImageSourceDialog(isProfile: false),
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
                        onTap: () => _showImageSourceDialog(isProfile: true),
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
                                    color: Colors.black.withOpacity(0.2),
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
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _showEditProfile,
                            // color: Colors.blue,
                            color: Color(0XFF76C05D),
                          ),
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
                      _buildStatColumn('Posts', '${_userPosts.length}'),
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
                      Tab(icon: Icon(Icons.people), text: 'Friends'),
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
                child: _userPosts.isEmpty
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
                        itemCount: _userPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: _userPosts[index]);
                        },
                      ),
              ),

              // Friends Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _friends.isEmpty
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
                          return FriendCard(friend: _friends[index]);
                        },
                      ),
              ),
            ],
          ),
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
