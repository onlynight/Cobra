class GET {
  final String value;

  const GET(this.value);
}

class POST {
  /**
   * This value is request url value.
   */
  final String value;

  const POST(this.value);
}

class Query {
  /**
   * This will use for [GET] request query params;
   * If the {this.value} is null, then the url generator will use the param name as the query param name.
   */
  final String value;

  const Query({this.value});
}

class Form {
  /**
   * This will use for [POST] request query params;
   * If the {this.value} is null, then the url generator will use the param name as the query param name.
   */
  final String value;

  const Form({this.value});
}
