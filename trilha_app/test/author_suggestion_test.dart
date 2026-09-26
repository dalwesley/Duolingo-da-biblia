import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/author_suggestion_service.dart';

void main() {
  test('name trims, collapses spaces and needs two letters', () {
    expect(AuthorSuggestionService.normalizeName('  Ana   Costa  '), 'Ana Costa');
    expect(AuthorSuggestionService.isValidName('A'), isFalse);
    expect(AuthorSuggestionService.isValidName('Ana'), isTrue);
    expect(
      AuthorSuggestionService.normalizeName('a' * 120).length,
      AuthorSuggestionService.maxName,
    );
  });

  test('phone is optional, and a filled one needs DDD', () {
    expect(AuthorSuggestionService.isValidPhone(''), isTrue);
    expect(AuthorSuggestionService.isValidPhone('(11) 98888-7777'), isTrue);
    expect(AuthorSuggestionService.phoneDigits('(11) 98888-7777'), '11988887777');
    expect(AuthorSuggestionService.isValidPhone('123'), isFalse);
    expect(AuthorSuggestionService.isValidPhone('abc'), isFalse);
  });

  test('email is optional and must look like an address when filled', () {
    expect(AuthorSuggestionService.isValidEmail(''), isTrue);
    expect(AuthorSuggestionService.isValidEmail('Ana@STWAY.com'), isTrue);
    expect(
      AuthorSuggestionService.normalizeEmail('Ana@STWAY.com'),
      'ana@stway.com',
    );
    expect(AuthorSuggestionService.isValidEmail('ana'), isFalse);
    expect(AuthorSuggestionService.isValidEmail('ana@stway'), isFalse);
  });

  test('instagram accepts a handle, an @ and a profile url', () {
    expect(AuthorSuggestionService.normalizeInstagram('@Autor.Biblia'), 'autor.biblia');
    expect(
      AuthorSuggestionService.normalizeInstagram(
        'https://instagram.com/autor.biblia/',
      ),
      'autor.biblia',
    );
    expect(AuthorSuggestionService.isValidInstagram(''), isTrue);
    expect(AuthorSuggestionService.isValidInstagram('@autor'), isTrue);
    expect(AuthorSuggestionService.isValidInstagram('não vale'), isFalse);
  });

  test('ready requires a name and at least one contact', () {
    expect(
      AuthorSuggestionService.isReady(
        name: 'Ana',
        phone: '',
        email: '',
        instagram: '',
      ),
      isFalse,
    );
    expect(
      AuthorSuggestionService.isReady(
        name: 'Ana',
        phone: '',
        email: 'ana@stway.com',
        instagram: '',
      ),
      isTrue,
    );
    expect(
      AuthorSuggestionService.isReady(
        name: 'A',
        phone: '11988887777',
        email: '',
        instagram: '',
      ),
      isFalse,
    );
    expect(
      AuthorSuggestionService.isReady(
        name: 'Ana',
        phone: '123',
        email: '',
        instagram: '@autor',
      ),
      isFalse,
    );
  });
}
