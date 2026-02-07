import 'package:flutter/material.dart';

import '../ui/hris_theme.dart';
import 'payslip_detail_page.dart';

class PayslipPage extends StatelessWidget {
  const PayslipPage({super.key});

  static const String routeName = '/payslip';

  @override
  Widget build(BuildContext context) {
    final payslips = [
      {'id': '2024-07', 'period': 'July 2024', 'amount': 'Rp 4.200.000'},
      {'id': '2024-06', 'period': 'June 2024', 'amount': 'Rp 4.050.000'},
      {'id': '2024-05', 'period': 'May 2024', 'amount': 'Rp 4.000.000'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: hrisHeaderGradient(),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your payslips',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review payroll summaries and download slips.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...payslips.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: hrisGray200,
                  child: const Icon(Icons.receipt_long_outlined, color: hrisBlue),
                ),
                title: Text(item['period']!),
                subtitle: Text('Net pay ${item['amount']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '${PayslipDetailPage.routePrefix}${item['id']}',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
