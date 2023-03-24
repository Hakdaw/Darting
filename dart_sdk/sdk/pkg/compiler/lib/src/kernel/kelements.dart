// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Entity model for elements derived from Kernel IR.

import 'package:kernel/ast.dart' as ir;
import '../elements/entities.dart';
import '../elements/indexed.dart';
import '../elements/names.dart';
import '../elements/types.dart';

const String kElementPrefix = 'k:';

class KLibrary extends IndexedLibrary {
  @override
  final String name;
  @override
  final Uri canonicalUri;
  @override
  final bool isNonNullableByDefault;

  KLibrary(this.name, this.canonicalUri, this.isNonNullableByDefault);

  @override
  String toString() => '${kElementPrefix}library($name)';
}

class KClass extends IndexedClass {
  @override
  final KLibrary library;

  @override
  final String name;
  @override
  final bool isAbstract;

  KClass(this.library, this.name, {required this.isAbstract});

  @override
  bool get isClosure => false;

  @override
  String toString() => '${kElementPrefix}class($name)';
}

abstract class KMember extends IndexedMember {
  @override
  final KLibrary library;
  @override
  final KClass? enclosingClass;
  final Name _name;
  final bool _isStatic;

  KMember(this.library, this.enclosingClass, this._name,
      {bool isStatic = false})
      : _isStatic = isStatic;

  @override
  String get name => _name.text;

  @override
  Name get memberName => _name;

  @override
  bool get isAssignable => false;

  @override
  bool get isConst => false;

  @override
  bool get isAbstract => false;

  @override
  bool get isSetter => false;

  @override
  bool get isGetter => false;

  @override
  bool get isFunction => false;

  @override
  bool get isInstanceMember => enclosingClass != null && !_isStatic;

  @override
  bool get isStatic => enclosingClass != null && _isStatic;

  @override
  bool get isTopLevel => enclosingClass == null;

  String get _kind;

  @override
  String toString() => '${kElementPrefix}$_kind'
      '(${enclosingClass != null ? '${enclosingClass!.name}.' : ''}$name)';
}

abstract class KFunction extends KMember
    implements FunctionEntity, IndexedFunction {
  @override
  final ParameterStructure parameterStructure;
  @override
  final bool isExternal;
  @override
  final AsyncMarker asyncMarker;

  KFunction(super.library, super.enclosingClass, super.name,
      this.parameterStructure, this.asyncMarker,
      {super.isStatic, this.isExternal = false});
}

abstract class KConstructor extends KFunction
    implements ConstructorEntity, IndexedConstructor {
  @override
  final bool isConst;
  @override
  KClass enclosingClass;

  KConstructor(
      this.enclosingClass, Name name, ParameterStructure parameterStructure,
      {required bool isExternal, required this.isConst})
      : super(enclosingClass.library, enclosingClass, name, parameterStructure,
            AsyncMarker.SYNC,
            isExternal: isExternal);

  @override
  bool get isInstanceMember => false;

  @override
  bool get isStatic => false;

  @override
  bool get isTopLevel => false;

  @override
  bool get isFromEnvironmentConstructor => false;

  @override
  String get _kind => 'constructor';
}

class KGenerativeConstructor extends KConstructor {
  KGenerativeConstructor(
      super.enclosingClass, super.name, super.parameterStructure,
      {required super.isExternal, required super.isConst});

  @override
  bool get isFactoryConstructor => false;

  @override
  bool get isGenerativeConstructor => true;
}

class KFactoryConstructor extends KConstructor {
  @override
  final bool isFromEnvironmentConstructor;

  KFactoryConstructor(
      super.enclosingClass, super.name, super.parameterStructure,
      {required super.isExternal,
      required super.isConst,
      required this.isFromEnvironmentConstructor});

  @override
  bool get isFactoryConstructor => true;

  @override
  bool get isGenerativeConstructor => false;
}

class KMethod extends KFunction {
  @override
  final bool isAbstract;

  KMethod(super.library, super.enclosingClass, super.name,
      super.parameterStructure, super.asyncMarker,
      {required super.isStatic,
      required super.isExternal,
      required this.isAbstract});

  @override
  bool get isFunction => true;

  @override
  String get _kind => 'method';
}

class KGetter extends KFunction {
  @override
  final bool isAbstract;

  KGetter(KLibrary library, KClass? enclosingClass, Name name,
      AsyncMarker asyncMarker,
      {required bool isStatic,
      required bool isExternal,
      required this.isAbstract})
      : super(library, enclosingClass, name, ParameterStructure.getter,
            asyncMarker,
            isStatic: isStatic, isExternal: isExternal);

  @override
  bool get isGetter => true;

  @override
  String get _kind => 'getter';
}

class KSetter extends KFunction {
  @override
  final bool isAbstract;

  KSetter(KLibrary library, KClass? enclosingClass, Name name,
      {required bool isStatic,
      required bool isExternal,
      required this.isAbstract})
      : super(library, enclosingClass, name, ParameterStructure.setter,
            AsyncMarker.SYNC,
            isStatic: isStatic, isExternal: isExternal);

  @override
  bool get isAssignable => true;

  @override
  bool get isSetter => true;

  @override
  String get _kind => 'setter';
}

class KField extends KMember implements FieldEntity, IndexedField {
  @override
  final bool isAssignable;
  @override
  final bool isConst;

  KField(super.library, super.enclosingClass, super.name,
      {required super.isStatic,
      required this.isAssignable,
      required this.isConst});

  @override
  String get _kind => 'field';
}

class KTypeVariable extends IndexedTypeVariable {
  @override
  final Entity typeDeclaration;
  @override
  final String name;
  @override
  final int index;

  KTypeVariable(this.typeDeclaration, this.name, this.index);

  @override
  String toString() =>
      '${kElementPrefix}type_variable(${typeDeclaration.name}.$name)';
}

class KLocalFunction implements Local {
  @override
  final String? name;
  final MemberEntity memberContext;
  final Entity executableContext;
  final ir.LocalFunction node;
  late final FunctionType functionType;

  KLocalFunction(
      this.name, this.memberContext, this.executableContext, this.node);

  @override
  String toString() => '${kElementPrefix}local_function'
      '(${memberContext.name}.${name ?? '<anonymous>'})';
}

class KLocalTypeVariable implements TypeVariableEntity {
  @override
  final KLocalFunction typeDeclaration;
  @override
  final String name;
  @override
  final int index;
  late final DartType bound;
  late final DartType defaultType;

  KLocalTypeVariable(this.typeDeclaration, this.name, this.index);

  @override
  String toString() =>
      '${kElementPrefix}local_type_variable(${typeDeclaration.name}.$name)';
}
