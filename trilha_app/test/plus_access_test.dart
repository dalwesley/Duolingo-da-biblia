import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/plus_access.dart';

void main() {
  test('features stay open when there is nothing to buy', () {
    expect(
      PlusAccess.featuresOpen(hasPlus: false, canPurchase: false),
      isTrue,
    );
    expect(
      PlusAccess.featuresOpen(hasPlus: false, canPurchase: true),
      isFalse,
    );
    expect(
      PlusAccess.featuresOpen(hasPlus: true, canPurchase: true),
      isTrue,
    );
  });
}
