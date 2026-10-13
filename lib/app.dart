import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/converter/converter_page.dart';
import 'features/converter/cubit/converter_cubit.dart';
import 'theme/app_theme.dart';

class ElementFlowApp extends StatelessWidget {
  const ElementFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConverterCubit(),
      child: MaterialApp(
        title: 'ElementFlow — From HTML to Flutter. Seamlessly.',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const ConverterPage(),
      ),
    );
  }
}
