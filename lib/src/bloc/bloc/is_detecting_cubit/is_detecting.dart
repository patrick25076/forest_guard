import 'package:flutter_bloc/flutter_bloc.dart';

part 'is_detecting_state.dart';

class IsDetectingCubit extends Cubit<IsDetectingState> {
  IsDetectingCubit() : super(IsNotDetecting());

  void startDetecting() => emit(Isdetecting());

  void stopDetecting() => emit(IsNotDetecting());
}
