// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:medicail/core/audio/audio_capture_service.dart' as _i21;
import 'package:medicail/core/audio/speech_to_text_service_impl.dart' as _i439;
import 'package:medicail/core/config/app_config.dart' as _i155;
import 'package:medicail/core/di/register_module.dart' as _i91;
import 'package:medicail/core/network/api_client.dart' as _i1005;
import 'package:medicail/core/network/auth_token_storage.dart' as _i760;
import 'package:medicail/core/network/interceptors/auth_interceptor.dart'
    as _i737;
import 'package:medicail/core/network/interceptors/error_interceptor.dart'
    as _i479;
import 'package:medicail/core/network/interceptors/logging_interceptor.dart'
    as _i945;
import 'package:medicail/core/network/secure_storage_auth_token.dart' as _i249;
import 'package:medicail/core/router/app_router.dart' as _i1038;
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart'
    as _i988;
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart'
    as _i302;
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart'
    as _i794;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i155.AppConfig>(() => _i155.AppConfig());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i479.ErrorInterceptor>(() => _i479.ErrorInterceptor());
    gh.lazySingleton<_i945.LoggingInterceptor>(
      () => _i945.LoggingInterceptor(),
    );
    gh.lazySingleton<_i1038.AppRouter>(() => _i1038.AppRouter());
    gh.lazySingleton<_i21.AudioCaptureService>(
      () => _i439.SpeechToTextServiceImpl(),
    );
    gh.factory<_i794.VoiceCaptureBloc>(
      () => _i794.VoiceCaptureBloc(gh<_i21.AudioCaptureService>()),
    );
    gh.lazySingleton<_i760.AuthTokenStorage>(
      () => _i249.SecureStorageAuthToken(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i302.RecordingSessionRepository>(
      () => _i988.SecureStorageRecordingSessionRepository(
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i583.GoRouter>(
      () => registerModule.goRouter(gh<_i1038.AppRouter>()),
    );
    gh.lazySingleton<_i737.AuthInterceptor>(
      () => _i737.AuthInterceptor(gh<_i760.AuthTokenStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i155.AppConfig>(),
        gh<_i737.AuthInterceptor>(),
        gh<_i945.LoggingInterceptor>(),
        gh<_i479.ErrorInterceptor>(),
      ),
    );
    gh.lazySingleton<_i1005.ApiClient>(() => _i1005.ApiClient(gh<_i361.Dio>()));
    return this;
  }
}

class _$RegisterModule extends _i91.RegisterModule {}
