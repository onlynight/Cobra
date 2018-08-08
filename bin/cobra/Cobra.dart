import 'dart:mirrors';
import 'Annotations.dart';
import 'package:http/http.dart' as http;
export 'Annotations.dart';

class Cobra {
  String _url;
  Map<Type, Map<Symbol, MethodMirror>> _cache = {};

  void set baseUrl(String url) => _url = url;

  String get baseUrl => _url;

  dynamic obtainService(Type type) {
    var exist = _cache.containsKey(type);
    if (!exist) {
      ClassMirror classMirror = reflectClass(type);
      _cache.putIfAbsent(type, () => new Map<Symbol, MethodMirror>());
      classMirror.declarations.forEach((Symbol key, DeclarationMirror value) {
        if (value is MethodMirror) {
          _cache[type].putIfAbsent(key, () => value);
        }
      });
    }
    return this;
  }

  @override
  noSuchMethod(Invocation invocation) {
    var method = _getMethod(invocation);
    if (method != null) {
      var methodName = null;
      int methodCount = 0;
      method.metadata.forEach((metadata) {
        if (metadata.reflectee is GET) {
          methodName = 'GET';
          methodCount++;
        } else if (metadata.reflectee is POST) {
          methodName = 'POST';
          methodCount++;
        } else if (metadata.reflectee is HEAD) {
          methodName = 'HEAD';
          methodCount++;
        } else if (metadata.reflectee is PUT) {
          methodName = 'PUT';
          methodCount++;
        } else if (metadata.reflectee is DELETE) {
          methodName = 'DELETE';
          methodCount++;
        }
      });

      if (methodCount > 1) {
        throw new Exception(MirrorSystem.getName(method.qualifiedName) +
            ' ===> has multi metadata.');
      }

      switch (methodName) {
        case 'GET':
          return _get(method, invocation.positionalArguments);
          break;
        case 'POST':
          return _post(method, invocation.positionalArguments);
          break;
        case 'HEAD':
          return _head(method, invocation.positionalArguments);
          break;
        case 'PUT':
          return _put(method, invocation.positionalArguments);
          break;
        case 'DELETE':
          return _delete(method, invocation.positionalArguments);
          break;
        default:
          break;
      }
    }
  }

  MethodMirror _getMethod(Invocation invocation) {
    var method = null;
    _cache.forEach((Type type, Map<Symbol, MethodMirror> methods) {
      for (var name in methods.keys) {
        if (invocation.memberName == name) {
          method = methods[name];
          break;
        }
      }
    });

    return method;
  }

  dynamic _get(MethodMirror method, List<dynamic> data) {
    var request = new GetRequstBuilder(baseUrl, method, data).buildRequest();
    print('GET     =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());
    return _http_get(request);
  }

  dynamic _post(MethodMirror method, List<dynamic> data) {
    var request = new PostRequstBuilder(baseUrl, method, data).buildRequest();
    print('POST    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());
    return _http_post(request);
  }

  dynamic _head(MethodMirror method, List<dynamic> data) {
    var request = new HeadRequestBuilder(baseUrl, method, data).buildRequest();
    print('HEAD    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());

    return _http_head(request);
  }

  dynamic _put(MethodMirror method, List<dynamic> data) {
    var request = new PutRequestBuilder(baseUrl, method, data).buildRequest();
    print('PUT    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());

    return _http_put(request);
  }

  dynamic _delete(MethodMirror method, List<dynamic> data) {
    var request =
        new DeleteRequestBuilder(baseUrl, method, data).buildRequest();
    print('DELETE    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());

    return _http_delete(request);
  }

  static dynamic _http_head(Request request) {
    if (request != null) {
      return http.head(request.toGetUrl());
    } else {
      return null;
    }
  }

  static dynamic _http_get(Request request) {
    if (request != null) {
      return http.get(request.toGetUrl());
    } else {
      return null;
    }
  }

  static dynamic _http_post(Request request) {
    if (request != null) {
      return http.post(request.toGetUrl(), body: request.params);
    } else {
      return null;
    }
  }

  static dynamic _http_put(Request request) {
    if (request != null) {
      return http.put(request.toGetUrl(), body: request.params);
    } else {
      return null;
    }
  }

  static dynamic _http_delete(Request request) {
    if (request != null) {
      return http.delete(request.toGetUrl());
    } else {
      return null;
    }
  }
}

class GetRequstBuilder extends RequestBuilder {
  GetRequstBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is GET) {
          url += metadata.reflectee.path;
          break;
        }
      }

      var request = new Request(url, baseUrl);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Query) {
          if (methodMirror.parameters[i].metadata[0].reflectee.value != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.value,
                () => this.data[i]);
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

class PostRequstBuilder extends RequestBuilder {
  PostRequstBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is POST) {
          url += metadata.reflectee.path;
          break;
        }
      }

      var request = new Request(url, baseUrl);
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

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is HEAD) {
          url += metadata.reflectee.path;
          break;
        }
      }

      return new Request(url, baseUrl);
    }
    return null;
  }
}

class PutRequestBuilder extends RequestBuilder {
  PutRequestBuilder(String baseUrl, MethodMirror methodMirror, List data)
      : super(baseUrl, methodMirror, data);

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is PUT) {
          url += metadata.reflectee.path;
          break;
        }
      }

      var request = new Request(url, baseUrl);
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

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is DELETE) {
          url += metadata.reflectee.path;
          break;
        }
      }

      return new Request(url, baseUrl);
    }
    return null;
  }
}

class RequestBuilder {
  String baseUrl;
  MethodMirror methodMirror;
  List<dynamic> data;

  RequestBuilder(this.baseUrl, this.methodMirror, this.data);

  Request buildRequest() {
    return null;
  }
}

class Request {
  String url;
  String baseUrl;
  Map<String, String> params = {};
  Map<String, String> headers = {};

  Request(this.url, this.baseUrl, {this.headers}) {
    if (url != null) {
      if (!url.startsWith('http')) {
        url = baseUrl + url;
      }
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
