import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalamazoo_app_dashboard/dialogs/common_dialogs.dart';
import 'package:kalamazoo_app_dashboard/dialogs/progress_dialog.dart';
import 'package:kalamazoo_app_dashboard/plugins/stories/api/stories_api.dart';
import 'package:kalamazoo_app_dashboard/widgets/my_circular_progress.dart';
import 'package:kalamazoo_app_dashboard/widgets/show_scaffold_msg.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ViewStory extends StatefulWidget {
  // Variables
  final DocumentSnapshot<Map<String, dynamic>> story;

  const ViewStory(this.story, {Key? key}) : super(key: key);

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  // Variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storiesApi = StoriesApi();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  void _loadVideoStory() async {
    // Check Story media
    if (widget.story.data()!['story_type'] == 'video') {
      // Get the video url
      _videoPlayerController =
          VideoPlayerController.network(widget.story.data()!['story_url']);
      // Init the video player
      await _videoPlayerController!.initialize();
      // Define video settings
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          allowFullScreen: false);
      // Update UI
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVideoStory();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget storyContent = Container();

    // Control the Story media type
    switch (widget.story.data()!['story_type']) {
      case 'video':
        // Check the video controllers
        if (_chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized) {
          // Get video widget
          storyContent = SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // show story caption
                _showStoryCaption(),
                // Show video story
                Chewie(
                  controller: _chewieController!,
                ),
              ],
            ),
          );
        } else {
          storyContent = const MyCircularProgress();
        }
        break;
      case 'image':
        storyContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // show story caption
            _showStoryCaption(),
            Image.network(widget.story.data()!['story_url']),
          ],
        );
        break;
      case 'text':
        storyContent = Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.story.data()?['story_caption'] ?? '',
                style: const TextStyle(fontSize: 30, color: Colors.white)),
          ),
        );
        break;
    }

    // Scaffold
    return Scaffold(
        appBar: AppBar(
          title: const Text("View Story Media"),
          actions: [
            // Show Story options
            _showOptions()
          ],
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              elevation: 10.0,
              //shape: defaultCardBorder(),
              color: widget.story.data()!['story_type'] == 'text'
                  ? Color(int.parse(widget.story
                      .data()!['story_color']
                      .toString()
                      .replaceAll('#', '0xff')))
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: storyContent,
              ),
            ),
          ),
        ));
  }

  Widget _showStoryCaption() {
    // show story caption
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.story.data()?['story_caption'] ?? '',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor)),
      ),
    );
  }

  Widget _showOptions() {
    /// Actions list
    return PopupMenuButton<String>(
      initialValue: "",
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        /// Copy User ID
        const PopupMenuItem(
            value: "activate",
            child: ListTile(
              leading: Text("Activate Story"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            )),

        /// Copy Phone Number
        const PopupMenuItem(
            value: "delete",
            child: ListTile(
              leading: Text("Delete Story"),
              trailing: Icon(Icons.delete, color: Colors.red),
            )),
      ],
      onSelected: (val) {
        /// Control selected value
        switch (val) {
          case 'activate':
            // Activate Story
            //
            // Show confirm dialog
            confirmDialog(context,
                message: 'The Story will be Activated!',
                negativeText: 'CANCEL',
                negativeAction: () => Navigator.of(context).pop(),
                positiveText: 'ACTIVATE',
                positiveAction: () async {
                  // instance
                  final _pr = ProgressDialog(context, isDismissible: false);
                  // Show processing dialog
                  _pr.show("Processing...");

                  // Activate the story
                  await widget.story.reference
                      .update({'story_status': 'active'});
                  // Increment Profile Total Stories
                  await _storiesApi.updateStoryProfile(widget.story);
                  // close progress
                  _pr.hide();

                  // Show success message
                  showScaffoldMessage(
                      context: context,
                      scaffoldkey: _scaffoldKey,
                      message: "Story activated successfully!");

                  // Close dialog
                  Navigator.of(context).pop();
                  // Close screen
                  Navigator.of(context).pop();
                });
            break;

          case 'delete':
            // Show confirm dialog
            confirmDialog(context,
                message: 'The Story will be deleted!',
                negativeText: 'CANCEL',
                negativeAction: () => Navigator.of(context).pop(),
                positiveText: 'DELETE',
                positiveAction: () async {
                  // instance
                  final _pr = ProgressDialog(context, isDismissible: false);
                  // Show processing dialog
                  _pr.show("Processing...");

                  // Delete the Story
                  await _storiesApi.deleteStory(story: widget.story);
                  // close progress
                  _pr.hide();

                  // Show success message
                  showScaffoldMessage(
                      context: context,
                      scaffoldkey: _scaffoldKey,
                      message: "Story deleted successfully!");

                  // Close dialog
                  Navigator.of(context).pop();
                  // Close screen
                  Navigator.of(context).pop();
                });
            break;
        }
      },
    );
  }
}
