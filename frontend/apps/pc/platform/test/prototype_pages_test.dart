import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/prototype_registry.dart';

void main() {
  testWidgets('all 管理后台 prototype pages render without exceptions',
      (tester) async {
    expect(prototypePages.length, 75, reason: '75 pages expected');
    for (final entry in prototypePages) {
      final key = ValueKey('page-${entry.id}');
      tester.view.physicalSize = Size(entry.width, entry.height);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: KeyedSubtree(
            key: key,
            child: Builder(builder: entry.builder),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byKey(key)),
        Size(entry.width, entry.height),
        reason: '${entry.title} (${entry.id}) root size',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: '${entry.title} (${entry.id}) should render',
      );
      tester.view.reset();
    }
  });

  test('registry has unique ids and page lookup works', () {
    expect(prototypePageById.length, prototypePages.length);
    for (final e in prototypePages) {
      expect(prototypePageById[e.id], same(e));
    }
  });
}
