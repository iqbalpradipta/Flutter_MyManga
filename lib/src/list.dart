import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_manga/src/detail.dart';

class MangaSummary {
  final int id;
  final String title;
  final String imageUrl;

  MangaSummary({required this.id, required this.title, required this.imageUrl});

  factory MangaSummary.fromJson(Map<String, dynamic> json) {
    return MangaSummary(
      id: json['id'],
      title: json['title'],
      imageUrl: json['comic_image'],
    );
  }
}

Future<List<MangaSummary>> fetchMangaList() async {
  final response = await http.get(
    Uri.parse('https://api.npoint.io/3178c2ddc4be5b84c2e9/'),
  );
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => MangaSummary.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat daftar manga');
  }
}

class ListManga extends StatefulWidget {
  const ListManga({super.key});

  @override
  State<ListManga> createState() => _ListMangaState();
}

class _ListMangaState extends State<ListManga> {
  List<MangaSummary> _allManga = [];
  List<MangaSummary> _filteredManga = [];

  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMangaData();
  }

  Future<void> _loadMangaData() async {
    try {
      final data = await fetchMangaList();
      setState(() {
        _allManga = data;
        _filteredManga = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterManga(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredManga = _allManga;
      } else if (filter == '0-9') {
        _filteredManga = _allManga.where((manga) {
          final firstChar = manga.title.trim().substring(0, 1);
          return int.tryParse(firstChar) != null;
        }).toList();
      } else {
        _filteredManga = _allManga
            .where(
              (manga) => manga.title.trim().toUpperCase().startsWith(filter),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        title: const Text('Daftar Manga'),
        backgroundColor: const Color(0xFF1F1D2B),
        elevation: 0,
      ),
      body: Column(
        children: [
          FilterBar(
            selectedFilter: _selectedFilter,
            onFilterSelected: _filterManga,
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (_filteredManga.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada manga yang cocok.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 3.2,
      ),
      itemCount: _filteredManga.length,
      itemBuilder: (context, index) {
        final manga = _filteredManga[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailManga(mangaId: manga.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    manga.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                manga.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', '0-9', ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(filter),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: isSelected
                  ? Colors.deepPurple.shade400
                  : Colors.grey.shade800,
              onPressed: () => onFilterSelected(filter),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}
