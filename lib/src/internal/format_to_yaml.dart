import 'package:meta/meta.dart';

import '../dependency_type.dart';
import '../git_package_dependency.dart';
import '../hosted_package_dependency.dart';
import '../package_dependency.dart';
import '../path_package_dependency.dart';
import '../sdk_dependency.dart';
import '../sdk_package_dependency.dart';

String formatToYaml({
  @required Iterable<SdkDependency> sdks,
  @required Iterable<PackageDependency> packages,
}) =>
    "# Generated by pub"
    "\n# See https://dart.dev/tools/pub/glossary#lockfile"
    "${packages.isEmpty ? "" : _formatPackagesDependencies(packages)}"
    "${sdks.isEmpty ? "" : _formatSdkDependencies(sdks)}"
    "\n";

String _formatSdkDependencies(Iterable<SdkDependency> sdks) =>
    "\nsdks:${sdks.map((sdk) => "\n  ${sdk.sdk}: \"${sdk.version}\"").join()}";

String _formatPackagesDependencies(Iterable<PackageDependency> packages) =>
    "\npackages:${packages.map(_formatPackage).join()}";

String _formatPackage(PackageDependency package) => '''
\n  ${package.package()}:
    dependency: ${_formatLiteral(_convertDepTypeToString(package.type()))}
    description:${package.iswitch(
      sdk: (p) => _formatSdkPackageDescription(p),
      hosted: (p) => _formatHostedPackageDescription(p),
      git: (p) => _formatGitPackageDescription(p),
      path: (p) => _formatPathPackageDescription(p),
    )}
    source: ${package.iswitch(
      sdk: (p) => 'sdk',
      hosted: (p) => 'hosted',
      git: (p) => 'git',
      path: (p) => 'path',
    )}
    version: \"${package.version()}\"''';

String _formatSdkPackageDescription(SdkPackageDependency package) => " ${package.description}";

String _formatHostedPackageDescription(HostedPackageDependency package) => '''
\n      name: ${package.name}
      url: \"${package.url}\"''';

String _formatGitPackageDescription(GitPackageDependency package) => '''
\n      path: \"${package.path}\"
      ref: ${_formatLiteral(package.ref)}
      resolved-ref: \"${package.resolvedRef}\"
      url: \"${package.url}\"''';

String _formatPathPackageDescription(PathPackageDependency package) => '''
\n      path: \"${package.path}\"
      relative: ${package.relative}''';

String _convertDepTypeToString(DependencyType dependencyType) {
  switch (dependencyType) {
    case DependencyType.direct:
      return "direct main";
    case DependencyType.development:
      return "direct dev";
    case DependencyType.transitive:
      return "transitive";
  }
  throw AssertionError(dependencyType);
}

String _formatLiteral(String s) => s.contains(RegExp(r'\s')) ? "\"$s\"" : s;
