import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOffersScreen extends StatelessWidget {
  final String requestId;
  final String requestDetails;

  const CustomerOffersScreen({
    super.key,
    required this.requestId,
    required this.requestDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض المقدمة لطلبك'),
        backgroundColor: Colors.blue,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.build, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تفاصيل طلبك: $requestDetails',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'عروض التجار المتاحة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // جلب العروض الخاصة برقم هذا الطلب فقط
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .where('requestId', isEqualTo: requestId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'لم يتم تقديم عروض لهذا الطلب بعد.\nيرجى الانتظار لحين مراجعة التجار لطلبك.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      );
                    }

                    final offers = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        var offerData = offers[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'السعر: ${offerData['price']} جنيه',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Chip(
                                      label: Text('عرض جديد'),
                                      backgroundColor: Colors.lightGreenAccent,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'تفاصيل العرض / الضمان: ${offerData['notes'] ?? 'لا يوجد ملاحظات إضافية'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم قبول العرض! جاري للتواصل مع التاجر...')),
                                      );
                                    },
                                    child: const Text(
                                      'قبول العرض والتواصل',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
