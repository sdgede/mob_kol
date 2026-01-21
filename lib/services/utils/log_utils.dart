class LogUtils {
  /// Returns the name of the current class (if called from an instance).
  String getClassName(Object instance) {
    return instance.runtimeType.toString();
  }

  /// Returns the name of the currently executing method.
  String getCurrentMethodName() {
    // 1. Get the stack trace
    final frames = StackTrace.current.toString().split('\n');

    // 2. The first frame (#0) is this function itself.
    //    The second frame (#1) is the caller (the method we want).
    //    Note: strict usage of indices like this can be fragile.
    if (frames.length > 1) {
      String frame = frames[1];

      // Parse the frame string to extract the method name.
      // Typical format: "#1      MyClass.myMethod (file://...)"
      // We look for the part before the opening parenthesis '('.

      int indexOfOpenParen = frame.indexOf('(');
      int indexOfSpace = frame.indexOf(' ', 0); // Find first space for offset

      // Adjust parsing based on your specific platform (Web vs VM) output
      // This simple parse assumes standard VM formatting:
      if (indexOfOpenParen != -1) {
        // Extract "MyClass.myMethod" trimming the leading sequence number/spaces
        // You might need a more robust Regex for production web/multiple platforms
        var methodInfo = frame.substring(0, indexOfOpenParen).trim();

        // Remove the frame number (e.g. "#1")
        var parts = methodInfo.split(RegExp(r'\s+'));
        if (parts.length > 1) {
          return parts.last;
        }
      }
    }
    return 'Unknown Method';
  }
}
