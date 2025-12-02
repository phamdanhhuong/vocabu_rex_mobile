// Achievement Module Barrel File
// This file exports all public APIs from the achievement module

// Domain Layer
export 'domain/entities/achievement_entity.dart';
export 'domain/repositories/achievement_repository.dart';
export 'domain/usecases/get_achievements_usecase.dart';
export 'domain/usecases/get_achievements_by_category_usecase.dart';
export 'domain/usecases/get_recent_achievements_usecase.dart';

// Data Layer
export 'data/models/achievement_model.dart';
export 'data/service/achievement_service.dart';
export 'data/datasources/achievement_datasource.dart';
export 'data/datasources/achievement_datasource_impl.dart';
export 'data/repositories/achievement_repository_impl.dart';

// UI Layer
export 'ui/blocs/achievement_bloc.dart';
export 'ui/widgets/achievement_record_card.dart';
export 'ui/widgets/achievement_tile.dart';
export 'ui/widgets/achievement_detail_dialog.dart';
export 'ui/widgets/all_achievements_view.dart';
