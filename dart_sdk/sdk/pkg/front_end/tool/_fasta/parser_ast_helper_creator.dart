// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:_fe_analyzer_shared/src/parser/parser.dart';
import 'package:_fe_analyzer_shared/src/scanner/utf8_bytes_scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:dart_style/dart_style.dart' show DartFormatter;
import '../../test/utils/io_utils.dart' show computeRepoDirUri;

void main(List<String> args) {
  final Uri repoDir = computeRepoDirUri();
  String generated = generateAstHelper(repoDir);
  new File.fromUri(computeAstHelperUri(repoDir))
      .writeAsStringSync(generated, flush: true);
}

Uri computeAstHelperUri(Uri repoDir) {
  return repoDir
      .resolve("pkg/front_end/lib/src/fasta/util/parser_ast_helper.dart");
}

String generateAstHelper(Uri repoDir) {
  StringBuffer out = new StringBuffer();
  File f = new File.fromUri(
      repoDir.resolve("pkg/_fe_analyzer_shared/lib/src/parser/listener.dart"));
  List<int> rawBytes = f.readAsBytesSync();

  Uint8List bytes = new Uint8List(rawBytes.length + 1);
  bytes.setRange(0, rawBytes.length, rawBytes);

  Utf8BytesScanner scanner = new Utf8BytesScanner(bytes, includeComments: true);
  Token firstToken = scanner.tokenize();

  out.write(r"""
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/experiments/flags.dart';
import 'package:_fe_analyzer_shared/src/parser/assert.dart';
import 'package:_fe_analyzer_shared/src/parser/block_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/constructor_reference_context.dart';
import 'package:_fe_analyzer_shared/src/parser/declaration_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/formal_parameter_kind.dart';
import 'package:_fe_analyzer_shared/src/parser/identifier_context.dart';
import 'package:_fe_analyzer_shared/src/parser/listener.dart';
import 'package:_fe_analyzer_shared/src/parser/member_kind.dart';
import 'package:_fe_analyzer_shared/src/scanner/error_token.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:front_end/src/fasta/messages.dart';

// ignore_for_file: lines_longer_than_80_chars

// THIS FILE IS AUTO GENERATED BY
// 'tool/_fasta/parser_ast_helper_creator.dart'
// Run this command to update it:
// 'dart pkg/front_end/tool/_fasta/parser_ast_helper_creator.dart'

abstract class ParserAstNode {
  final String what;
  final ParserAstType type;
  Map<String, Object?> get deprecatedArguments;
  List<ParserAstNode>? children;
  ParserAstNode? parent;

  ParserAstNode(this.what, this.type);

  // TODO(jensj): Compare two ASTs.
}

enum ParserAstType { BEGIN, END, HANDLE }

abstract class AbstractParserAstListener implements Listener {
  List<ParserAstNode> data = [];

  void seen(ParserAstNode entry);

""");

  ParserCreatorListener listener = new ParserCreatorListener(out);
  ClassMemberParser parser = new ClassMemberParser(listener);
  parser.parseUnit(firstToken);

  out.writeln("}");
  out.writeln("");
  out.write(listener.newClasses.toString());

  return new DartFormatter().format("$out");
}

class ParserCreatorListener extends Listener {
  final StringSink out;
  bool insideListenerClass = false;
  String? currentMethodName;
  String? latestSeenParameterTypeToken;
  String? latestSeenParameterTypeTokenQuestion;
  final List<Parameter> parameters = <Parameter>[];
  Token? formalParametersEnd;
  final StringBuffer newClasses = new StringBuffer();

  ParserCreatorListener(this.out);

  @override
  void beginClassDeclaration(
      Token begin,
      Token? abstractToken,
      Token? macroToken,
      Token? inlineToken,
      Token? sealedToken,
      Token? baseToken,
      Token? interfaceToken,
      Token? finalToken,
      Token? augmentToken,
      Token? mixinToken,
      Token name) {
    if (name.lexeme == "Listener") insideListenerClass = true;
  }

  @override
  void endClassDeclaration(Token beginToken, Token endToken) {
    insideListenerClass = false;
  }

  @override
  void beginMethod(
      DeclarationKind declarationKind,
      Token? augmentToken,
      Token? externalToken,
      Token? staticToken,
      Token? covariantToken,
      Token? varFinalOrConst,
      Token? getOrSet,
      Token name) {
    currentMethodName = name.lexeme;
  }

  @override
  void endFormalParameters(
      int count, Token beginToken, Token endToken, MemberKind kind) {
    formalParametersEnd = endToken;
  }

