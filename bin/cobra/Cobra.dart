import 'dart:mirrors';
import 'Annotations.dart';
import 'package:http/http.dart' as http;
export 'Annotations.dart';

class Cobra {
  static final Map<Type, Map<Symbol, MethodMirror>> _cache = {};
  static final Cobra _instance = const Cobra();

  static dynamic obtainService(Type type) {
    return _instance._obtainService(type);
  }

  const Cobra();

  dynamic _obtainService(Type type) {
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
      var hasGet = false;
      var hasPost = false;
      method.metadata.forEach((metadata) {
        if (metadata.reflectee is GET) {
          hasGet = true;
        }

        if (metadata.reflectee is POST) {
          hasPost = true;
        }
      });

      if (hasGet && hasPost) {
        throw new Exception(MirrorSystem.getName(method.qualifiedName) +
            ' ===> has both [GET] and [POST] metadata.');
      }

      if (hasGet) {
        return _get(method, invocation.positionalArguments);
      } else if (hasPost) {
        _post(method, invocation.positionalArguments);
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
    var request = new GetRequstBuilder(method, data).buildRequest();
    print('GET     =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGeturl());
    return _read(request);
  }

  dynamic _post(MethodMirror method, List<dynamic> data) {
    var request = new PostRequstBuilder(method, data).buildRequest();
    print('POST    =>    <' +
        MirrorSystem.getName(method.qualifiedName) +
        '>    REQUEST    =>    ' +
        request.toGeturl());
    return _read_post(request);
  }

  void _head(Request request){
    http.head(request.toGeturl());
  }

  static dynamic _read(Request request) {
    return http.get(request.toGeturl());
  }

  static dynamic _read_post(Request request) {
    return http.post(request.url, body: request.params);
  }
}

class GetRequstBuilder extends RequestBuilder {
  GetRequstBuilder(MethodMirror methodMirror, List data)
      : super(methodMirror, data);

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is GET) {
          url += metadata.reflectee.path;
          break;
        }
      }

      var request = new Request(url);
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
  PostRequstBuilder(MethodMirror methodMirror, List data)
      : super(methodMirror, data);

  Request buildRequest() {
    String url = '';
    if (methodMirror != null) {
      for (var metadata in methodMirror.metadata) {
        if (metadata.reflectee is POST) {
          url += metadata.reflectee.path;
          break;
        }
      }

      var request = new Request(url);
      for (int i = 0; i < methodMirror.parameters.length; i++) {
        if (methodMirror.parameters[i].metadata[0].reflectee is Field) {
          if (methodMirror.parameters[i].metadata[0].reflectee.path != null) {
            request.params.putIfAbsent(
                methodMirror.parameters[i].metadata[0].reflectee.path,
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

class RequestBuilder {
  MethodMirror methodMirror;
  List<dynamic> data;

  RequestBuilder(this.methodMirror, this.data);

  Request buildRequest() {
    return null;
  }
}

class Request {
  String url;
  Map<String, String> params = {};
  Map<String, String> headers = {};

  Request(this.url, {this.headers});

  String toGeturl() {
    String getUrl = url;
    getUrl += '?';
    params.forEach((String key, dynamic value) {
      getUrl += key + '=' + value.toString() + '&';
    });
    return getUrl;
  }

  String toUrl(){
    return url;
  }
}
