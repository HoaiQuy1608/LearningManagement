import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/class_provider.dart';
import 'package:learningmanagement/screens/Teacher_screens/create_class_screen.dart';
import 'package:learningmanagement/widgets/class/class_item_card.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classState = ref.watch(classProvider);
    final myClasses = classState.teachingClasses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp Học Của Tôi'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
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
                    print("Bấm vào lớp: ${classModel.className}");
                  },
                );
              },
            ),
      floatingActionButton: myClasses.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateClassScreen()),
                );
              },
            )
          : null,
    );
  }
}
