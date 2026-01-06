import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interaction_model.dart';

class InteractionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> logInteraction(InteractionModel interaction) async {
    await _db
        .collection('users')
        .doc(interaction.userId)
        .collection('interactions')
        .add(interaction.toJson());
  }
}
