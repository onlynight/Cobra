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
```

Then use ```Cobra``` to create a proxy class, and call the API method:

```dart
var cobra = new Cobra()
    ..baseUrl = constants.LOCAL_HOST
    ..addIntercepter(new HttpRequestIntercepter());

TestService service = cobra.obtainService(TestService);

Future<Response> response = service.getLocalhost();
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
