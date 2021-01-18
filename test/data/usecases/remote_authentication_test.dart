import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:tdd_solid_design/domain/usecases/usecases.dart ';

import 'package:tdd_solid_design/data/http/http.dart';
import 'package:tdd_solid_design/data/usecases/usecases.dart';

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
    final params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    await sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    verify(httpClient.request(
        url: url,
        method: 'post',
        body: {'email': params.email, 'password': params.secret}));
  });
}
