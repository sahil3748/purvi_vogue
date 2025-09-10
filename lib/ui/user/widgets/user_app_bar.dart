import 'package:flutter/material.dart';

class UserAppBar extends StatelessWidget {
  const UserAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Row(
          children: [
            Text(
              'Purvi Vogue',
              style: TextStyle(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F9FA),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Search Button
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF1A237E)),
          onPressed: () {
            Navigator.pushNamed(context, '/user/search');
          },
        ),
        // Categories Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.category, color: Color(0xFF1A237E)),
          onSelected: (value) {
            Navigator.pushNamed(context, '/user/category', arguments: value);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'all',
              child: Text('All Categories'),
            ),
            const PopupMenuItem(
              value: 'women',
              child: Text('Women'),
            ),
            const PopupMenuItem(
              value: 'men',
              child: Text('Men'),
            ),
            const PopupMenuItem(
              value: 'unisex',
              child: Text('Unisex'),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
