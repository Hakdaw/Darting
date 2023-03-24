// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Foo {
  dynamic x;
  dynamic y;

  Foo.foo1(dynamic a, dynamic b)
      : x = a as int,
        y = b as int?;

  Foo.foo2(dynamic a, dynamic b)
      : x = a is int,
        y = b is int?;

  Foo.foo3(dynamic a, dynamic b)
      : x = a as int?,
        y = b as int;

  Foo.foo4(dynamic a, dynamic b)
      : x = a is int?,
        y = b is int;

  Foo.bar1(dynamic a, dynamic b)
      : x = a as int,
        y = b as int? {}

  Foo.bar2(dynamic a, dynamic b)
      : x = a is int,
        y = b is int? {}

  Foo.bar3(dynamic a, dynamic b)
      : x = a as int?,
        y = b as int {}

  Foo.bar4(dynamic a, dynamic b)
      : x = a is int?,
        y = b is int {}
}
