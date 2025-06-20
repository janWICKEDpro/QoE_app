import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qoe_app/models/review.dart';
import 'package:qoe_app/supabase/db_methods.dart';

final formKey = GlobalKey<FormState>();

class ISPRatingDialog extends StatefulWidget {
  const ISPRatingDialog({super.key});

  @override
  State<ISPRatingDialog> createState() => _ISPRatingDialogState();
}

class _ISPRatingDialogState extends State<ISPRatingDialog> {
  final db = DbMethods();
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = false;
  double _rating = 4.0;
  final int _maxReviewLines = 7;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<bool> _submitRating() async {
    setState(() {
      isLoading = true;
    });
    try {
      final review = Review(rating: _rating, comment: _commentController.text);
      final response = await db.storeReviews(review);
      setState(() {
        isLoading = false;
      });
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Rating submitted successfully",
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _commentController.clear();
        _rating = 0.0;
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Rating submitted successfully",
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error Occured", style: const TextStyle(fontSize: 16)),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min,
              children: [
                Text(
                  'Rate Your Internet Service Experience',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'How would you rate your satisfaction with your current ISP?',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemSize: 30,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Color(0xFFFFC107)),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _commentController,
                  maxLines: _maxReviewLines,
                  validator: (review) {
                    if (review == null || review.isEmpty) {
                      return 'Please enter your review';
                    }
                    if (review.length < 10) {
                      return 'Review must be at least 10 characters long';
                    }
                    if (review.length > 500) {
                      return 'Review cannot exceed 500 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Write your review here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final res = await _submitRating();
                          if (res) {
                            Navigator.of(context).pop({
                              'rating': _rating,
                              'comment': _commentController.text,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                        child:
                            isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                  'Submit Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> showISPRatingDialog(BuildContext context) async {
  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return const ISPRatingDialog();
    },
  );
}

class TestScreenForRatingDialog extends StatelessWidget {
  const TestScreenForRatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISP Rating Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showISPRatingDialog(context);
            if (result != null) {
              debugPrint(
                'Rating: ${result['rating']}, Comment: ${result['comment']}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Thanks for your feedback! Rating: ${result['rating']}, Comment: "${result['comment']}"',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              debugPrint('Rating dialog cancelled.');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rating cancelled.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Rate ISP'),
        ),
      ),
    );
  }
}
