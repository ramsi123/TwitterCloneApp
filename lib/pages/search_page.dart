/*

SEARCH PAGE

User can search for any user in the database

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_user_tile.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SearchPage());
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // text controller
  final _searchController = TextEditingController();

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // provider
    final databaseProvider = Provider.of<DatabaseProvider>(
      context,
      listen: false,
    );
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    // Scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // App Bar -> Search Bar
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users..',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            border: InputBorder.none,
          ),

          // search will begin after each new character has been type
          onChanged: (value) {
            // search users
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value);
            }

            // clear results
            else {
              databaseProvider.searchUsers('');
            }
          },
        ),
      ),

      // body
      body: listeningProvider.searchResult.isEmpty
          ?
          // no users found..
          const Center(
              child: Text('No users found..'),
            )
          :

          // users found!
          ListView.builder(
              itemCount: listeningProvider.searchResult.length,
              itemBuilder: (context, index) {
                // get each user from search result
                final user = listeningProvider.searchResult[index];

                // return as a user tile
                return MyUserTile(user: user);
              },
            ),
    );
  }
}
