import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:aegistree/src/src.dart';

class DetailedDiseases extends ConsumerWidget {
  const DetailedDiseases(this.disease, {super.key});
  final LearnEntity disease;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(disease.disease.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: black60,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.memory(disease.disease.image),
              ),
            ),
            const Gap(32),
            Details(title: "Description", description: disease.description),
            Details(title: "Symptoms", description: disease.symptoms),
            Details(title: "Treatment", description: disease.treatment),
          ],
        ),
      ),
    );
  }
}

class Details extends ConsumerWidget {
  const Details({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InknutAntiqua(
          title,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          shadow: [Shadows().defaultShadow],
        ),
        const Gap(2),
        // Make description scrollable if it overflows
        SizedBox(
          height: 100, // Adjust the height as needed
          child: SingleChildScrollView(
            child: Koho(description),
          ),
        ),
        const Gap(16),
      ],
    );
  }
}
