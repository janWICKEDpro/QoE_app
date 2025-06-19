import 'package:flutter/material.dart';

// A custom dialog widget for ISP satisfaction rating.
class ISPRatingDialog extends StatefulWidget {
  const ISPRatingDialog({super.key});

  @override
  State<ISPRatingDialog> createState() => _ISPRatingDialogState();
}

class _ISPRatingDialogState extends State<ISPRatingDialog> {
  int _selectedRating = 0; // Stores the selected star rating (0 to 5)
  final TextEditingController _commentController = TextEditingController(); // Controller for the comment input

  @override
  void dispose() {
    _commentController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Padding around the content
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the column take minimum vertical space
          children: [
            // Title for the dialog
            Text(
              'Rate Your ISP Experience',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Prompt for rating
            Text(
              'How would you rate your satisfaction with your current ISP?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Star Rating Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1; // Update rating on tap
                    });
                  },
                  child: Icon(
                    Icons.star_rounded, 
                    color: index < _selectedRating ? Colors.amber : Colors.grey.shade300, 
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Comment Text Field
            TextField(
              controller: _commentController,
              maxLines: 4, 
              decoration: InputDecoration(
                hintText: 'Share your comments (optional)',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: BorderSide(color: Colors.blue.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline, 
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null); 
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'rating': _selectedRating,
                      'comment': _commentController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue.shade600, 
                    foregroundColor: Colors.white,
                    elevation: 3, 
                  ),
                  child: const Text(
                    'Submit Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the ISP rating dialog
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
      appBar: AppBar(
        title: const Text('ISP Rating Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showISPRatingDialog(context);
            if (result != null) {
              debugPrint('Rating: ${result['rating']}, Comment: ${result['comment']}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thanks for your feedback! Rating: ${result['rating']}, Comment: "${result['comment']}"'),
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