import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });

  Future<void> auth() async {
    httpClient.request(url: url, method: 'post');
  }
}

abstract class HttpClient {
  Future<void> request({
    @required String url,
    @required String method,
  });
}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;

  setUp(() {
    ///Utilização do triplo A
    ///1º Arrange -> Configuração de tudo que é necessário para que o teste possa rodar
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should call HttpClient with correct values', () async {
    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    await sut.auth();

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    verify(httpClient.request(
      url: url,
      method: 'post',
    ));
  });
}
