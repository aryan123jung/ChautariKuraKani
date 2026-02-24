import 'dart:io';

import 'package:chautari_kurakani/core/utils/top_popup.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/chautari/presentation/pages/chautari_detail_screen.dart';
import 'package:chautari_kurakani/features/chautari/presentation/state/chautari_state.dart';
import 'package:chautari_kurakani/features/chautari/presentation/view_model/chautari_view_model.dart';
import 'package:chautari_kurakani/features/chautari/presentation/widgets/chautari_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChautariScreen extends ConsumerStatefulWidget {
  const ChautariScreen({super.key});

  @override
  ConsumerState<ChautariScreen> createState() => _ChautariScreenState();
}

class _ChautariScreenState extends ConsumerState<ChautariScreen> {
  double _fabBottomOffset(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const navHeight = 65.0;
    const navBottomMargin = 20.0;
    const gapAboveNav = -30.0;
    return safeBottom + navHeight + navBottomMargin + gapAboveNav;
  }

  Future<bool> _confirmLeave(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Chautari'),
        content: Text('Do you want to leave "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeChautariViewModelProvider.notifier).loadMy();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(homeChautariViewModelProvider.notifier).loadMy();
  }

  Future<void> _showCreateChautariSheet() async {
    final nameController = TextEditingController(text: 'c/');
    final descController = TextEditingController();
    File? pickedImage;
    final picker = ImagePicker();

    final shouldCreate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Chautari',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name (must start with c/)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked == null) return;
                      setModalState(() => pickedImage = File(picked.path));
                    },
                    icon: const Icon(Icons.photo_outlined),
                    label: Text(
                      pickedImage == null
                          ? 'Add profile image (optional)'
                          : 'Image selected',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (shouldCreate != true) return;

    final name = nameController.text.trim();
    if (!name.toLowerCase().startsWith('c/')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chautari name must start with c/')),
      );
      return;
    }

    final ok = await ref
        .read(homeChautariViewModelProvider.notifier)
        .create(
          name: name,
          description: descController.text.trim(),
          profileImage: pickedImage,
        );

    if (!mounted) return;
    if (!ok) {
      final err = ref.read(homeChautariViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Failed to create Chautari')),
      );
      return;
    }
    await ref.read(homeChautariViewModelProvider.notifier).loadMy();

    if (!mounted) return;
    showTopPopup(context, 'Chautari created');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeChautariViewModelProvider);
    final currentUserId = ref.watch(authViewModelProvider).authEntity?.authId;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _fabBottomOffset(context)),
        child: FloatingActionButton(
          heroTag: 'chautari_create_fab',
          onPressed: _showCreateChautariSheet,
          backgroundColor: const Color(0XFF76C05D),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          children: [
            if (state.status == ChautariUiStatus.loading &&
                state.communities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.communities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(
                  child: Text(
                    'No Chautari yet.\nUse + to create a new Chautari.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (state.status == ChautariUiStatus.error)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    state.errorMessage ?? 'Failed to load Chautari',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              ...state.communities.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ChautariTileWidget(
                    item: item,
                    currentUserId: currentUserId,
                    onTap: () async {
                      final deleted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChautariDetailScreen(community: item),
                        ),
                      );

                      await ref
                          .read(homeChautariViewModelProvider.notifier)
                          .loadMy();
                      if (!mounted) return;

                      if (deleted == true) {
                        showTopPopup(this.context, 'Chautari deleted');
                      }
                    },
                    onJoinLeave: () async {
                      final joined = item.isJoinedBy(currentUserId);
                      if (joined) {
                        final shouldLeave = await _confirmLeave(item.name);
                        if (!shouldLeave) return;
                      }
                      final ok = joined
                          ? await ref
                                .read(homeChautariViewModelProvider.notifier)
                                .leave(item.id)
                          : await ref
                                .read(homeChautariViewModelProvider.notifier)
                                .join(item.id);
                      if (!ok) return;
                      await ref
                          .read(homeChautariViewModelProvider.notifier)
                          .loadMy();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
