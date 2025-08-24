import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configurations {
  String baseUrl = kReleaseMode ? dotenv.env["BASE_URL"] ?? "" :  "https://triq-server.onrender.com/" ;
}
