import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseTile({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'ar', symbol: 'ج.م', decimalDigits: 2);
    final df = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            expense.category.characters.first,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          fmt.format(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('${expense.category} • ${expense.note}\n${df.format(expense.date)}'),
        isThreeLine: expense.note.isNotEmpty,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}