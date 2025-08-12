/*

FOLLOW LIST PAGE

This page displays a tab bar for ( a given uid ):

- a list of all followers
- a list of all following

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_user_tile.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({
    super.key,
    required this.uid,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  @override
  void initState() {
    super.initState();

    // load follower list
    loadFollowerList();

    // load following list
    loadFollowingList();
  }

  // load followers
  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
  }

  // load following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // listen to followers & following
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);

    // TAB CONTROLLER
    return DefaultTabController(
      length: 2,

      // SCAFFOLD
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        // App Bar
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          // Tab Bar
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,

            // Tabs
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        // Body
        body: TabBarView(
          children: [
            _buildUserList(followers, 'No followers..'),
            _buildUserList(following, 'No following..'),
          ],
        ),
      ),
    );
  }

  // build user list, given a list of profiles
  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ?
        // empty message if there are no users
        Center(
            child: Text(emptyMessage),
          )
        :
        // user list
        ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              // get each user
              final user = userList[index];

              // return as a user list tile
              return MyUserTile(user: user);
            },
          );
  }
}
