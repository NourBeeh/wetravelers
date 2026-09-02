import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/admin/admin_home_content_service.dart';
import 'package:wetravellers/core/admin/admin_provider_models.dart';
import 'package:wetravellers/core/admin/http_admin_home_service.dart';
import 'package:wetravellers/core/admin/http_admin_provider_service.dart';
import 'package:wetravellers/core/network/http_api_client.dart';
import 'package:wetravellers/core/storage/secure_token_storage_provider.dart';

/// Admin workstream wiring (ADM-A2). Both services share the standard
/// [HttpApiClient] and read the session bearer token from secure storage.
final adminContentServiceProvider = Provider<AdminHomeContentService>((ref) {
  return HttpAdminContentService(
    apiClient: HttpApiClient(),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

final adminHomeServiceProvider = Provider<HttpAdminHomeService>((ref) {
  return HttpAdminHomeService(
    apiClient: HttpApiClient(),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

final adminProviderServiceProvider = Provider<AdminProviderService>((ref) {
  return HttpAdminProviderService(
    apiClient: HttpApiClient(),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});
