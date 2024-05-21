import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryItemsPage extends StatefulWidget {
  final String category;

  const CategoryItemsPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedItems = prefs.getString('items_${widget.category}');
    if (storedItems != null) {
      setState(() {
        items = List<Map<String, dynamic>>.from(json.decode(storedItems));
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('items_${widget.category}', json.encode(items));
  }

  void _editItem(int index, String name, int quantity, String note) {
    setState(() {
      items[index] = {'name': name, 'quantity': quantity, 'note': note};
    });
    _saveItems();
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveItems();
  }

  void _addItem(String name) {
    setState(() {
      items.add({'name': name, 'quantity': 1, 'note': ''});
    });
    _saveItems();
  }

  void _showAddItemDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addItem(_controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(int index) {
    final TextEditingController _nameController = TextEditingController(text: items[index]['name']);
    final TextEditingController _quantityController =
        TextEditingController(text: items[index]['quantity'].toString());
    final TextEditingController _noteController = TextEditingController(text: items[index]['note']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(hintText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(hintText: 'Note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editItem(
                  index,
                  _nameController.text,
                  int.tryParse(_quantityController.text) ?? items[index]['quantity'],
                  _noteController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Quantity: ${item['quantity']}'),
            trailing: item['note'] != ''
                ? const Icon(Icons.note)
                : null,
            onTap: () {
              _showEditItemDialog(index);
            },
          );
        },
      ),
    );
  }
}
