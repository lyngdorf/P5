import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class DataUsageTrackerHttpClient extends http.BaseClient {
  final http.Client _client;
  int totalUploadedBytes = 0;
  int totalDownloadedBytes = 0;

  DataUsageTrackerHttpClient(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Track upload data size
    if (request is http.Request && request.bodyBytes.isNotEmpty) {
      totalUploadedBytes += request.bodyBytes.length;
    }

    // Capture the response
    final http.StreamedResponse response = await _client.send(request);

    // Convert the response stream to bytes to avoid listening more than once
    final List<int> bytes = await response.stream.toBytes();
    totalDownloadedBytes += bytes.length;

    // Return a new StreamedResponse using the captured bytes
    return http.StreamedResponse(
      Stream.fromIterable([bytes]),
      response.statusCode,
      contentLength: bytes.length,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      reasonPhrase: response.reasonPhrase,
    );
  }
}