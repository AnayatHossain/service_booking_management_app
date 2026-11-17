import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  bool _isLoading = true;
  List<dynamic> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    final token = await Urls.bearerToken;
    try {
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: Urls.providerServices,
        apiType: ApiType.get,
        apiHeaders: {'Authorization': token},
        enableLoading: false,
        enableApiSuccessResponseGetSnackBar: false,
        enableApiErrorResponseGetSnackBar: false,
      );
      final res = await api.call();
      if (res.isSuccess && res.data is Map && res.data['data'] is List) {
        _services = res.data['data'];
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Home Cleaning');
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Service', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Service Name', hintText: 'e.g. Premium Sofa Cleaning'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category', hintText: 'Home Cleaning, Beauty, Repair'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (\$)', hintText: '50.00'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (Minutes)', hintText: '60'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Comprehensive service details...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final cat = categoryCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              final dur = int.tryParse(durationCtrl.text.trim()) ?? 60;
              final desc = descCtrl.text.trim();

              if (name.isEmpty || price <= 0) return;

              Navigator.pop(ctx);

              final token = await Urls.bearerToken;
              final api = FlutterApiCraft(
                baseUrl: Urls.baseUrl,
                path: Urls.services,
                apiType: ApiType.post,
                apiHeaders: {'Authorization': token},
                apiBody: ApiBody.json({
                  'name': name,
                  'category': cat,
                  'price': price,
                  'duration_minutes': dur,
                  'description': desc.isNotEmpty ? desc : 'Professional quality service guarantee.',
                  'image_url': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
                  'is_featured': false,
                }),
                enableLoading: true,
                enableApiSuccessResponseGetSnackBar: true,
                enableApiErrorResponseGetSnackBar: true,
              );
              final res = await api.call();
              if (res.isSuccess) {
                _fetchServices();
              }
            },
            child: const Text('Publish Service'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Service Catalog',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryColor, size: 26),
            onPressed: _showAddServiceDialog,
            tooltip: 'Add Service',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddServiceDialog,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _fetchServices,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : _services.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No services listed yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Tap "Add Service" to publish your first service listing.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = _services[idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.strokeColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: item['image_url'] ?? '',
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 84,
                                  height: 84,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['category'] ?? 'Service',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${item['price']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryColor),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text('${item['duration_minutes']}m', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      const Spacer(),
                                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text('${item['rating'] ?? 4.8}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
