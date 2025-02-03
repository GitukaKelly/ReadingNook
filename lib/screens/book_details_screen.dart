import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailsScreen extends StatelessWidget {
  final String title;
  final String author;
  final String description;
  final String thumbnailUrl;
  final String pdfLink;
  final String epubLink;

  // Constructor to receive book data
  const BookDetailsScreen({super.key, 
    required this.title,
    required this.author,
    required this.description,
    required this.thumbnailUrl,
    required this.pdfLink,
    required this.epubLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 236, 95, 218),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Thumbnail
            Center(
              child: Image.network(
                thumbnailUrl,
                width: 150,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Book Title
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              'by $author',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              description.isNotEmpty ? description : 'No description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Read Now Button
            if (pdfLink.isNotEmpty || epubLink.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _showReadOptions(context);
                },
                child: const Text('Read Now'),
              ),
          ],
        ),
      ),
    );
  }

  // Show Read Options
  void _showReadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pdfLink.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Read PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(Uri.parse(pdfLink))) {
                    await launchUrl(Uri.parse(pdfLink));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open PDF')),
                    );
                  }
                },
              ),
            if (epubLink.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Read EPUB'),
                onTap: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(Uri.parse(epubLink))) {
                    await launchUrl(Uri.parse(epubLink));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open EPUB')),
                    );
                  }
                },
              ),
          ],
        );
      },
    );
  }
}
