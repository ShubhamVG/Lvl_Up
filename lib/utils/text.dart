String pascalToNormal(String input) {
  if (input.isEmpty) return input;

  StringBuffer buffer = StringBuffer();
  buffer.write(input[0].toUpperCase()); // Capitalize first character

  for (int i = 1; i < input.length; i++) {
    int charCode = input.codeUnitAt(i);

    // Check if uppercase (A-Z)
    if (charCode >= 65 && charCode <= 90) {
      buffer.write(' '); // Add space before uppercase
    }
    buffer.write(input[i]);
  }

  return buffer.toString();
}
