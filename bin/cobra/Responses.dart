class CobraResponse {
  int statusCode = 400;
  String body;
  Map<String, String> headers;

  CobraResponse(this.statusCode, this.body, this.headers);
}