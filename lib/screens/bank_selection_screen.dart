import 'package:flutter/material.dart';
import '../models/vietnamese_bank.dart';
import '../services/vietnamese_bank_service.dart';

class BankSelectionScreen extends StatefulWidget {
  final Function(VietnameseBank) onBankSelected;

  const BankSelectionScreen({super.key, required this.onBankSelected});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  final bankService = VietnameseBankService();
  final searchController = TextEditingController();
  List<VietnameseBank> filteredBanks = [];
  List<VietnameseBank> popularBanks = [];
  bool showAllBanks = false;

  @override
  void initState() {
    super.initState();
    popularBanks = bankService.getPopularBanks();
    filteredBanks = popularBanks;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBanks = showAllBanks ? bankService.getAllBanks() : popularBanks;
      } else {
        filteredBanks = bankService.searchBanks(query);
      }
    });
  }

  void _toggleShowAllBanks() {
    setState(() {
      showAllBanks = !showAllBanks;
      if (searchController.text.isEmpty) {
        filteredBanks = showAllBanks ? bankService.getAllBanks() : popularBanks;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chọn ngân hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ngân hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Show all banks toggle
          if (searchController.text.isEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showAllBanks
                          ? 'Hiển thị tất cả ngân hàng (${bankService.getAllBanks().length})'
                          : 'Hiển thị ngân hàng phổ biến (${popularBanks.length})',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleShowAllBanks,
                    child: Text(
                      showAllBanks ? 'Thu gọn' : 'Xem tất cả',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Banks list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBanks.length,
              itemBuilder: (context, index) {
                final bank = filteredBanks[index];
                return _buildBankCard(bank);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(VietnameseBank bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => widget.onBankSelected(bank),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bank logo placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _parseColor(bank.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      bank.shortName.length > 3
                          ? bank.shortName.substring(0, 3).toUpperCase()
                          : bank.shortName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _parseColor(bank.color),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Bank info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.shortName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bank.name,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
