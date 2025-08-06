import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/utils.dart';
import '../../../../shared/widgets/common_title_text.dart';
import '../bloc/auth_bloc.dart';
import '../../../../app/router/route_args.dart';

class SampleWidget extends StatefulWidget {
  const SampleWidget({super.key,this.sampleWidgetArgs});
  final SampleWidgetArgs? sampleWidgetArgs;

  @override
  State<SampleWidget> createState() => _SampleWidgetState();
}

class _SampleWidgetState extends State<SampleWidget> {
  final _bloc = AuthBloc();
  @override
  void initState() {
    super.initState();
    _bloc.add(OnLoginEvent());
  }

  @override
  Widget build(final BuildContext context) {
    return BlocProvider(
      create: (final context) => _bloc,
      child: Scaffold(
        body: BlocBuilder<AuthBloc,AuthState>(
              builder: (final context, final state) {
            if (state.apiCallStatus is StateLoaded) {
              Utils.instance.showToast('Success');
              return ListView.builder(
                itemBuilder: (final context, final index) {
                  return CommonTitleText(text: state.sampleModel?.data?[index].employeeName ?? '');
                },
                itemCount: state.sampleModel?.data?.length,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
