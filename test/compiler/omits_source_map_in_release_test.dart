// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS d.file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:scheduled_test/scheduled_test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';
import 'utils.dart';

main() {
  integrationWithCompiler("omits source maps from a release build", (compiler) {
    d.dir(appPath, [
      d.appPubspec(),
      d.dir("lib", [d.file("message.dart", "String get message => 'hello';")]),
      d.dir("web", [
        d.file(
            "main.dart",
            """
        import "package:$appPath/message.dart";
        void main() => print(message);
        """)
      ])
    ]).create();

    pubGet();
    schedulePub(
        args: ["build", "--web-compiler=${compiler.name}"],
        output: new RegExp(r'Built \d+ files? to "build".'),
        exitCode: 0);

    switch (compiler) {
      case Compiler.dart2JS:
        d.dir(appPath, [
          d.dir('build', [
            d.dir('web', [
              d.nothing('main.dart.js.map'),
            ])
          ])
        ]).validate();
        break;
      case Compiler.dartDevc:
        d.dir(appPath, [
          d.dir('build', [
            d.dir('web', [
              d.dir('packages', [
                d.dir(appPath, [
                  d.matcherFile(
                      'lib__message.js',
                      isNot(
                          contains("# sourceMappingURL=lib__message.js.map"))),
                  d.nothing('lib__message.js.map'),
                ]),
              ]),
              d.nothing('main.dart.js.map'),
              d.nothing('web__main.js.map'),
            ])
          ])
        ]).validate();
        break;
    }
  });
}
