import 'dart:io';
import 'package:http/http.dart' as http;

class CustomHttpClient extends http.BaseClient {
  final String proxyUrl;
  final HttpClient _httpClient = HttpClient();
  final http.Client _inner;

  CustomHttpClient(this.proxyUrl, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Configure the proxy
    _httpClient.findProxy = (uri) {
      return HttpClient.findProxyFromEnvironment(uri, environment: {
        'http_proxy': proxyUrl,
        'https_proxy': proxyUrl,
      });
    };

    // Use the HttpClient to create an HttpClientRequest
    final ioRequest = await _httpClient.openUrl(request.method, request.url);

    // Set headers
    request.headers.forEach((name, value) {
      ioRequest.headers.set(name, value);
    });

    // Add body
    if (request is http.Request) {
      ioRequest.add(request.bodyBytes);
    }

    // Get the response
    final ioResponse = await ioRequest.close();

    // Convert headers to a Map<String, String>
    final headers = <String, String>{};
    ioResponse.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });

    return http.StreamedResponse(
      ioResponse.cast<List<int>>(),
      ioResponse.statusCode,
      contentLength: ioResponse.contentLength,
      request: request,
      headers: headers,
      isRedirect: ioResponse.isRedirect,
      reasonPhrase: ioResponse.reasonPhrase,
    );
  }

  Future<bool> checkProxyConnection() async {
    try {
      final response = await _inner.get(
        Uri.parse('https://www.google.com'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  void close() {
    _httpClient.close();
    _inner.close();
  }
}