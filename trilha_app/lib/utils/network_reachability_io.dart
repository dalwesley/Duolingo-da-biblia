import 'dart:io';

Future<bool> hasInternet({
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    final result = await InternetAddress.lookup(
      'firestore.googleapis.com',
    ).timeout(timeout);
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
