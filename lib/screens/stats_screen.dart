import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final all = await DatabaseHelper.instance.getAll();
    final Map<String, double> totals = {};
    for (var e in all) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    setState(() => _categoryTotals = totals);
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryTotals.isEmpty) {
      return const Center(child: Text('لا توجد بيانات لعرضها'));
    }

    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink
    ];

    final sections = <PieChartSectionData>[];
    int idx = 0;
    _categoryTotals.forEach((cat, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${amount.toStringAsFixed(0)}',
          color: colors[idx % colors.length],
          radius: 60,
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      idx++;
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('توزيع المصاريف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _categoryTotals.entries.map((e) {
              final i = _categoryTotals.keys.toList().indexOf(e.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: colors[i % colors.length]),
                  const SizedBox(width: 4),
                  Text('${e.key}: ${e.value.toStringAsFixed(0)}'),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}