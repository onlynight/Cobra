Cobra
=====

If you are an android developer, you must know [Retrofit][1]. This project aim to create the same functionality tools for flutter. Now it's in develop, let's develop it together.

## TEST

Test server project is [here][2].

## DEMO

Define a abstract class to declare HTTP request method:

```dart
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

  @POST('https://www.baidu.com')
  Future<Response> getWebPage(@Query('q') String query);
}
```

Then use ```Cobra``` to create a proxy class, and call the API method:

```dart
TestService service = Cobra.obtainService(TestService);
var response = service.getSiteInfo();
response.then((res){
    print(res);
});
```

Then you will see this response:

```json
{
    "title" : "V2EX",
    "slogan" : "way to explore",
    "description" : "创意工作者们的社区",
    "domain" : "www.v2ex.com"
}
```

## New Feature

Now, this is just a metadata demo, in the future, i want add more and more feature into Cobra.

Add new feature here...

[1]: https://github.com/square/retrofit
[2]: https://github.com/onlynight/CobraTestServer
