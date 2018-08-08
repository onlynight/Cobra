import 'dart:async';
import 'package:http/http.dart';

import 'cobra/Cobra.dart';
import 'Constants.dart' as constants;

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

  @GET(constants.LOCAL_HOST)
  Future<Response> requestLocalhost();

  @POST(constants.LOCAL_HOST)
  Future<Response> postLocalhost(@Field('id') int id);

  @HEAD(constants.LOCAL_HOST)
  Future<Response> headLocalhost();

  @PUT(constants.LOCAL_HOST)
  Future<Response> putLocalhost(@Field('id') int id);

  @DELETE(constants.LOCAL_HOST)
  Future<Response> deleteLocalhost();
}

main(List<String> args) {
  TestService service = Cobra.obtainService(TestService);
  Future<Response> response = service.getSiteInfo();
  printResponse(response);
  response = service.getSiteStatus();
  printResponse(response);
  response = service.getLatestTopic();
  // printResponse(response);
  response = service.getHotTopic();
  // printResponse(response);
  response = service.getTopicDetails(476624);
  // printResponse(response);
  response = service.requestLocalhost();
  printResponse(response);
  response = service.postLocalhost(1);
  printResponse(response);
  response = service.headLocalhost();
  printResponse(response);
  response = service.putLocalhost(1);
  printResponse(response);
  response = service.deleteLocalhost();
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
