import 'dart:async';
import 'cobra/Cobra.dart';
import 'Constants.dart' as constants;

abstract class TestService {
  @GET(constants.API_SITE_INFO)
  Future<String> getSiteInfo();

  @GET(constants.API_SITE_STATUS)
  Future<String> getSiteStatus();

  @GET(constants.API_TOPICS_LATEST)
  Future<String> getLatestTopic();

  @GET(constants.API_TOPICS_HOT)
  Future<String> getHotTopic();

  @GET(constants.API_TOPIC_DETAILS)
  Future<String> getTopicDetails(@Query() int id);
}

main(List<String> args) {
  TestService service = Cobra.obtainService(TestService);
  var response = service.getSiteInfo();
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
    response.then((res) {
      print(res);
    });
  }
}
