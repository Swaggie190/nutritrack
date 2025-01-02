import 'dart:io';

void main() {
  // Directory where your Dart files are located.
  final directoryPath = 'lib/features';
  final directory = Directory(directoryPath);

  if (!directory.existsSync()) {
    print('Directory does not exist: $directoryPath');
    return;
  }

  // Process each Dart file in the directory recursively.
  final dartFiles = directory
      .listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'));

  for (var file in dartFiles) {
    final dartFile = File(file.path);
    final content = dartFile.readAsStringSync();

    // Regular expression to find `const` keyword before widgets or decorations using ThemeConstants.
    final updatedContent = content.replaceAllMapped(
      RegExp(
          r'const\s+(Text|InputDecoration)\((.*?ThemeConstants\.[a-zA-Z]+\b.*?\))'),
      (match) {
        // Return the widget without the `const` keyword.
        return '${match.group(1)}(${match.group(2)})';
      },
    );

    // Save the updated content back to the file.
    dartFile.writeAsStringSync(updatedContent);
    print('Updated file: ${file.path}');
  }

  print('All files processed successfully.');
}
