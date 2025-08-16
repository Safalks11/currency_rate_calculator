import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static final String? baseUrl = dotenv.env['BASE_URL'];

  static final String? accessKey = dotenv.env['ACCESS_KEY'];
}
