// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

void main() {
  Object o = new Object();
  o || o;
//^
// [analyzer] COMPILE_TIME_ERROR.NON_BOOL_OPERAND
// [cfe] A value of type 'Object' can't be assigned to a variable of type 'bool'.
//     ^
// [analyzer] COMPILE_TIME_ERROR.NON_BOOL_OPERAND
// [cfe] A value of type 'Object' can't be assigned to a variable of type 'bool'.

  o && o;
//^
// [analyzer] COMPILE_TIME_ERROR.NON_BOOL_OPERAND
// [cfe] A value of type 'Object' can't be assigned to a variable of type 'bool'.
//     ^
// [analyzer] COMPILE_TIME_ERROR.NON_BOOL_OPERAND
// [cfe] A value of type 'Object' can't be assigned to a variable of type 'bool'.
}
