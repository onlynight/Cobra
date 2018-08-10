import 'dart:mirrors';

import 'Annotations.dart';

class GetRequstBuilder extends RequestBuilder {
  GetRequstBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    var headers = _buildHeaders();
    if (methodMirror != null) {
      var request = new CobraRequest(url, baseUrl, headers: headers);
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
    var headers = _buildHeaders();
    if (methodMirror != null) {
      var request = new CobraRequest(url, baseUrl, headers: headers);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Field) {
          if (methodMirror.parameters[i].metadata[0].reflectee.value != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.value,
                () => this.data[i].toString());
          }
        } else if (methodMirror.parameters[i].metadata[0].reflectee is Body) {
          request = new CobraRequest(url, baseUrl,
              params: this.data[i], headers: headers);
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
    var headers = _buildHeaders();
    if (methodMirror != null) {
      return new CobraRequest(url, baseUrl, headers: headers);
    }
    return null;
  }
}

class PutRequestBuilder extends RequestBuilder {
  PutRequestBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  CobraRequest buildRequest() {
    String url = _buildUrl();
    var headers = _buildHeaders();
    if (methodMirror != null) {
      var request = new CobraRequest(url, baseUrl, headers: headers);
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
    var headers = _buildHeaders();
    if (methodMirror != null) {
      return new CobraRequest(url, baseUrl, headers: headers);
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
            if (paths[i].compareTo('') == 0) {
              paths.removeAt(i);
            }
          }
          for (int i = 0; i < paths.length; i++) {
            String temp = paths[i];
            if (temp.contains('{') && temp.contains('}')) {
              String key = temp.replaceAll('{', '').replaceAll('}', '');
              for (int j = 0; j < methodMirror.parameters.length; j++) {
                ParameterMirror param = methodMirror.parameters[j];
                if (param.metadata[0].reflectee is Path &&
                    key.compareTo(param.metadata[0].reflectee.value) == 0) {
                  paths.removeAt(i);
                  paths.insert(i, this.data[j]);
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
        } else {
          return methodMirror.metadata[0].reflectee.path;
        }
      } else {
        return methodMirror.metadata[0].reflectee.path;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  Map<String, String> _buildHeaders() {
    Map<String, String> headers = new Map();
    methodMirror.metadata.forEach((metadata) {
      if (metadata.reflectee is Headers) {
        if (metadata.reflectee.value != null) {
          try {
            Map<String, String> mapper = metadata.reflectee.value;
            mapper.forEach((String key, String value) {
              headers.putIfAbsent(key, () => value);
            });
          } catch (e) {
            print(e);
          }
        }
      }
    });
    return headers;
  }
}

class CobraRequest {
  String url;
  String baseUrl;
  Map<String, String> params = {};
  Map<String, String> headers = {};

  CobraRequest(this.url, this.baseUrl, {this.headers, this.params}) {
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
    if (params is Map) {
      params.forEach((String key, dynamic value) {
        getUrl += key + '=' + value.toString() + '&';
      });
    } else if (params is String) {
      getUrl += params.toString();
    }
    return getUrl;
  }

  String toUrl() {
    return url;
  }
}
