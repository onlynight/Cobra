/**
 * define http GET request method.
 */
class GET {
  /**
   * Set the request path here,
   * if you reset http host here, then it will replace the {baseUrl}.
   */
  final String path;

  const GET(this.path);
}

/**
 * define http POST request method.
 */
class POST {
  /**
   * Set the request path here,
   * if you reset http host here, then it will replace the {baseUrl}.
   */
  final String path;

  const POST(this.path);
}

/**
 * Define the http request headers.
 */
class HEAD {
  final String path;

  const HEAD(this.path);
}

/**
 * Define PUT http request.
 */
class PUT {
  final String path;

  const PUT(this.path);
}

/**
 * Define DELETE http request.
 */
class DELETE {
  final String path;

  const DELETE(this.path);
}

/**
 * fill the url '{path}' path value.
 */
class Path {
  final String value;

  const Path(this.value);
}

/**
 * this value will fill the GET request query param.
 */
class Query {
  /**
   * This will use for [GET] request query params;
   * If the {this.value} is null, then the url generator will use the param name as the query param name.
   */
  final String value;

  const Query(this.value);
}

/**
 * Define the GET http request query map param.
 * The query key will be the map key.
 */
class QueryMap {
  const QueryMap();
}

class Body {
  final String value;

  const Body(this.value);
}

/**
 * Set the POST request body field.
 */
class Field {
  /**
   * This will use for [POST] request query params;
   * If the {this.value} is null, then the url generator will use the param name as the query param name.
   */
  final String value;

  const Field(this.value);
}

/**
 * Set http request param as form-urlencoded.
 */
class FormUrlEncoded {
  const FormUrlEncoded();
}

/**
 * Set http request param as form data.
 */
class FormData {
  const FormData();
}

/**
 * Set http request param as raw data.
 */
class RawData {
  const RawData();
}

/**
 * Set the http request headers.
 */
class Headers {
  final String value;

  const Headers(this.value);
}

/**
 * Set the header with map, Map<String,String> only this way.
 */
class HeaderMap {
  const HeaderMap();
}