  @override
  void endClassMethod(Token? getOrSet, Token beginToken, Token beginParam,
      Token? beginInitializers, Token endToken) {
    void end() {
      parameters.clear();
      currentMethodName = null;
      formalParametersEnd = null;
    }

    if (insideListenerClass &&
        (currentMethodName!.startsWith("begin") ||
            currentMethodName!.startsWith("end") ||
            currentMethodName!.startsWith("handle"))) {
      StringBuffer sb = new StringBuffer();
      sb.writeln("  @override");
      sb.write("  ");
      Token token = beginToken;
      Token? latestToken;
      if (formalParametersEnd == null) {
        // getter, so just copy through the getter name.
        formalParametersEnd = getOrSet!.next;
      }
      while (true) {
        if (latestToken != null && latestToken.charEnd < token.charOffset) {
          sb.write(" ");
        }
        sb.write(token.lexeme);
        if (latestToken == formalParametersEnd) break;
        if (token == endToken) {
          throw token.runtimeType;
        }
        latestToken = token;
        token = token.next!;
      }

      if (token is SimpleToken && token.type == TokenType.FUNCTION) {
        return end();
      } else {
        sb.write("\n    ");
        String typeString;
        String typeStringCamel;
        String name;
        if (currentMethodName!.startsWith("begin")) {
          typeString = "BEGIN";
          typeStringCamel = "Begin";
          name = currentMethodName!.substring("begin".length);
        } else if (currentMethodName!.startsWith("end")) {
          typeString = "END";
          typeStringCamel = "End";
          name = currentMethodName!.substring("end".length);
        } else if (currentMethodName!.startsWith("handle")) {
          typeString = "HANDLE";
          typeStringCamel = "Handle";
          name = currentMethodName!.substring("handle".length);
        } else {
          throw "Unexpected.";
        }

        String className = "${name}${typeStringCamel}";
        sb.write("$className data = new $className(");
        sb.write("ParserAstType.");
        sb.write(typeString);
        for (int i = 0; i < parameters.length; i++) {
          Parameter param = parameters[i];
          sb.write(', ');
          sb.write(param.name);
          sb.write(': ');
          sb.write(param.name);
        }

        sb.write(");");
        sb.write("\n    ");
        sb.write("seen(data);");
        sb.write("\n  ");

        newClasses.write("class ${name}${typeStringCamel} "
            "extends ParserAstNode {\n");

        for (int i = 0; i < parameters.length; i++) {
          Parameter param = parameters[i];
          newClasses.write("  final ");
          newClasses.write(param.type);
          newClasses.write(param.hasQuestion ? '?' : '');
          newClasses.write(' ');
          newClasses.write(param.name);
          newClasses.write(';\n');
        }
        newClasses.write('\n');
        newClasses.write("  ${name}${typeStringCamel}"
            "(ParserAstType type");
        String separator = ", {";
        for (int i = 0; i < parameters.length; i++) {
          Parameter param = parameters[i];
          newClasses.write(separator);
          if (!param.hasQuestion) {
            newClasses.write('required ');
          }
          newClasses.write('this.');
          newClasses.write(param.name);
          separator = ", ";
        }
        if (parameters.isNotEmpty) {
          newClasses.write('}');
        }
        newClasses.write(') : super("$name", type);\n\n');
        newClasses.writeln("@override");
        newClasses.write("Map<String, Object?> get deprecatedArguments => {");
        for (int i = 0; i < parameters.length; i++) {
          Parameter param = parameters[i];
          newClasses.write('"');
          newClasses.write(param.name);
          newClasses.write('": ');
          newClasses.write(param.name);
          newClasses.write(',');
        }
        newClasses.write("};\n");
        newClasses.write("}\n");
      }

      sb.write("}");
      sb.write("\n\n");

      out.write(sb.toString());
    }
    end();
  }

  @override
  void handleNoType(Token lastConsumed) {
    latestSeenParameterTypeToken = null;
    latestSeenParameterTypeTokenQuestion = null;
  }

  @override
  void handleType(Token beginToken, Token? questionMark) {
    latestSeenParameterTypeToken = beginToken.lexeme;
    latestSeenParameterTypeTokenQuestion = questionMark?.lexeme;
  }

  @override
  void endFormalParameter(
      Token? thisKeyword,
      Token? superKeyword,
      Token? periodAfterThisOrSuper,
      Token nameToken,
      Token? initializerStart,
      Token? initializerEnd,
      FormalParameterKind kind,
      MemberKind memberKind) {
    parameters.add(new Parameter(
        nameToken.lexeme,
        latestSeenParameterTypeToken ?? 'dynamic',
        latestSeenParameterTypeTokenQuestion == null ? false : true));
  }
}

class Parameter {
  final String name;
  final String type;
  final bool hasQuestion;

  Parameter(this.name, this.type, this.hasQuestion);
}
