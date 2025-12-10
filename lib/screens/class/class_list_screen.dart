import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/class_provider.dart';
import 'package:learningmanagement/screens/class/create_class_screen.dart';
import 'package:learningmanagement/screens/class/class_detail_screen.dart';
import 'package:learningmanagement/widgets/class/class_item_card.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classState = ref.watch(classProvider);
    final myClasses = classState.teachingClasses;

    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Lớp Học Của Tôi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)], 
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    ),
      body: classState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myClasses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa tạo lớp học nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateClassScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo Lớp Học Mới'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myClasses.length,
              itemBuilder: (context, index) {
                final classModel = myClasses[index];
                return ClassItemCard(
                  classModel: classModel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ClassDetailScreen(classModel: classModel),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: myClasses.isNotEmpty
      ? FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateClassScreen()),
            );
          },
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            "Tạo lớp học",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, 
    );
  }
}
