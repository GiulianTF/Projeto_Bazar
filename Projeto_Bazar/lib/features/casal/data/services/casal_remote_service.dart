import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/casal_model.dart';

class CasalRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CasalModel>> getCasais() async {
    final snapshot = await _firestore
        .collection('casais')
        .orderBy('nome')
        .get();

    return snapshot.docs.map((doc) => CasalModel.fromMap(doc.data())).toList();
  }

  Future<void> createCasal(CasalModel casal) async {
    await _firestore.collection('casais').doc(casal.id).set(casal.toMap());
  }

  Future<void> deleteCasal(String id) async {
    await _firestore.collection('casais').doc(id).delete();
  }
}
