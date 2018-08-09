import 'dart:mirrors';

import 'Annotations.dart';

class GetRequstBuilder extends RequestBuilder {
  GetRequstBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    if (methodMirror != null) {
      // for (var metadata in methodMirror.metadata) {
      //   if (metadata.reflectee is GET) {
      //     url += metadata.reflectee.path;
      //     break;
      //   }
      // }

      var request = new CobraRequest(url, baseUrl);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Query) {
          if (methodMirror.parameters[i].metadata[0].reflectee.value != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.value,
                () => this.data[i]);
          }
        } else if (methodMirror.parameters[i].metadata[0].reflectee
            is QueryMap) {
          if (this.data[i] != null) {
            this.data[i].forEach((String key, String value) {
              request.params.putIfAbsent(key, () => this.data[i][key]);
            });
          }
        }
      }
      return request;
    }
    return null;
  }
}

class PostRequstBuilder extends RequestBuilder {
  PostRequstBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    if (methodMirror != null) {
      // for (var metadata in methodMirror.metadata) {
      //   if (metadata.reflectee is POST) {
      //     url += metadata.reflectee.path;
      //     break;
      //   }
      // }

      var request = new CobraRequest(url, baseUrl);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Field) {
          if (methodMirror.parameters[i].metadata[0].reflectee.value != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.value,
                () => this.data[i].toString());
          }
          // else {
          //   request.params.putIfAbsent(
          //       MirrorSystem.getName(methodMirror.parameters[i].simpleName),
          //       () => this.data[i]);
          // }
        }
      }
      return request;
    }
    return null;
  }
}

class HeadRequestBuilder extends RequestBuilder {
  HeadRequestBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    if (methodMirror != null) {
      // for (var metadata in methodMirror.metadata) {
      //   if (metadata.reflectee is HEAD) {
      //     url += metadata.reflectee.path;
      //     break;
      //   }
      // }

      return new CobraRequest(url, baseUrl);
    }
    return null;
  }
}

class PutRequestBuilder extends RequestBuilder {
  PutRequestBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    if (methodMirror != null) {
      // for (var metadata in methodMirror.metadata) {
      //   if (metadata.reflectee is PUT) {
      //     url += metadata.reflectee.path;
      //     break;
      //   }
      // }

      var request = new CobraRequest(url, baseUrl);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Field) {
          if (methodMirror.parameters[i].metadata[0].reflectee.value != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.value,
                () => this.data[i].toString());
          }
        }
      }
      return request;
    }
    return null;
  }
}

class DeleteRequestBuilder extends RequestBuilder {
  DeleteRequestBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    if (methodMirror != null) {
      // for (var metadata in methodMirror.metadata) {
      //   if (metadata.reflectee is DELETE) {
      //     url += metadata.reflectee.path;
      //     break;
      //   }
      // }

      return new CobraRequest(url, baseUrl);
    }
    return null;
  }
}

class RequestBuilder {
  String baseUrl;
  MethodMirror methodMirror;
  List<dynamic> data;

  RequestBuilder(this.baseUrl, this.methodMirror, this.data);

  CobraRequest buildRequest() {
    return null;
  }

  String _buildUrl() {
    try {
      if (methodMirror.metadata[0].reflectee != null &&
          methodMirror.metadata[0].reflectee.path != null) {
        String path = methodMirror.metadata[0].reflectee.path;
        if (path.contains('{') && path.contains('}')) {
          List<String> paths = path.split('/');
          for (int i = 0; i < paths.length; i++) {
            String temp = paths[i];
            if (temp.contains('{') && temp.contains('}')) {
              String key = temp.replaceAll('{', '').replaceAll('}', '');
              for (int j = 0; j < methodMirror.parameters.length; j++) {
                ParameterMirror param = methodMirror.parameters[j];
                if (key.compareTo(param.metadata[0].reflectee.value) == 0) {
                  paths.replaceRange(
                      j, j, new List<String>()..add(this.data[j]));
                }
              }
            }
          }
          String url = '';
          paths.forEach((temp) {
            if (temp.startsWith('http')) {
              url += temp;
            } else {
              url += '/' + temp;
            }
          });
          url += '/';
          return url;
        }
      } else {
        print(methodMirror.metadata[0].reflectee.path);
        return methodMirror.metadata[0].reflectee.path;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }
}

class CobraRequest {
  String url;
  String baseUrl;
  Map<String, String> params = {};
  Map<String, String> headers = {};

  CobraRequest(this.url, this.baseUrl, {this.headers}) {
    if (url != null) {
      if (!url.startsWith('http')) {
        url = baseUrl + url;
      }
    }
    if (this.headers == null) {
      this.headers = {};
    }
    if (this.params == null) {
      this.params = {};
    }
  }

  String toGetUrl() {
    String getUrl = url;
    getUrl += '?';
    params.forEach((String key, dynamic value) {
      getUrl += key + '=' + value.toString() + '&';
    });
    return getUrl;
  }

  String toUrl() {
    return url;
  }
}
