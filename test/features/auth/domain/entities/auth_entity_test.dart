import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = AuthEntity(
    authId: 'u1',
    fName: 'John',
    lName: 'Doe',
    email: 'john@example.com',
    username: 'john_doe',
    profilePicture: 'p.jpg',
    coverPicture: 'c.jpg',
    bio: 'hello',
  );

  group('AuthEntity', () {
    test('constructs with expected values', () {
      expect(base.authId, 'u1');
      expect(base.fName, 'John');
      expect(base.username, 'john_doe');
    });

    test('copyWith updates selected fields', () {
      final updated = base.copyWith(fName: 'Jane', username: 'jane_doe');
      expect(updated.fName, 'Jane');
      expect(updated.username, 'jane_doe');
      expect(updated.lName, 'Doe');
    });

    test('copyWith keeps old values when no params given', () {
      final same = base.copyWith();
      expect(same.authId, base.authId);
      expect(same.email, base.email);
      expect(same.bio, base.bio);
    });

    test('copyWith can update nullable fields', () {
      final updated = base.copyWith(profilePicture: 'new.jpg', bio: 'new bio');
      expect(updated.profilePicture, 'new.jpg');
      expect(updated.bio, 'new bio');
    });
  });
}
