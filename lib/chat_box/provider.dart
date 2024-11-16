import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_repository.dart';

final chatProvider = Provider(
      (ref) => ChatRepository(),
);

