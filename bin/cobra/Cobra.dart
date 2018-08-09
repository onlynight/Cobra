import 'dart:mirrors';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'Annotations.dart';
import 'Intercepters.dart';
import 'Requests.dart';
import 'Responses.dart';

export 'Annotations.dart';
export 'Intercepters.dart';
export 'Requests.dart';
export 'Responses.dart';

class Cobra {
  String _url;
  List<Intercepter> _intercepters = new List();
  Map<Type, Map<Symbol, MethodMirror>> _cache = {};

  void set baseUrl(String url) => _url = url;

  String get baseUrl => _url;

  void addIntercepter(Intercepter intercepter) {
    _intercepters.add(intercepter);
  }

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

  dynamic _get(MethodMirror method, List<dynamic> data) async {
    return await _http_get(
        method, new GetRequstBuilder(baseUrl, method, data).buildRequest());
  }

  dynamic _post(MethodMirror method, List<dynamic> data) async {
    return _http_post(
        method, new PostRequstBuilder(baseUrl, method, data).buildRequest());
  }

  dynamic _head(MethodMirror method, List<dynamic> data) {
    return _http_head(
        method, new HeadRequestBuilder(baseUrl, method, data).buildRequest());
  }

  dynamic _put(MethodMirror method, List<dynamic> data) {
    return _http_put(
        method, new PutRequestBuilder(baseUrl, method, data).buildRequest());
  }

  dynamic _delete(MethodMirror method, List<dynamic> data) {
    return _http_delete(
        method, new DeleteRequestBuilder(baseUrl, method, data).buildRequest());
  }

  dynamic _http_head(MethodMirror method, CobraRequest request) async {
    if (request != null) {
      _performBeforeRequest(request);
      _printRequestLog(method, 'HEAD', request);
      Response response =
          await http.head(request.toGetUrl(), headers: request.headers);
      _performAfterResponse(
          request,
          new CobraResponse(
              response.statusCode, response.body, response.headers));
      return response;
    } else {
      return null;
    }
  }

  dynamic _http_get(MethodMirror method, CobraRequest request) async {
    if (request != null) {
      _performBeforeRequest(request);
      _printRequestLog(method, 'GET', request);
      Response response =
          await http.get(request.toGetUrl(), headers: request.headers);
      _performAfterResponse(
          request,
          new CobraResponse(
              response.statusCode, response.body, response.headers));
      return response;
    } else {
      return null;
    }
  }

  dynamic _http_post(MethodMirror method, CobraRequest request) async {
    if (request != null) {
      _performBeforeRequest(request);
      _printRequestLog(method, 'POST', request);
      Response response = await http.post(request.toGetUrl(),
          body: request.params, headers: request.headers);
      _performAfterResponse(
          request,
          new CobraResponse(
              response.statusCode, response.body, response.headers));
      return response;
    } else {
      return null;
    }
  }

  dynamic _http_put(MethodMirror method, CobraRequest request) async {
    if (request != null) {
      _performBeforeRequest(request);
      _printRequestLog(method, 'PUT', request);
      Response response = await http.put(request.toGetUrl(),
          body: request.params, headers: request.headers);
      _performAfterResponse(
          request,
          new CobraResponse(
              response.statusCode, response.body, response.headers));
      return response;
    } else {
      return null;
    }
  }

  dynamic _http_delete(MethodMirror method, CobraRequest request) async {
    if (request != null) {
      _performBeforeRequest(request);
      _printRequestLog(method, 'DELETE', request);
      Response response =
          await http.delete(request.toGetUrl(), headers: request.headers);
      _performAfterResponse(
          request,
          new CobraResponse(
              response.statusCode, response.body, response.headers));
      return response;
    } else {
      return null;
    }
  }

  void _printRequestLog(
      MethodMirror method, String httpMethod, CobraRequest request) {
    print(httpMethod +
        '    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGetUrl());
  }

  void _performBeforeRequest(CobraRequest request) {
    _intercepters.forEach((Intercepter intercepter) {
      intercepter.beforeRequest(request);
    });
  }

  void _performAfterResponse(CobraRequest request, CobraResponse response) {
    _intercepters.forEach((Intercepter intercepter) {
      intercepter.afterResponse(request, response);
    });
  }
}
