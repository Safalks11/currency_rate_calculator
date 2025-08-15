import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/currencies.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String from = 'USD';
    final String to = 'INR';
    final TextEditingController amount = TextEditingController(text: '1');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'From'),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'currency-$from',
                            child: CircleAvatar(
                              child: Text(currencyByCode(from)?.flag ?? from.substring(0, 1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              '$from — ${currencyByCode(from)?.name ?? ''}',
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.swap_horiz)),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'To'),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'currency-$to',
                            child: CircleAvatar(
                              child: Text(currencyByCode(to)?.flag ?? to.substring(0, 1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              '$to — ${currencyByCode(to)?.name ?? ''}',
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: Text('Convert')),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.trending_up),
                label: const Text('5-Day Trend'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
