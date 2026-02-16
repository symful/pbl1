import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/api_client.dart';
import '../features/home/config/app_config.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.baseUrl);
});
