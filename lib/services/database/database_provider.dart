import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/comment.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/database_service.dart';
import '../../models/post.dart';
import '../../models/user.dart';

/*

DATABASE PROVIDER

This provider is to separate the firestore data handling and the UI of our app.

--------------------------------------------------------------------------------

- The database service class handles data to and from firebase
- The database provider class processes the data to display in our app

This is to make our code much more modular, cleaner, and easier to read and test.
Particularly as the number of pages grow, we need this provider to properly manage
the different states of the app.

- Also, if one day, we decide to change our backend (from firebase to something else)
then it's much easier to manage and switch out different databases.

*/

class DatabaseProvider extends ChangeNotifier {
  /*
  
  SERVICES
  
  */

  // get db & auth service
  final _db = DatabaseService();
  final _auth = AuthService();

  /*
  
  USER PROFILE
  
  */

  // get user profile given uid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  // update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  /*
  
  POSTS
  
  */

  // local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  // get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  // post message
  Future<void> postMessage(String message) async {
    // post message in firebase
    await _db.postMessageInFirebase(message);

    // reload data from firebase
    await loadAllPosts();
  }

  // fetch all posts
  Future<void> loadAllPosts() async {
    // get all posts from firebase
    final allPosts = await _db.getAllPostsFromFirebase();

    // get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    // filter out blocked users posts & update locally
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    // filter out the following posts
    loadFollowingPosts();

    // initialize local like data
    initializeLikeMap();

    // update UI
    notifyListeners();
  }

  // filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // load following posts -> posts from users that the current user follows
  Future<void> loadFollowingPosts() async {
    // get current uid
    String currentUid = _auth.getCurrentUid();

    // get list of uids that the current logged in user follows (from firebase)
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);

    // filter all posts to be the ones for the following tab
    _followingPosts =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();

