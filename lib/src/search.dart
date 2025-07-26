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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<MangaSummary> _allManga = [];
  List<MangaSummary> _searchResults = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMangaData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadMangaData() async {
    try {
      final data = await fetchMangaList();
      setState(() {
        _allManga = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allManga.where((manga) {
          return manga.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF252836),
                  hintText: 'Search manga...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(child: _buildContent()),
            ],
          ),
        ),
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
    if (_searchController.text.isNotEmpty) {
      return SearchResultList(results: _searchResults);
    }
    return const InitialSearchFilters();
  }
}

class SearchResultList extends StatelessWidget {
  final List<MangaSummary> results;
  const SearchResultList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No results found.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final manga = results[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(manga.imageUrl, width: 50, fit: BoxFit.cover),
          ),
          title: Text(manga.title, style: const TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailManga(mangaId: manga.id),
              ),
            );
          },
        );
      },
    );
  }
}

class InitialSearchFilters extends StatelessWidget {
  const InitialSearchFilters({super.key});

  @override
  Widget build(BuildContext context) {
    const lastSearches = ['Demon Hunter', 'Berserk'];
    const popularSearches = [
      'Manhua',
      'Hot',
      'Berserk',
      'Top Rated',
      'Vampire',
      'Drama',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Last search',
            actionText: 'clear all',
            onActionPressed: () {},
          ),
          SearchChipGroup(terms: lastSearches),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Popular search'),
          SearchChipGroup(terms: popularSearches),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick filters'),
          const SizedBox(height: 8),
          const Text(
            'Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const StatusFilterChips(),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Genres',
            actionText: 'see all',
            onActionPressed: () {},
          ),
          const GenreFilterChips(),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionText!,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
      ],
    );
  }
}

class SearchChipGroup extends StatelessWidget {
  final List<String> terms;
  const SearchChipGroup({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: terms
          .map(
            (term) => Chip(
              label: Text(term),
              backgroundColor: const Color(0xFF252836),
              labelStyle: const TextStyle(color: Colors.white),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }
}

class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Ongoing'),
          avatar: const Icon(Icons.flag, color: Colors.orange, size: 16),
          selected: true,
          onSelected: (selected) {},
          backgroundColor: const Color(0xFF252836),
          selectedColor: Colors.orange,
          labelStyle: const TextStyle(color: Colors.orange),
          side: BorderSide.none,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Completed'),
          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
          selected: false,
          onSelected: (selected) {},
          backgroundColor: const Color(0xFF252836),
          selectedColor: Colors.green,
          labelStyle: const TextStyle(color: Colors.green),
          side: BorderSide.none,
        ),
      ],
    );
  }
}

class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = {
      'Sci-Fi': '💖',
      'Horror': '👻',
      'Sport': '⚽',
      'Romance': '❤️',
      'Comedy': '😂',
      'Adventure': '🚀',
    };

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: genres.entries.map((entry) {
        return Chip(
          avatar: Text(entry.value, style: const TextStyle(fontSize: 16)),
          label: Text(entry.key),
          backgroundColor: const Color(0xFF252836),
          labelStyle: const TextStyle(color: Colors.white),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
