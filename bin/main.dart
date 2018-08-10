import 'dart:async';

import 'package:http/http.dart';

import 'Constants.dart' as constants;
import 'cobra/Cobra.dart';

abstract class TestService {
  @GET(constants.API_SITE_INFO)
  Future<Response> getSiteInfo();

  @GET(constants.API_SITE_STATUS)
  Future<Response> getSiteStatus();

  @GET(constants.API_TOPICS_LATEST)
  Future<Response> getLatestTopic();

  @GET(constants.API_TOPICS_HOT)
  Future<Response> getHotTopic();

  @GET(constants.API_TOPIC_DETAILS)
  Future<Response> getTopicDetails(@Query('id') int id);

  @GET(constants.LOCAL_HOST + '/get.json')
  Future<Response> getLocalhost();

  @POST(constants.LOCAL_HOST + '/post.json')
  Future<Response> postLocalhost(@Field('id') int id);

  @HEAD(constants.LOCAL_HOST + '/head.json')
  Future<Response> headLocalhost();

  @PUT(constants.LOCAL_HOST + '/put.json')
  Future<Response> putLocalhost(@Field('id') int id);

  @DELETE('/delete.json')
  Future<Response> deleteLocalhost();

  @GET('/query_map.json')
  Future<Response> queryMapLocalhost(@QueryMap() Map<String, String> params);

  @GET('/{some_path}/{some_path2}/get.json/')
  Future<Response> getPathLocalhost(@Path('some_path') String path,
      @Query('id') int id, @Path('some_path2') String path2);

  @GET('/headers.json')
  @Headers(const {'deviece_id': '1234sabgas3242asdfabqwer'})
  Future<Response> getWithHeadersLocalhost();

  @POST('/json.json')
  @Headers(const {'Content-type': 'application/json'})
  Future<Response> postJsonContentLocalhost(@Body() String body);

}

void testJsonBody() {
  String url = "http://localhost:8080";
  post(url,
          headers: {'Content-type': 'application/json'},
          body:
              '{"distinct": "users","key": "account","query": {"active":true}}')
      .then((response) {
    print(response.body);
  });
}

main(List<String> args) {
  // testJsonBody();
  var cobra = new Cobra()
    ..baseUrl = constants.LOCAL_HOST
    ..addIntercepter(new HttpRequestIntercepter());

  TestService service = cobra.obtainService(TestService);

  Future<Response> response = service.getLocalhost();
  printResponse(response);

  response = service.postLocalhost(1);
  printResponse(response);

  response = service.headLocalhost();
  printResponse(response);

  response = service.putLocalhost(1);
  printResponse(response);

  response = service.deleteLocalhost();
  printResponse(response);

  Map<String, String> params = {};
  params.putIfAbsent('key1', () => 'value1');
  params.putIfAbsent('key2', () => 'value2');
  params.putIfAbsent('key3', () => 'value3');
  response = service.queryMapLocalhost(params);
  printResponse(response);

  response = service.getPathLocalhost('get', 1, 'post');
  printResponse(response);

  response = service.getWithHeadersLocalhost();
  printResponse(response);

  response = service.postJsonContentLocalhost('{\"id\":123}');
  printResponse(response);
}

void printResponse(var response) {
  if (response != null) {
    response.then((Response res) {
      print(res.request.method +
          ' ==> ' +
          res.statusCode.toString() +
          ' ==> ' +
          res.request.url.toString() +
          ' ==> ' +
          res.body.toString());
    });
  }
}

class HttpRequestIntercepter extends Intercepter {
  @override
  void afterResponse(CobraRequest request, CobraResponse response) {}

  @override
  void beforeRequest(CobraRequest request) {
    if (request.params is Map) {
      request.params.putIfAbsent('add_param_in_intercepter', () => 'value');
    }
    request.headers
        .putIfAbsent('token', () => 'tokenasdfaskjdkqwerjajsdfasafds21432');
  }
}
