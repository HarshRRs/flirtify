import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../controllers/auth_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final List<String?> _photos = List.generate(6, (_) => null);
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'male';
  final _picker = ImagePicker();
  
  // Profile Prompts
  String? _selectedPrompt;
  final _promptAnswerController = TextEditingController();
  final List<String> _prompts = [
    "My ideal date involves...",
    "A fun fact about me...",
    "I'm looking for someone who...",
    "My favorite travel memory is...",
    "The way to my heart is through...",
  ];

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _photos[index] = base64Encode(bytes);
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutExpo,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutExpo,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: _previousStep,
            )
          : null,
        title: Text(
          'Step ${_currentStep + 1} of 4',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBioStep(),
                _buildPhotoStep(),
                _buildPromptStep(),
                _buildSummaryStep(authController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get to know you",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text(
            "Tell us the basics to start matching.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 48),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'How should people call you?',
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 24),
          
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'Only 18+ allowed',
            ),
          ).animate().fadeIn(delay: 500.ms),
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
                _nextStep();
              } else {
                Get.snackbar('Oops!', 'Please fill in your name and age.');
              }
            },
            child: const Text('Next Step'),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload your best shots",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          Text(
            "Minimum 2 photos required for a verified look.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildPhotoPlaceholder(index),
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: () {
              final count = _photos.whereType<String>().length;
              if (count >= 1) {
                _nextStep();
              } else {
                Get.snackbar('Focus!', 'Please upload at least 1 photo to continue.');
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add a Spark",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          Text(
            "Answer a prompt to help start conversations.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          DropdownButtonFormField<String>(
            value: _selectedPrompt,
            decoration: const InputDecoration(labelText: 'Select a Prompt'),
            items: _prompts.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (val) => setState(() => _selectedPrompt = val),
          ).animate().fadeIn(delay: 400.ms),
          
          if (_selectedPrompt != null) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _promptAnswerController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(),
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
          ],
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: _nextStep,
            child: const Text('Looking Good!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 100)
              .animate().scale(duration: 800.ms, curve: Curves.bounceOut),
          const SizedBox(height: 32),
          Text(
            "Ready to Spark?",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Your profile is complete. Let's find your first match!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 48),
          Obx(() => authController.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    final validPhotos = _photos.whereType<String>().toList();
                    authController.register(
                      name: _nameController.text,
                      email: Get.arguments['email'],
                      password: Get.arguments['password'],
                      age: int.parse(_ageController.text),
                      gender: _selectedGender,
                      photos: validPhotos,
                      // We should ideally update the backend to accept bio/prompts too
                    );
                  },
                  child: const Text('Start Flirting'),
                )),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Color(0xFF1E1E1E) 
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _photos[index] != null ? AppColors.primary : AppColors.grey300,
            width: 2,
          ),
        ),
        child: _photos[index] == null
            ? const Icon(Icons.add_a_photo_outlined, color: AppColors.grey400)
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  base64Decode(_photos[index]!),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
