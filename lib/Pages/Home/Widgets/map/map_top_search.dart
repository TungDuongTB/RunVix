import 'package:flutter/material.dart';
import 'package:runvix/export.dart';
import '../../../../Component/FilterComponent.dart';

class MapTopSearch extends StatelessWidget {
  const MapTopSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchRow(),
          const SizedBox(height: 8),
          _buildFilterRow(),
          const SizedBox(height: 16),
          _buildSearchHereButton(),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconCircle(Icons.directions_run),
          const SizedBox(width: 8),
          const Expanded(child: _SearchInput()),
          const SizedBox(width: 8),
          _buildSavedButton(),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.buttonColor),
    );
  }

  Widget _buildSavedButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: const Row(
        children: [
          Icon(Icons.bookmark_border, size: 20),
          SizedBox(width: 4),
          Text('Đã lưu', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AppFilterChip(label: 'Lộ trình', isSelected: true, hasDropdown: true, onTap: () {}),
          AppFilterChip(label: 'Độ dài', onTap: () {}),
          AppFilterChip(label: 'Độ cao', onTap: () {}),
          AppFilterChip(label: 'Bề mặt', onTap: () {}),
          AppFilterChip(label: 'Khó khăn', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchHereButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      child: const Text('Tìm kiếm tại đây', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm vị trí',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
