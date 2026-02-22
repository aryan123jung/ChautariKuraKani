import 'dart:async';

import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:chautari_kurakani/features/search/presentation/state/search_state.dart';
import 'package:chautari_kurakani/features/search/presentation/view_model/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(searchViewModelProvider.notifier).searchUsers(query: trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final users = searchState.users;
    final isLoading = searchState.status == SearchStatus.loading;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search users by name, username, or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchViewModelProvider.notifier).clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (!hasQuery) {
                    return const Center(child: Text('Type to search users'));
                  }

                  if (searchState.status == SearchStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          searchState.errorMessage ?? 'Failed to search users',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!isLoading && users.isEmpty) {
                    return Center(child: Text('No users found'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _UserTile(user: user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final SearchUserEntity user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final fullName = user.fullName;
    final profile = user.profileUrl;
    final imageUrl = _resolveProfile(profile);

    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? Text(
                  (fullName.isNotEmpty ? fullName[0] : 'U').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              : null,
        ),
        title: Text(
          fullName.isEmpty ? 'User' : fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('@${user.username}\n${user.email}'),
        isThreeLine: true,
      ),
    );
  }

  String? _resolveProfile(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}
