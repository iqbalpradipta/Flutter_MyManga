import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manga_bal/src/detail.dart';
import 'dart:convert';

import 'package:manga_bal/src/model/manga_detail.dart';

Future<List<MangaSummary>> fetchManga({
  required int page,
  String? query,
}) async {
  final Map<String, String> queryParams = {
    'page': page.toString(),
    'limit': '30',
  };

  if (query != null && query.isNotEmpty && query != 'All') {
    queryParams['q'] = query;
  }

  final uri = Uri.parse('https://flutter-my-manga.vercel.app/api/v1/comic')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final decodedResponse = jsonDecode(response.body);
    final List<dynamic> data = decodedResponse['data'];
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
  final List<MangaSummary> _mangaList = [];
  String? _error;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMangaData({bool isRefreshing = false}) async {
    if (_isLoadingMore || (!_hasMoreData && !isRefreshing)) return;

    setState(() {
      if (isRefreshing) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final newManga = await fetchManga(
        page: _currentPage,
        query: _selectedFilter,
      );

      setState(() {
        if (isRefreshing) {
          _mangaList.clear();
        }
        _mangaList.addAll(newManga);
        _currentPage++;
        if (newManga.length < 30) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }
  
  Future<void> _loadInitialData() async {
    _currentPage = 1;
    _hasMoreData = true;
    await _loadMangaData(isRefreshing: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadMangaData();
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadInitialData();
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
            onFilterSelected: _onFilterSelected,
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
      return Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white)));
    }
    if (_mangaList.isEmpty) {
      return const Center(child: Text('Tidak ada manga yang cocok.', style: TextStyle(color: Colors.white)));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 3.2,
      ),
      itemCount: _mangaList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _mangaList.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final manga = _mangaList[index];
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
                      return const Icon(Icons.image_not_supported, color: Colors.grey);
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

  const FilterBar({super.key, required this.selectedFilter, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')];
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
              backgroundColor: isSelected ? Colors.deepPurple.shade400 : Colors.grey.shade800,
              onPressed: () => onFilterSelected(filter),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}