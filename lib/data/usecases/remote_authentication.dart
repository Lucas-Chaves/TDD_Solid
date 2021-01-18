import 'package:meta/meta.dart';

import 'package:tdd_solid_design/domain/usecases/usecases.dart';

import '../http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });

  Future<void> auth(AuthenticationParams params) async {
    httpClient.request(
      url: url,
      method: 'post',
      body: params.toJson(),
    );
  }
}
