// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

/*class: A:exp,needsArgs*/
class A<T> {
  instanceMethod() => T;
}

main() {
  var a = A<int>();
  a.instanceMethod();
}
