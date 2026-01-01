// Stub file for non-web platforms
// This file provides empty implementations to avoid compilation errors on mobile

class Window {
  dynamic get navigator => _Navigator();
}

class _Navigator {
  dynamic get mediaDevices => null;
}

class VideoElement {
  dynamic srcObject;
  int get videoWidth => 0;
  int get videoHeight => 0;
  Future<void> play() async {}
}

class CanvasElement {
  int width = 0;
  int height = 0;
  dynamic getContext(String type) => null;
  String toDataUrl(String type, double quality) => '';
}

class Blob {
  Blob(List<dynamic> data) {}
}

class AnchorElement {
  String? href;
  AnchorElement({this.href});
  void setAttribute(String name, String value) {}
  void click() {}
  void remove() {}
}

class Document {
  BodyElement? get body => null;
}

class BodyElement {
  void append(dynamic element) {}
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

final window = Window();
final document = Document();

