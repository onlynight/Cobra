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
  printResponse(response);
}

void printResponse(var response) {
  if (response != null) {
    response.then((Response res) {
      print(res.statusCode.toString() + ' ==> ' + res.body.toString());
    });
  }
}
