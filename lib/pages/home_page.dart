import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_drawer.dart';
import 'package:twitter_clone_app/components/my_input_alert_box.dart';
import 'package:twitter_clone_app/components/my_post_tile.dart';
import 'package:twitter_clone_app/helper/navigate_pages.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';

/*

HOME PAGE

This is the main page of this app: It displays a list of all posts.

--------------------------------------------------------------------------------

We can organize this page using a tab bar to split into:

  - for you page
  - following page

--------------------------------------------------------------------------------

What's the difference between listeningProvider and databaseProvider?
listeningProvider is used to listen for changes, where as databaseProvider is
used to execute function inside of the provider.

*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // text controllers
  final _messageController = TextEditingController();

  // on startup
  @override
  void initState() {
    super.initState();

    // let's load all the posts!
    loadAllPosts();
  }

  // load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  // show post messge dialog box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _messageController,
        hintText: 'What\'s on your mind?',
        onPressed: () async {
          // post in db
          await postMessage(_messageController.text);
        },
        onPressedText: 'Post',
      ),
    );
  }

  // user want to post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // TAB CONTROLLER: 2 options -> for you / following
    return DefaultTabController(
      length: 2,

      // SCAFFOLD
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),

        // App Bar
        appBar: AppBar(
          title: const Text("H O M E"),
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,

            // Tabs
            tabs: const [
              Tab(text: 'For you'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        // Floating Action Button
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),

        // Body: list of all posts
        body: TabBarView(
          children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
          ],
        ),
      ),
    );
  }

  // build list UI given a list of posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
        // post list is empty
        const Center(
            child: Text('Nothing here..'),
          )
        :
        // post list is NOT empty
        ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              // get each individual post
              final post = posts[index];

              // return Post Tile UI
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            },
          );
  }
}
