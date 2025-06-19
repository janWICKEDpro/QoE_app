import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentVariables {
  // ignore: non_constant_identifier_names
  static final BASE_URL = "${dotenv.env['BASE_URL']}";
  // ignore: non_constant_identifier_names
  static final API_KEY = "${dotenv.env['API_KEY']}";
  static final userUrl = "$BASE_URL/api";
  static final driverUrl = "$BASE_URL/api/driver";
  static final locationIQKey = "${dotenv.env['LOCATION_IQ_KEY']}";
  static final supabaseUrl = "${dotenv.env['SUPABASE_URL']}";
  static final supabaseAnonKey = "${dotenv.env['SUPABASE_ANON_KEY']}";
}