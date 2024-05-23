import 'package:flutter/material.dart';
import 'package:roomi/src/widgets/floating_add_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'category_items_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, String>> categories = [];
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedCategories = prefs.getString('categories');
    if (storedCategories != null) {
      setState(() {
        categories = (json.decode(storedCategories) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('categories', json.encode(categories));
  }

  void _addCategory(String name, {String? imagePath}) {
    setState(() {
      categories.add({'name': name, 'imagePath': imagePath ?? ''});
    });
    _saveCategories();
  }

  void _editCategory(int index, String name, {String? imagePath}) {
    setState(() {
      categories[index]['name'] = name;
      if (imagePath != null) {
        categories[index]['imagePath'] = imagePath;
      }
    });
    _saveCategories();
  }

  void _deleteCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
    _saveCategories();
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _editCategory(index, categories[index]['name']!,
          imagePath: pickedFile.path);
    }
  }

  void _showAddCategoryDialog({int? index}) {
    final TextEditingController controller = TextEditingController();
    if (index != null) {
      controller.text = categories[index]['name']!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            if (index != null)
              TextButton(
                onPressed: () {
                  _deleteCategory(index);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  return;
                }
                if (index == null) {
                  _addCategory(controller.text);
                } else {
                  _editCategory(index, controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            if (index != null)
              TextButton(
                onPressed: () {
                  _pickImage(index);
                },
                child: const Text('Change Image'),
              ),
          ],
        );
      },
    );
  }

  List<Map<String, String>> _filteredCategories() {
    if (_searchController.text.isEmpty) {
      return categories;
    } else {
      return categories
          .where((category) => category['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _filteredCategories().isEmpty
                ? const Center(
                    child: Text(
                      'No categories added. Click + to add a category.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredCategories().length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories()[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryItemsPage(
                                  category: category['name']!),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showAddCategoryDialog(index: index);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        color: category['imagePath']!.isEmpty
                                            ? Colors.blueAccent
                                            : null,
                                        image: category['imagePath']!.isNotEmpty
                                            ? DecorationImage(
                                                image: FileImage(File(
                                                    category['imagePath']!)),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: category['imagePath']!.isEmpty
                                          ? const Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          category['name']!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: () {
                                    _showAddCategoryDialog(index: index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingAddButton(
        onPressed: () => _showAddCategoryDialog(),
      ),
    );
  }
}
