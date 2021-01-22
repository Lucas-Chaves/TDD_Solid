import 'package:faker/faker.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:tdd_solid_design/domain/helpers/helpers.dart';
import 'package:tdd_solid_design/domain/usecases/usecases.dart ';

import 'package:tdd_solid_design/data/http/http.dart';
import 'package:tdd_solid_design/data/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;

  PostExpectation mockRequest() => when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body')));

  Map mockValidDate() =>
      {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    ///Utilização do triplo A
    ///1º Arrange -> Configuração de tudo que é necessário para que o teste possa rodar
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
        email: faker.internet.email(), secret: faker.internet.password());
    mockHttpData(mockValidDate());
  });

  test('Should call HttpClient with correct values', () async {
    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    await sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    verify(httpClient.request(
        url: url,
        method: 'post',
        body: {'email': params.email, 'password': params.secret}));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    mockHttpError(HttpError.badRequest);

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final future = sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final future = sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final future = sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialError if HttpClient returns 401',
      () async {
    mockHttpError(HttpError.unauthorized);

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final future = sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an Account if HttpClient returns 200', () async {
    final validDate = mockValidDate();
    mockHttpData(validDate);

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final account = await sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(account.token, validDate['accessToken']);
  });

  test(
      'Should throw UnexpectedError if HttpClient returns 200 with invalid data',
      () async {
    mockHttpData({'invalid_key': 'invalid_value'});

    ///2º Act -> Executa o teste, chamando alguma função ou algo do tipo
    final future = sut.auth(params);

    ///3º Assert -> Verifica se a operação realizada na anterior (Act) surtiu o resultado esperado
    expect(future, throwsA(DomainError.unexpected));
  });
}