    // update UI
    notifyListeners();
  }

  // delete post
  Future<void> deletePost(String postId) async {
    // delete from firebase
    await _db.deletePostFromFirebase(postId);

    // reload data from firebase
    await loadAllPosts();
  }

  /*
  
  LIKES
  
  */

  // Local map to track like counts for each post
  Map<String, int> _likeCounts = {
    // for each post id: like count
  };

  // Local list to track posts liked by current user
  List<String> _likedPosts = [];

  // does current user like this post?
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  // get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // Initialize like map locally
  void initializeLikeMap() {
    // get current uid
    final currentUserID = _auth.getCurrentUid();

    // clear liked posts (for when new user signs in, clear local data)
    _likedPosts.clear();

    // for each post get like data
    for (var post in _allPosts) {
      // update like count map
      _likeCounts[post.id] = post.likeCount;

      // if the current user already likes this post
      if (post.likedBy.contains(currentUserID)) {
        // add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  // toggle like
  Future<void> toggleLike(String postId) async {
    /*
    
    This first part will update the local values first so that the UI feels
    immediate and responsive. We will update the UI optimistically, and revert
    back if anything goes wrong while writing to the database

    Optimistically updating the local values like this is important because:
    reading and writing from the database takes some time (1-2 seconds, depending
    on the internet connection). So we don't want to give the user a slow lagged
    experience.

    */

    // store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    // perform like / unlike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    // update UI locally
    notifyListeners();

    /*
    
    Now let's try to update it in our database
    
    */

    // attempt like in database
    try {
      await _db.toggleLikeInFirebase(postId);
    }

    // revert back to initial state if update fails
    catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      // update UI again
      notifyListeners();
    }
  }

  /*
  
  COMMENTS

  {
  
  postId1: [ comment1, comment2, .. ],
  postId2: [ comment1, comment2, .. ],
  postId3: [ comment1, comment2, .. ],
  
  }
  
  */

  // local list of comments
  final Map<String, List<Comment>> _comments = {};

  // get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  // fetch comments from database for a post
  Future<void> loadComments(String postId) async {
    // get all comments for this post
    final allComments = await _db.getCommentsFromFirebase(postId);

    // update local data
    _comments[postId] = allComments;

    // update UI
    notifyListeners();
  }

  // add a comment
  Future<void> addComment(
    String postId,
    message,
  ) async {
    // add comment in firebase
    await _db.addCommentInFirebase(postId, message);

    // reload comments
    await loadComments(postId);
  }

  // delete a comment
  Future<void> deleteComment(
    String commentId,
    postId,
  ) async {
    // delete comment in firebase
    await _db.deleteCommentInFirebase(commentId);

    // reload comments
    await loadComments(postId);
  }

  /*
  
  ACCOUNT STUFF
  
  */

  // local list of blocked users
  List<UserProfile> _blockedUsers = [];

  // get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  // fetch blocked users
  Future<void> loadBlockedUsers() async {
    // get list of blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    // get full user details using uid
    final blockedUsersData = await Future.wait(
      blockedUserIds.map(
        (id) => _db.getUserFromFirebase(id),
      ),
    );

    // return as a list
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();

    // update UI
    notifyListeners();
  }

  // block user
  Future<void> blockUser(String userId) async {
    // perform block in firebase
    await _db.blockUserInFirebase(userId);

    // reload blocked users
    await loadBlockedUsers();

    // reload data
    await loadAllPosts();

    // update UI
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    // perform unblock in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    // reload blocked users
    await loadBlockedUsers();

    // reload posts
    await loadAllPosts();

    // update UI
    notifyListeners();
  }

  // report user & post
  Future<void> reportUser(
    String postId,
    userId,
  ) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  /*
  
  FOLLOW

  Everything here is done with uids (String)

  ------------------------------------------------------------------------------

  Each user id has a list of:
    - followers uid
    - following uid

  E.g.

  {
  
  'uid1': [ list of uids there are followers / following ],
  'uid2': [ list of uids there are followers / following ],
  'uid3': [ list of uids there are followers / following ],
  'uid4': [ list of uids there are followers / following ],
  
  }
  
  */

  // local map
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  // get counts for followers & following locally: given a uid
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  // load followers
  Future<void> loadUserFollowers(String uid) async {
    // get the list of follower uids from firebase
    final listOfFollowersUids = await _db.getFollowerUidsFromFirebase(uid);

    // update local data
    _followers[uid] = listOfFollowersUids;
    _followerCount[uid] = listOfFollowersUids.length;

    // update UI
    notifyListeners();
  }

  // load following
  Future<void> loadUserFollowing(String uid) async {
    // get the list of following uids from firebase
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    // update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    // update UI
    notifyListeners();
  }

  // follow user
  Future<void> followUser(String targetUserId) async {
    /*
    
    currently logged in user wants to follow target user
    
    */

    // get current uid
    final currentUserId = _auth.getCurrentUid();

    // initialize with empty lists if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    /*
    
    Optimistic UI changes: Update the local data & revert back if database
    request fails
    
    */

    // follow if current user is not one of the target user's followers
    if (!_followers[targetUserId]!.contains(currentUserId)) {
      // add current user to target user's follower list
      _followers[targetUserId]?.add(currentUserId);

      // update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      // then add target user to current user following
      _following[currentUserId]?.add(targetUserId);

      // update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }

    // update UI
    notifyListeners();

    /*
    
    UI has been optimistically updated above with local data.
    Now let's try to make this request to our database.
    
    */

    try {
      // follow user in firebase
      await _db.followUserInFirebase(targetUserId);

      // reload current user's followers
      await loadUserFollowers(currentUserId);

      // reload current user's following
      await loadUserFollowing(currentUserId);
    }

    // if there is an error.. revert back to original
    catch (e) {
      // remove current user from target user's followers
      _followers[targetUserId]?.remove(currentUserId);

      // update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      // remove from current user's following
      _following[currentUserId]?.remove(targetUserId);

      // update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      // update UI
      notifyListeners();
    }
  }

  // unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    /*
    
    currently logged in user wants to unfollow target user
    
    */

    // get current uid
    final currentUserId = _auth.getCurrentUid();

    // initialize lists if they dont exist
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    /*
    
    Optimistic UI changes: Update the local data first & revert back if database
    request fails
    
    */

    // unfollow if current user is one of the target user's following
    if (_followers[targetUserId]!.contains(currentUserId)) {
      // remove current user from target user's following
      _followers[targetUserId]?.remove(currentUserId);

      // update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

      // remove target user from current user's following list
      _following[currentUserId]?.remove(targetUserId);

      // update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }

    // update UI
    notifyListeners();

    /*
    
    UI has been optimistically updated with local data above.
    Now let's try to make this request to our database.
    
    */

    try {
      // unfollow target user in firebase
      await _db.unfollowUserInFirebase(targetUserId);

      // reload user followers
      await loadUserFollowers(currentUserId);

      // reload user following
      await loadUserFollowing(currentUserId);
    }

    // if there is an error.. revert back to original
    catch (e) {
      // add current user back into target user's followers
      _followers[targetUserId]?.add(currentUserId);

      // update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      // add target user back into current user's following list
      _following[currentUserId]?.add(targetUserId);

      // update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      // update UI
      notifyListeners();
    }
  }

  // is current user following target user?
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  /*
  
  MAP OF PROFILES

  for a given uid:

  - list of follower profiles
  - list of following profiles
  
  */

  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  // get list of follower profiles for a given user
  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  // get list of following profiles for a given user
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  // load follower profiles for a given uid
  Future<void> loadUserFollowerProfiles(String uid) async {
    try {
      // get list of follower uids from firebase
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      // create list of user profiles
      List<UserProfile> followerProfiles = [];

      // go thru each follower id
      for (String followerId in followerIds) {
        // get user profile from firebase with this uid
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);

        // add to follower profile
        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }

      // update local data
      _followersProfile[uid] = followerProfiles;

      // update UI
      notifyListeners();
    }

    // if there are errors..
    catch (e) {
      print(e);
    }
  }

  // load following profiles for a given uid
  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      // get list of following uids from firebase
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      // create list of user profiles
      List<UserProfile> followingProfiles = [];

      // go thru each following id
      for (String followingId in followingIds) {
        // get user profile from firebase with this uid
        UserProfile? followingProfile =
            await _db.getUserFromFirebase(followingId);

        // add to following profile
        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }

      // update local data
      _followingProfile[uid] = followingProfiles;

      // update UI
      notifyListeners();
    }

    // if there are errors..
    catch (e) {
      print(e);
    }
  }

  /*
  
  SEARCH USERS
  
  */

  // list of search results
  List<UserProfile> _searchResults = [];

  // get list of search results
  List<UserProfile> get searchResult => _searchResults;

  // method to search for a user
  Future<void> searchUsers(String searchTerm) async {
    try {
      // search users in firebase
      final results = await _db.searchUsersInFirebase(searchTerm);

      // update local data
      _searchResults = results;

      // update UI
      notifyListeners();
    }

    // errors..
    catch (e) {
      print(e);
    }
  }
}
