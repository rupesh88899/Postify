import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/comment_card.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/responsive/responsive.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    required this.postId,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  //textEditing controller to see waht user have typed
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

//for comments
  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      //this help to make our text fild empty when we save previous comment
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ref.watch(getPostByIdProvider(widget.postId)).when(
              data: (data) {
                return Column(
                  children: [
                    PostCard(post: data),
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addComment(data),
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'What are yout thoughts?',
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    ref.watch(getPostCommentsProvider(widget.postId)).when(
                          data: (data) {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final comment = data[index];
                                  return CommentCard(comment: comment);
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) => ErrorText(
                              error: error.toString(),
                              stackTrace: stackTrace.toString()),
                          loading: () => const Loader(),
                        )
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(
                  error: error.toString(), stackTrace: stackTrace.toString()),
              loading: () => const Loader(),
            ));
  }
}
