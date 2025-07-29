import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:manga_bal/src/detail.dart';
import 'package:manga_bal/src/model/manga_detail.dart';


Future<List<MangaSummary>> searchManga({
  String query = '',
  String? status,
  List<String> genres = const [],
}) async {
  final Map<String, dynamic> queryParams = {'limit': '50'}; 
  if (query.isNotEmpty) {
    queryParams['q'] = query;
  }
  if (status != null) {
    queryParams['status'] = status;
  }
  if (genres.isNotEmpty) {
    queryParams['genre'] = genres.join(',');
  }

  final uri = Uri.parse('https://flutter-my-manga.vercel.app/api/v1/comic')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final decodedResponse = jsonDecode(response.body);
    final List<dynamic> data = decodedResponse['data'];
    return data.map((json) => MangaSummary.fromJson(json)).toList();
  } else {
    throw Exception('Gagal melakukan pencarian manga');
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  
  List<MangaSummary> _searchResults = [];
  bool _isSearching = false;
  String? _error;
  Timer? _debounce;

  String? _selectedStatus;
  final List<String> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_triggerSearch);
  }

  void _triggerSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_searchController.text.isEmpty && _selectedStatus == null && _selectedGenres.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _error = null;
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _error = null;
      });

      try {
        final results = await searchManga(
          query: _searchController.text,
          status: _selectedStatus,
          genres: _selectedGenres,
        );
        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _onStatusSelected(String status) {
    setState(() {
      if (_selectedStatus == status) {
        _selectedStatus = null;
      } else {
        _selectedStatus = status;
      }
    });
    _triggerSearch();
  }

  void _onGenreSelected(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
    _triggerSearch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_triggerSearch);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSearchActive = _searchController.text.isNotEmpty || _selectedStatus != null || _selectedGenres.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF1F1D2B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF252836),
                hintText: 'Search manga...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _selectedStatus = null;
                      _selectedGenres.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white)))
                      : isSearchActive
                          ? SearchResultList(results: _searchResults)
                          : InitialSearchFilters(
                              onStatusSelected: _onStatusSelected,
                              onGenreSelected: _onGenreSelected,
                              selectedStatus: _selectedStatus,
                              selectedGenres: _selectedGenres,
                            ),
            ),
          ],
        ),
      ),
    );
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                manga.imageUrl, 
                width: 50, 
                height: 70, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 70,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
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
          ),
        );
      },
    );
  }
}

class InitialSearchFilters extends StatelessWidget {
  final Function(String) onStatusSelected;
  final Function(String) onGenreSelected;
  final String? selectedStatus;
  final List<String> selectedGenres;

  const InitialSearchFilters({
    super.key,
    required this.onStatusSelected,
    required this.onGenreSelected,
    this.selectedStatus,
    required this.selectedGenres,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick filters'),
          const SizedBox(height: 8),
          const Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StatusFilterChips(
            selectedStatus: selectedStatus,
            onSelected: onStatusSelected,
          ),
          const SizedBox(height: 16),
          SectionHeader(title: 'Genres', actionText: 'see all', onActionPressed: () {}),
          GenreFilterChips(
            selectedGenres: selectedGenres,
            onSelected: onGenreSelected,
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  const SectionHeader({super.key, required this.title, this.actionText, this.onActionPressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionText != null)
          TextButton(onPressed: onActionPressed, child: Text(actionText!, style: TextStyle(color: Colors.grey.shade400))),
      ],
    );
  }
}

class StatusFilterChips extends StatelessWidget {
  final String? selectedStatus;
  final Function(String) onSelected;
  const StatusFilterChips({super.key, this.selectedStatus, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Ongoing'),
          avatar: const Icon(Icons.flag, color: Colors.orange, size: 16),
          selected: selectedStatus == 'Ongoing',
          onSelected: (selected) => onSelected('Ongoing'),
          backgroundColor: const Color(0xFF252836),
          selectedColor: Colors.orange,
          labelStyle: const TextStyle(color: Colors.orange),
          side: BorderSide.none,
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Completed'),
          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
          selected: selectedStatus == 'Completed',
          onSelected: (selected) => onSelected('Completed'),
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
  final List<String> selectedGenres;
  final Function(String) onSelected;
  const GenreFilterChips({super.key, required this.selectedGenres, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final genres = {
      'Sci-Fi': '💖', 'Horror': '👻', 'Sport': '⚽',
      'Romance': '❤️', 'Comedy': '😂', 'Adventure': '🚀',
    };
    
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: genres.entries.map((entry) {
        final isSelected = selectedGenres.contains(entry.key);
        return FilterChip(
          avatar: Text(entry.value, style: const TextStyle(fontSize: 16)),
          label: Text(entry.key),
          selected: isSelected,
          onSelected: (selected) => onSelected(entry.key),
          backgroundColor: const Color(0xFF252836),
          selectedColor: Colors.deepPurpleAccent,
          labelStyle: const TextStyle(color: Colors.white),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}