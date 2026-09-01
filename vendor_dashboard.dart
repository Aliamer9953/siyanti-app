import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  // دالة إظهار نافذة تقديم العرض
  void _showOfferDialog(BuildContext context, String requestId) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تقديم عرض سعر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر (بالجنيه)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل العرض (مدة الضمان / حالة القطعة)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (priceController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('offers').add({
                    'requestId': requestId,
                    'price': priceController.text.trim(),
                    'notes': noteController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال العرض بنجاح للعميل!')),
                    );
                  }
                }
              },
              child: const Text('إرسال العرض'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة طلبات قطع الغيار'),
        backgroundColor: Colors.indigo,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('spare_parts_requests')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد طلبات معروضة حالياً'));
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var doc = requests[index];
                var data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      data['details'] ?? 'بدون تفاصيل',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('الحالة المطلوبة: ${data['condition'] ?? 'غير محدد'}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      onPressed: () => _showOfferDialog(context, doc.id),
                      child: const Text('تقديم عرض', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
