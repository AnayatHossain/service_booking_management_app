import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_api_craft/flutter_api_craft.dart';
import 'package:service_booking_management_app/core/const/app_colors.dart';
import 'package:service_booking_management_app/core/const/app_svg_icons.dart';
import 'package:service_booking_management_app/core/network_caller/endpoints.dart';
import 'package:service_booking_management_app/feature/users/normal_user/home_screen/model/service_model.dart';

class ProviderAddEditServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const ProviderAddEditServiceScreen({super.key, this.service});

  bool get isEditing => service != null;

  @override
  State<ProviderAddEditServiceScreen> createState() => _ProviderAddEditServiceScreenState();
}

class _ProviderAddEditServiceScreenState extends State<ProviderAddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descController;
  late TextEditingController _newIncludeController;

  late String _selectedCategory;
  late String _selectedImageUrl;
  late List<String> _includes;
  late List<String> _availableDays;
  late List<String> _timeSlots;
  late bool _isFeatured;
  bool _isSaving = false;

  static const List<String> _categories = [
    'Home Cleaning',
    'Spa & Wellness',
    'Appliance Repair',
    'Beauty & Salon',
    'Automotive',
    'Tech & Electronics',
    'Plumbing & Bath',
    'Painting & Decor',
  ];

  static const List<int> _durationPresets = [30, 45, 60, 90, 120, 180];

  static const List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _allTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  static const Map<String, String> _presetImages = {
    'Home Cleaning': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
    'Spa & Wellness': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80',
    'Appliance Repair': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
    'Beauty & Salon': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
    'Automotive': 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&w=800&q=80',
    'Tech & Electronics': 'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?auto=format&fit=crop&w=800&q=80',
    'Plumbing & Bath': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&w=800&q=80',
    'Painting & Decor': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
  };

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(
        text: s != null ? (s.price.truncateToDouble() == s.price ? s.price.toInt().toString() : s.price.toString()) : '');
    _durationController = TextEditingController(text: s?.durationMinutes.toString() ?? '60');
    _descController = TextEditingController(text: s?.description ?? '');
    _newIncludeController = TextEditingController();

    _selectedCategory = s?.category ?? 'Home Cleaning';
    _selectedImageUrl = s?.imageUrl ?? _presetImages[_selectedCategory] ?? _presetImages['Home Cleaning']!;
    _isFeatured = s?.isFeatured ?? false;

    _includes = s != null && s.includes.isNotEmpty
        ? List<String>.from(s.includes)
        : [
            'Vetted & background checked professionals',
            'Full satisfaction guarantee with free rework',
            '24/7 dedicated support & easy cancellation',
          ];

    _availableDays = s != null && s.availableDays.isNotEmpty
        ? List<String>.from(s.availableDays)
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    _timeSlots = s != null && s.timeSlots.isNotEmpty
        ? List<String>.from(s.timeSlots)
        : ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descController.dispose();
    _newIncludeController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Service Cover Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a verified high-resolution photograph for this service.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetImages.entries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final entry = _presetImages.entries.elementAt(idx);
                    final isSel = _selectedImageUrl == entry.value;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedImageUrl = entry.value;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppColors.primaryColor : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: entry.value,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSel)
                                const Center(
                                  child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final duration = int.tryParse(_durationController.text.trim()) ?? 60;
    final desc = _descController.text.trim();

    if (price <= 0) {
      Get.snackbar('Invalid Price', 'Please enter a valid price greater than \$0');
      return;
    }

    setState(() => _isSaving = true);
    final token = await Urls.bearerToken;

    final payload = {
      'name': name,
      'category': _selectedCategory,
      'price': price,
      'duration_minutes': duration,
      'description': desc.isNotEmpty ? desc : 'Professional $name service with guaranteed satisfaction.',
      'image_url': _selectedImageUrl,
      'is_featured': _isFeatured,
      'includes': _includes,
      'available_days': _availableDays,
      'time_slots': _timeSlots,
    };

    try {
      final isEdit = widget.isEditing;
      final api = FlutterApiCraft(
        baseUrl: Urls.baseUrl,
        path: isEdit ? Urls.providerUpdateService(widget.service!.id) : Urls.services,
        apiType: isEdit ? ApiType.put : ApiType.post,
        apiHeaders: {'Authorization': token},
        apiBody: ApiBody.json(payload),
        enableLoading: true,
        enableApiSuccessResponseGetSnackBar: true,
        enableApiErrorResponseGetSnackBar: true,
      );

      final res = await api.call();

      if (res.isSuccess) {
        final Map<String, dynamic> doc = (res.data is Map && res.data['data'] is Map)
            ? res.data['data']
            : payload;
        if (!doc.containsKey('id') && widget.service != null) {
          doc['id'] = widget.service!.id;
        }
        final updatedService = ServiceModel.fromJson(doc);
        Get.back(result: updatedService);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppSvgIcons.backArrow,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isEditing ? 'Edit Service' : 'Add New Service',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image Preview Card
              _buildCoverImageCard(),
              const SizedBox(height: 20),

              // Basic Info Section
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                children: [
                  _buildLabel('Service Title *'),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g. Full House Deep Cleaning'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter service title' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Category *'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                            color: isSel ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSel ? AppColors.primaryColor : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              if (!widget.isEditing) {
                                _selectedImageUrl = _presetImages[cat] ?? _selectedImageUrl;
                              }
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hot / Featured Promotion Section
              _buildSectionCard(
                title: 'Featured Promotion',
                icon: Icons.local_fire_department_rounded,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isFeatured ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isFeatured ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isFeatured ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                'Featured Service',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (_isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'HOT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isFeatured,
                          activeColor: const Color(0xFFDC2626),
                          activeTrackColor: const Color(0xFFFECDD3),
                          onChanged: (val) {
                            setState(() {
                              _isFeatured = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hot / Featured Promotion Section
              _buildSectionCard(
                title: 'Featured Promotion',
                icon: Icons.local_fire_department_rounded,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isFeatured ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isFeatured ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _isFeatured ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                'Featured Service',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (_isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'HOT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isFeatured,
                          activeColor: const Color(0xFFDC2626),
                          activeTrackColor: const Color(0xFFFECDD3),
                          onChanged: (val) {
                            setState(() {
                              _isFeatured = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pricing & Duration Section
              _buildSectionCard(
                title: 'Pricing & Duration',
                icon: Icons.monetization_on_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price (\$) *'),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('0.00', prefixText: '\$ '),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter price' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Duration (Mins) *'),
                            TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('60', suffixText: ' mins'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter duration' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _durationPresets.map((dur) {
                      final isSel = _durationController.text == dur.toString();
                      return ActionChip(
                        label: Text('${dur}m', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.primaryColor)),
                        backgroundColor: isSel ? AppColors.primaryColor : AppColors.primaryLight,
                        onPressed: () {
                          setState(() => _durationController.text = dur.toString());
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description Section
              _buildSectionCard(
                title: 'Description',
                icon: Icons.description_outlined,
                children: [
                  _buildLabel('Service Overview'),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: _inputDecoration('Write a comprehensive and attractive description of this service...'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // What's Included Section
              _buildSectionCard(
                title: "What's Included",
                icon: Icons.checklist_rounded,
                children: [
                  _buildLabel('Key Highlights & Inclusions'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newIncludeController,
                          decoration: _inputDecoration('Add an inclusion (e.g. Free cleanup)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          final text = _newIncludeController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              _includes.add(text);
                              _newIncludeController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _includes.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entry.value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              ),
                              InkWell(
                                onTap: () => setState(() => _includes.removeAt(entry.key)),
                                child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Available Days Section
              _buildSectionCard(
                title: 'Available Service Days',
                icon: Icons.calendar_today_rounded,
                children: [
                  _buildLabel('Select operational days'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allDays.map((day) {
                      final isSel = _availableDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSel,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? AppColors.primaryColor : AppColors.textSecondary,
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _availableDays.add(day);
                            } else {
                              _availableDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Available Time Slots Section
              _buildSectionCard(
                title: 'Available Time Slots',
                icon: Icons.access_time_rounded,
                children: [
                  _buildLabel('Select bookable slots'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allTimeSlots.map((slot) {
                      final isSel = _timeSlots.contains(slot);
                      return FilterChip(
                        label: Text(slot),
                        selected: isSel,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? AppColors.primaryColor : AppColors.textSecondary,
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _timeSlots.add(slot);
                            } else {
                              _timeSlots.remove(slot);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      widget.isEditing ? 'Save Changes' : 'Publish Service',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImageCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _selectedImageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.primaryLight),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.broken_image_rounded, size: 40, color: Color(0xFF94A3B8)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: _showImagePickerSheet,
                icon: SvgPicture.asset(
                  AppSvgIcons.addImage,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                ),
                label: const Text(
                  'Change Cover Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'HD Cover Image',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText, String? suffixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      suffixText: suffixText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }
}
