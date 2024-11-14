import 'dart:io';

import 'package:flutter/services.dart';

import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:aegistree/src/src.dart';

part 'diseases_provider.g.dart';

@Riverpod(keepAlive: true)
class Disease extends _$Disease {
  late final UserEntity _user;

  @override
  List<DiseaseEntity> build() {
    _user = ref.read(usersProvider)!;

    syncDiseases();

    final localDiseases = isar.diseaseModels.where().findAll();
    return localDiseases
        .map((model) => DiseaseEntity.fromModel(model))
        .toList();
  }

  Future<void> syncDiseases() async {
    try {
      final lastSync = isar.lastSyncModels
              .where()
              .typeEqualTo('disease')
              .findFirst() ??
          LastSyncModel()
        ..type = 'disease'
        ..timestamp = DateTime.fromMicrosecondsSinceEpoch(0);

      final localChanges = isar.diseaseModels
          .where()
          .createdAtGreaterThan(lastSync.timestamp)
          .findAll();

      for (final disease in localChanges) {
        await db.collection('diseases').doc(disease.uid).set(disease.toJson);

        final diseaseRef =
            storage.child("diseases/${_user.id}/${disease.id}.png");

        await diseaseRef.putFile(
          File.fromRawPath(Uint8List.fromList(disease.image)),
        );
      }

      final remoteChanges = await db
          .collection('diseases')
          .where('createdBy', isEqualTo: _user.id)
          .where('createdAt',
              isGreaterThan: lastSync.timestamp.toIso8601String())
          .get();

      await isar.writeAsync((isar) async {
        for (final doc in remoteChanges.docs) {
          final data = doc.data();

          final diseaseRef =
              storage.child("diseases/${_user.id}/${doc.id}.png");

          final image = await diseaseRef.getData();

          DiseaseModel disease = DiseaseEntity(
            id: doc.id,
            name: data['name'],
            description: data['description'],
            image: image!,
            createdAt: data['createdAt'],
            createdBy: data['createdBy'],
            imagePath: '',
          ).toModel
            ..id = isar.diseaseModels.autoIncrement();

          isar.diseaseModels.put(disease);
        }

        lastSync.timestamp = DateTime.now();
        isar.lastSyncModels.put(lastSync);
      });

      // Update state with latest data
      final updatedDiseases = isar.diseaseModels.where().findAll();
      state = updatedDiseases
          .map((model) => DiseaseEntity.fromModel(model))
          .toList();
    } catch (error) {
      // On error, just load from local database
      final localDiseases = isar.diseaseModels.where().findAll();
      state =
          localDiseases.map((model) => DiseaseEntity.fromModel(model)).toList();
    }
  }

  DiseaseEntity addDisease(String name, String description, Uint8List bytes) {
    final index = checkDisease(name);
    if (index == -1) {
      final disease = DiseaseEntity(
        id: uuid.v4(),
        name: name,
        description: description,
        image: bytes,
        createdBy: _user.id,
        createdAt: DateTime.now(),
        imagePath: '',
      );

      final model = disease.toModel..id = isar.diseaseModels.autoIncrement();

      isar.writeAsync((isar) {
        isar.diseaseModels.put(model);
      });

      try {
        db.collection('diseases').doc(disease.id).set(disease.toJson);
      } catch (error) {
        //
      }

      syncDiseases();

      state = [...state, disease];
      return disease;
    }

    return state[index];
  }

  int checkDisease(String name) {
    return state.indexWhere((value) => value.name == name);
  }

  DiseaseEntity findById(String id) {
    return state.firstWhere((value) => value.id == id);
  }
}
