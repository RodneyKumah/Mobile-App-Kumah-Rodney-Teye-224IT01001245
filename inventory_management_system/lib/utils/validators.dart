class Validators {
  /// Must not be empty
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Must be a positive whole number
  static String? positiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a number';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid whole number';
    if (n <= 0) return 'Must be greater than zero';
    return null;
  }

  /// Must be a positive decimal number
  static String? positiveDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a price';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Price cannot be negative';
    return null;
  }

  /// Must not exceed available stock
  static String? notExceedStock(String? value, int available) {
    final baseCheck = positiveInt(value);
    if (baseCheck != null) return baseCheck;
    final qty = int.parse(value!.trim());
    if (qty > available) return 'Only $available units available';
    return null;
  }
}
