import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LibraryHome(),
    );
  }
}

class LibraryHome extends StatefulWidget {
  const LibraryHome({super.key});

  @override
  _LibraryHomeState createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  static const available = 'Available';
  static const requested = 'Requested';
  static const accepted = 'Accepted';
  static const rejected = 'Rejected';
  static const cancelled = 'Cancelled';
  static const returned = 'Returned';

  final List<Book> books = [
    Book(name: 'Book A', author: 'Author 1', code: '001', status: available),
    Book(name: 'Book B', author: 'Author 2', code: '002', status: available),
    Book(name: 'Book C', author: 'Author 3', code: '003', status: requested),
    Book(name: 'Book D', author: 'Author 4', code: '004', status: requested),
    Book(name: 'Book E', author: 'Author 5', code: '005', status: available),
  ];

  bool isAdmin = false;
  String searchQuery = '';
  final TextEditingController codeController = TextEditingController();

  void requestBook(Book book) {
    setState(() {
      if (book.status == available) {
        book.status = requested;
      }
    });
  }

  void returnBook(Book book) {
    setState(() {
      if (book.status == accepted) {
        book.status = returned;
      }
    });
  }

  void cancelRequest(Book book) {
    setState(() {
      if (book.status == requested) {
        book.status = cancelled;
      }
    });
  }

  void approveRequest(Book book) {
    setState(() {
      if (book.status == requested) {
        book.status = accepted;
      }
    });
  }

  void rejectRequest(Book book) {
    setState(() {
      if (book.status == requested) {
        book.status = rejected;
      }
    });
  }

  Book? findBookByCode(String code) {
    return books.firstWhere(
      (book) => book.code == code,
      // orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Book> adminBooks = books
        .where((book) => book.status == requested)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Panel' : 'Library Home'),
        actions: [
          Switch(
            value: isAdmin,
            onChanged: (value) {
              setState(() {
                isAdmin = value;
              });
            },
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.blue,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isAdmin) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by Book Name or Author',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Book Code',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (!isAdmin) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final book = findBookByCode(codeController.text);
                    if (book != null) {
                      requestBook(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book requested')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book not found')),
                      );
                    }
                  },
                  child: const Text('Request'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final book = findBookByCode(codeController.text);
                    if (book != null) {
                      returnBook(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book returned')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book not found')),
                      );
                    }
                  },
                  child: const Text('Return'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final book = findBookByCode(codeController.text);
                    if (book != null) {
                      cancelRequest(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request cancelled')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book not found')),
                      );
                    }
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
          if (isAdmin) ...[
            Expanded(
              child: ListView.builder(
                itemCount: adminBooks.length,
                itemBuilder: (context, index) {
                  final book = adminBooks[index];
                  return ListTile(
                    title: Text('${book.name} by ${book.author}'),
                    subtitle: Text(
                      'Code: ${book.code} | Status: ${book.status}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            approveRequest(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Book request accepted'),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            rejectRequest(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Book request rejected'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          if (!isAdmin) ...[
            Expanded(
              child: ListView.builder(
                itemCount: books
                    .where(
                      (book) =>
                          book.name.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ) ||
                          book.author.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                    )
                    .toList()
                    .length,
                itemBuilder: (context, index) {
                  final book = books.firstWhere(
                    (book) =>
                        book.name.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ||
                        book.author.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                  );
                  return ListTile(
                    title: Text('${book.name} by ${book.author}'),
                    subtitle: Text(
                      'Code: ${book.code} | Status: ${book.status}',
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Book {
  String name;
  String author;
  String code;
  String status;

  Book({
    required this.name,
    required this.author,
    required this.code,
    required this.status,
  });
}
