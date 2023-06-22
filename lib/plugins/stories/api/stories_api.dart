import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StoriesApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  // Delete the Story
  Future<void> deleteStory({
    required DocumentSnapshot<Map<String, dynamic>> story,
  }) async {
    // Handle Delete Story
    try {
      // Check Story media type
      if (story.data()!['story_type'] == 'video' ||
          story.data()!['story_type'] == 'image') {
        // Delete the uploaded story file
        FirebaseStorage.instance
            .refFromURL(story.data()!['story_url'])
            .delete();
      }

      // Get User ID
      final String userId = story['user_id'];

      // Delete Story Document
      await story.reference.delete();

      // Get updated user stories list
      final stories = (await _firestore
              .collection('Stories')
              .where('user_id', isEqualTo: userId)
              .get())
          .docs;

      // Check the total stories to decrement
      if (stories.length > 1) {
        // Replace the Deleted Story with next one
        updateStoryProfile(stories.last, isIncrement: false);
      } else {
        // Also Delete the Story profile
        (await _firestore.collection('StoryProfiles').doc(userId).get())
            .reference
            .delete();
      }
    } catch (e) {
      // Debug
      debugPrint('deleteStory() -> error: $e');
    }
  }

  // Update the Story Profile
  Future<void> updateStoryProfile(
    DocumentSnapshot<Map<String, dynamic>> story, {
    isIncrement = true,
  }) async {
    // Save Last Story in Profiles Group
    await _firestore
        .collection('StoryProfiles')
        .doc(story.data()![USER_ID])
        .set({
      USER_ID: story.data()![USER_ID],
      USER_GENDER: story.data()![USER_GENDER],
      'story_status': 'active',
      'story_type': story.data()!['story_type'],
      'story_url': story.data()!['story_url'],
      'story_caption': story.data()!['story_caption'],
      'story_color': story.data()!['story_color'],
      TIMESTAMP: FieldValue.serverTimestamp(),
      'total_stories':
          isIncrement ? FieldValue.increment(1) : FieldValue.increment(-1)
    }, SetOptions(merge: true));
  }

  /// Get Stories Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getStories() {
    Query<Map<String, dynamic>> query = _firestore
        .collection('Stories')
        .where('story_status', isEqualTo: 'flagged');
    // Order by newest status
    query = query.orderBy('story_flagged_time', descending: true);
    return query.snapshots();
  }
}
