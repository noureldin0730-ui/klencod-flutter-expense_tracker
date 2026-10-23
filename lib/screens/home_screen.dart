import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  double _todayTotal = 0;
  double _weekTotal = 0;
  double _monthTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DatabaseHelper.instance.getAll();
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final startOfMonth = DateTime(now.year, now.month, 1);

    final tTotal = await DatabaseHelper.instance.getTotal(startOfDay, endOfDay);
    final wTotal = await DatabaseHelper.instance.getTotal(startOfWeekDay, endOfDay);
    final mTotal = await DatabaseHelper.instance.getTotal(startOfMonth, endOfDay);

    setState(() {
      _expenses = all;
      _todayTotal = tTotal;
      _weekTotal = wTotal;
      _monthTotal = mTotal;
    });
  }

  Future<void> _delete(Expense e) async {
    await DatabaseHelper.instance.delete(e.id!);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'ar', symbol: 'ج.م', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مصاريفي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('اليوم', _todayTotal, fmt),
                _buildStat('الأسبوع', _weekTotal, fmt),
                _buildStat('الشهر', _monthTotal, fmt),
              ],
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('لا توجد مصاريف مسجلة'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (_, i) {
                      final e = _expenses[i];
                      return ExpenseTile(
                        expense: e,
                        onDelete: () => _delete(e),
                      );
                    },
                  ),
          ),
          // تذييل الحقوق بخط خفيف
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'الحقوق محفوظة © 2026 ALPHA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300, // خط خفيف
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (added == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStat(String label, double value, NumberFormat fmt) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(fmt.format(value), style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}