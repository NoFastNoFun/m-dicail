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
import 'package:medicail/core/audio/audio_playback_service.dart' as _i366;
import 'package:medicail/core/audio/just_audio_playback_service.dart' as _i475;
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
import 'package:medicail/core/storage/app_session_storage.dart' as _i345;
import 'package:medicail/features/auth/data/repositories/auth_repository_impl.dart'
    as _i985;
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart'
    as _i790;
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart'
    as _i250;
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart'
    as _i541;
import 'package:medicail/features/exo_patient/data/datasources/exercise_catalog_data_source.dart'
    as _i1040;
import 'package:medicail/features/exo_patient/data/repositories/exercise_repository_impl.dart'
    as _i858;
import 'package:medicail/features/exo_patient/data/repositories/patient_exercise_repository_impl.dart'
    as _i993;
import 'package:medicail/features/exo_patient/domain/repositories/exercise_repository.dart'
    as _i643;
import 'package:medicail/features/exo_patient/domain/repositories/patient_exercise_repository.dart'
    as _i506;
import 'package:medicail/features/note_template/data/datasources/asset_note_template_data_source.dart'
    as _i564;
import 'package:medicail/features/note_template/data/repositories/note_template_repository_impl.dart'
    as _i93;
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart'
    as _i144;
import 'package:medicail/features/note_template/presentation/note_template_bloc.dart'
    as _i297;
import 'package:medicail/features/patient/data/repositories/api_patient_repository.dart'
    as _i545;
import 'package:medicail/features/patient/data/repositories/dynamic_patient_repository.dart'
    as _i238;
import 'package:medicail/features/patient/data/repositories/secure_storage_patient_repository.dart'
    as _i830;
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart'
    as _i390;
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart'
    as _i802;
import 'package:medicail/features/patient/presentation/patient_bloc.dart'
    as _i301;
import 'package:medicail/features/recording/data/repositories/dynamic_recording_session_repository.dart'
    as _i932;
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart'
    as _i913;
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart'
    as _i814;
import 'package:medicail/features/settings/data/repositories/secure_user_preferences_repository.dart'
    as _i104;
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart'
    as _i460;
import 'package:medicail/features/settings/presentation/bloc/settings_bloc.dart'
    as _i488;
import 'package:medicail/features/settings/presentation/notifier/settings_notifier.dart'
    as _i713;
import 'package:medicail/features/tutorial/data/repositories/tutorial_repository_impl.dart'
    as _i511;
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart'
    as _i79;
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart'
    as _i306;
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
    gh.lazySingleton<_i541.AuthNotifier>(() => _i541.AuthNotifier());
    gh.lazySingleton<_i1040.ExerciseCatalogDataSource>(
      () => _i1040.ExerciseCatalogDataSource(),
    );
    gh.lazySingleton<_i564.AssetNoteTemplateDataSource>(
      () => _i564.AssetNoteTemplateDataSource(),
    );
    gh.lazySingleton<_i713.SettingsNotifier>(() => _i713.SettingsNotifier());
    gh.lazySingleton<_i345.AppSessionStorage>(
      () => _i345.SecureAppSessionStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i460.UserPreferencesRepository>(
      () => _i104.SecureUserPreferencesRepository(
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i830.SecureStoragePatientRepository>(
      () => _i830.SecureStoragePatientRepository(
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i913.SecureStorageRecordingSessionRepository>(
      () => _i913.SecureStorageRecordingSessionRepository(
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i488.SettingsBloc>(
      () => _i488.SettingsBloc(
        gh<_i460.UserPreferencesRepository>(),
        gh<_i713.SettingsNotifier>(),
      ),
    );
    gh.lazySingleton<_i21.AudioCaptureService>(
      () => _i439.SpeechToTextServiceImpl(),
    );
    gh.lazySingleton<_i366.AudioPlaybackService>(
      () => _i475.JustAudioPlaybackService(),
    );
    gh.lazySingleton<_i760.AuthTokenStorage>(
      () => _i249.SecureStorageAuthToken(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i1038.AppRouter>(
      () => _i1038.AppRouter(gh<_i541.AuthNotifier>()),
    );
    gh.lazySingleton<_i79.TutorialRepository>(
      () => _i511.TutorialRepositoryImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i506.PatientExerciseRepository>(
      () =>
          _i993.PatientExerciseRepositoryImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i144.NoteTemplateRepository>(
      () => _i93.NoteTemplateRepositoryImpl(
        gh<_i564.AssetNoteTemplateDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i583.GoRouter>(
      () => registerModule.goRouter(gh<_i1038.AppRouter>()),
    );
    gh.factory<_i297.NoteTemplateBloc>(
      () => _i297.NoteTemplateBloc(gh<_i144.NoteTemplateRepository>()),
    );
    gh.lazySingleton<_i814.RecordingSessionRepository>(
      () => _i932.DynamicRecordingSessionRepository(
        gh<_i913.SecureStorageRecordingSessionRepository>(),
      ),
    );
    gh.lazySingleton<_i643.ExerciseRepository>(
      () =>
          _i858.ExerciseRepositoryImpl(gh<_i1040.ExerciseCatalogDataSource>()),
    );
    gh.lazySingleton<_i737.AuthInterceptor>(
      () => _i737.AuthInterceptor(gh<_i760.AuthTokenStorage>()),
    );
    gh.factory<_i794.VoiceCaptureBloc>(
      () => _i794.VoiceCaptureBloc(
        gh<_i21.AudioCaptureService>(),
        gh<_i814.RecordingSessionRepository>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i155.AppConfig>(),
        gh<_i737.AuthInterceptor>(),
        gh<_i945.LoggingInterceptor>(),
        gh<_i479.ErrorInterceptor>(),
      ),
    );
    gh.factory<_i306.TutorialBloc>(
      () => _i306.TutorialBloc(
        gh<_i79.TutorialRepository>(),
        gh<_i814.RecordingSessionRepository>(),
      ),
    );
    gh.lazySingleton<_i1005.ApiClient>(() => _i1005.ApiClient(gh<_i361.Dio>()));
    gh.factory<_i545.ApiPatientRepository>(
      () => _i545.ApiPatientRepository(gh<_i1005.ApiClient>()),
    );
    gh.lazySingleton<_i790.AuthRepository>(
      () => _i985.AuthRepositoryImpl(
        gh<_i1005.ApiClient>(),
        gh<_i760.AuthTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i390.PatientRepository>(
      () => _i238.DynamicPatientRepository(
        gh<_i545.ApiPatientRepository>(),
        gh<_i830.SecureStoragePatientRepository>(),
        gh<_i760.AuthTokenStorage>(),
      ),
    );
    gh.factory<_i802.PatientDetailBloc>(
      () => _i802.PatientDetailBloc(
        gh<_i390.PatientRepository>(),
        gh<_i814.RecordingSessionRepository>(),
      ),
    );
    gh.factory<_i301.PatientBloc>(
      () => _i301.PatientBloc(gh<_i390.PatientRepository>()),
    );
    gh.factory<_i250.AuthBloc>(
      () => _i250.AuthBloc(
        gh<_i790.AuthRepository>(),
        gh<_i541.AuthNotifier>(),
        gh<_i345.AppSessionStorage>(),
        gh<_i760.AuthTokenStorage>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i91.RegisterModule {}
