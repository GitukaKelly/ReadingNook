import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_application/screens/book_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> books = []; // List to store books from API
  bool isLoading = true;
  
  get backgroundColor => null; // To show a loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
  try {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=free+books&maxResults=40'));
          if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> fetchedBooks = [];
      for (var item in data['items']) {
        final volumeInfo = item['volumeInfo'];
        final accessInfo = item['accessInfo'];
        final pdfLink = accessInfo['pdf']?['acsTokenLink'] ?? "";
        final epubLink = accessInfo['epub']?['acsTokenLink'] ?? "";
        final imageLinks = volumeInfo['imageLinks'];
        fetchedBooks.add({
          "title": volumeInfo['title'] ?? "Unknown Title",
          "author": (volumeInfo['authors'] != null)
              ? (volumeInfo['authors'] as List<dynamic>).join(", ")
              : "Unknown Author",
          "thumbnailUrl": imageLinks != null
              ? imageLinks['thumbnail'] ?? ""
              : "", // Get the thumbnail URL if available
          "description":volumeInfo["description"] ?? "No description Available",
          "pdfLink": pdfLink,
          "epubLink": epubLink,
        });
      }
      setState(() {
        books = fetchedBooks; // Update the books list
        isLoading = false; // Stop showing the loading indicator
      });
    } else {
      throw Exception('Failed to load books');
    }
  } catch (e) {
    setState(() {
      isLoading = false; // Stop loading indicator even if there's an error
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching books: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
      SizedBox(
  width: double.infinity,
  height: 60,
  child: Container(
    color: Colors.pink, // Background color
    alignment: Alignment.bottomLeft, // Align text to the left
    padding: EdgeInsets.only(left: 16), // Add padding for spacing
    child: Text(
      "Reading Nook",
      style: TextStyle(
        color: Colors.white, // Text color
        fontSize: 22, // Font size
        fontWeight: FontWeight.bold, // Bold text
      ),
    ),
  ),
),

          // Banner at the top
          // ignore: sized_box_for_whitespace
          Container(
  width: double.infinity,
  height: 180,
  child: Image.network(
    'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiZVFI2MehFy4iYziil6aooZtoIpN1tmUgtOivd3SbnDCTaxthdvC_pb9_fEzKTHrTeifzB2DzAFhnoVrZI1NQwkJBlEYbOIHaPcF3oKyAAbmomtWHiJonKVAT-Wg5RethiBXAPGG2CB1dE-atNhkB4dgzyz7pU0kKjJ2F-xTlz4sy487X7tItikAGLicjZ/s768/0A40A036-F16F-4018-8A09-89E12CD5F4FF_1.jpg', //  image URL
    fit: BoxFit.cover, // Ensures the image covers the entire container
    errorBuilder: (context, error, stackTrace) {
      return Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 50,
        ), // Fallback icon if image fails to load
      );
    },
  ),
),
          // Display a loading indicator while data is being fetched
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            // List of books
            Expanded(
              child: books.isEmpty
                  ? Center(
                      child: Text(
                        'No books found.',
                        style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 171, 170, 170)),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            leading: Image.network(
  book["thumbnailUrl"]!,
  width: 50,  // Set the width of the thumbnail
  height: 70, // Set the height of the thumbnail
  fit: BoxFit.cover, // Crop or scale the image to fill
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image, color: Colors.grey); // Fallback for broken images
  },
),

                            title: Text(
                              book["title"]!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(book["author"]!),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookDetailsScreen(
        title: book["title"]!,
        author: book["author"]!,
        description: book["description"] !,
        thumbnailUrl: book["thumbnailUrl"]!, pdfLink:book["pdfLink"]!, epubLink: book["epubLink"]!,
      ),
    ),
  );
},
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
