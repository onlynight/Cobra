import 'Requests.dart';
import 'Responses.dart';

abstract class Intercepter {
  void beforeRequest(CobraRequest request);
  void afterResponse(CobraRequest request, CobraResponse response);
}