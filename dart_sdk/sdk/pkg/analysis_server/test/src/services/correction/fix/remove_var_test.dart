// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'fix_processor.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RemoveVarTest);
  });
}

@reflectiveTest
class RemoveVarTest extends FixProcessorTest {
  @override
  FixKind get kind => DartFixKind.REMOVE_VAR;

  Future<void> test_function() async {
    await resolveTestCode('''
var f() {}
''');
    await assertHasFix('''
f() {}
''');
  }

  Future<void> test_pattern_declaration() async {
    await resolveTestCode('''
f() {
  var [var x] = [1];
  print(x);
}
''');
    await assertHasFix('''
f() {
  var [x] = [1];
  print(x);
}
''');
  }

  @FailingTest(
      issue: "https://github.com/dart-lang/sdk/issues/49960",
      reason: "Fix once error is reported")
  Future<void> test_pattern_in_assignment() async {
    await resolveTestCode('''
f() {
  var a = 1;
  var b = 2;
  (var a, int b) = (3, 4);
}
''');
    await assertHasFix('''
f() {
  var a = 1;
  var b = 2;
  (a, int b) = (3, 4);
}
''');
  }

  Future<void> test_setter() async {
    await resolveTestCode('''
class C {
  var set s(int i) {}
}
''');
    await assertHasFix('''
class C {
  set s(int i) {}
}
''');
  }

  Future<void> test_typedef() async {
    await resolveTestCode('''
typedef F = var Function();
''');
    await assertHasFix('''
typedef F = Function();
''', errorFilter: (error) {
      return error.errorCode == ParserErrorCode.VAR_RETURN_TYPE;
    });
  }
}
