import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'phone_auth_screen.dart';
import 'vendor_dashboard.dart';
import 'customer_offers_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SiyantiApp());
}

class SiyantiApp extends StatelessWidget {
  const SiyantiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صيانتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PhoneAuthScreen(),
    );
  }
}

class RequestSparePartScreen extends StatefulWidget {
  const RequestSparePartScreen({super.key});

  @override
  State<RequestSparePartScreen> createState() => _RequestSparePartScreenState();
}

class _RequestSparePartScreenState extends State<RequestSparePartScreen> {
  String partCondition = 'جديد';
  final TextEditingController detailsController = TextEditingController();
  bool isLoading = false;
  String? lastRequestId; // لحفظ رقم آخر طلب تم إرساله

  Future<void> submitRequest() async {
    if (detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء كتابة تفاصيل قطعة الغيار')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var docRef = await FirebaseFirestore.instance.collection('spare_parts_requests').add({
        'details': detailsController.text.trim(),
        'condition': partCondition,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          lastRequestId = docRef.id;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلبك بنجاح للتجار!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإرسال: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب قطعة غيار - صيانتي'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'لوحة التاجر',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VendorDashboardScreen()),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تفاصيل قطعة الغيار المطلوبة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'اكتب ماركة السيارة/الجهاز والموديل واسم القطعة...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'حالة القطعة المطلوبة:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('جديد'),
                        value: 'جديد',
                        groupValue: partCondition,
                        onChanged: (val) => setState(() => partCondition = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('استيراد'),
                        value: 'استيراد',
                        groupValue: partCondition,
                        onChanged: (val) => setState(() => partCondition = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'إرسال الطلب للتجار',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 15),
                // زر عرض العروض الخاصة بالطلب
                if (lastRequestId != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    icon: const Icon(Icons.local_offer, color: Colors.blue),
                    label: const Text(
                      'عرض العروض المقدمة لطلبك الأخير',
                      style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerOffersScreen(
                            requestId: lastRequestId!,
                            requestDetails: detailsController.text,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
