import 'package:flutter/material.dart';

class PayslipDetailPage extends StatelessWidget {
  const PayslipDetailPage({super.key, required this.payslipId});

  static const String routePrefix = '/payslip/';

  final String payslipId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payslip $payslipId'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Period', value: payslipId),
                  const _InfoRow(label: 'Base salary', value: 'Rp 3.800.000'),
                  const _InfoRow(label: 'Overtime', value: 'Rp 400.000'),
                  const _InfoRow(label: 'Deductions', value: 'Rp 0'),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Net pay',
                    value: 'Rp 4.200.000',
                    valueStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final textStyle = valueStyle ?? Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
