import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_repository.dart';
import '../services/storage_repository.dart';

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) => FirestoreRepository());
final storageRepositoryProvider = Provider<StorageRepository>((ref) => StorageRepository());
