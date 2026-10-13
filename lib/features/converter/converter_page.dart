import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/app_theme.dart';
import 'cubit/converter_cubit.dart';
import 'cubit/converter_state.dart';
import 'widgets/converter_toolbar.dart';
import 'widgets/dart_code_panel.dart';
import 'widgets/flutter_preview_panel.dart';
import 'widgets/html_editor_panel.dart';
import 'widgets/html_preview_panel.dart';

/// The ElementFlow workspace: any combination of the four panes in one row.
class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  /// Below this width the panes become tabs.
  static const _tabBreakpoint = 720.0;

  /// Narrowest a pane may get before the row scrolls horizontally.
  static const _minPaneWidth = 320.0;

  int _tab = 0;

  static Widget _paneWidget(WorkspacePane pane) => switch (pane) {
    WorkspacePane.htmlCode => const HtmlEditorPanel(),
    WorkspacePane.htmlPreview => const HtmlPreviewPanel(),
    WorkspacePane.flutterPreview => const FlutterPreviewPanel(),
    WorkspacePane.dartCode => const DartCodePanel(),
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConverterCubit, ConverterState>(
      listenWhen: (a, b) =>
          b.feedback != null && a.feedback?.id != b.feedback?.id,
      listener: (context, state) => _toast(context, state.feedback!),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, box) {
            final tabs = box.maxWidth < _tabBreakpoint;
            return Column(
              children: [
                AppHeader(compact: box.maxWidth < 900),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(tabs ? 8 : 14),
                    child: tabs ? _tabLayout() : _rowLayout(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _rowLayout() {
    return Column(
      children: [
        const ControlBar(),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<ConverterCubit, ConverterState>(
            buildWhen: (a, b) => a.visiblePanes != b.visiblePanes,
            builder: (context, state) {
              final panes = [
                for (final p in WorkspacePane.values)
                  if (state.visiblePanes.contains(p)) p,
              ];
              return LayoutBuilder(
                builder: (context, box) {
                  const gap = 12.0;
                  final fits =
                      box.maxWidth >=
                      panes.length * _minPaneWidth + (panes.length - 1) * gap;
                  final children = [
                    for (final p in panes)
                      KeyedSubtree(key: ValueKey(p), child: _paneWidget(p)),
                  ];
                  if (fits) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          Expanded(child: children[i]),
                        ],
                      ],
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: children.length,
                    separatorBuilder: (_, _) => const SizedBox(width: gap),
                    itemBuilder: (_, i) =>
                        SizedBox(width: _minPaneWidth, child: children[i]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tabLayout() {
    const panels = <Widget>[
      HtmlEditorPanel(),
      HtmlPreviewPanel(),
      FlutterPreviewPanel(),
      DartCodePanel(),
    ];
    return BlocListener<ConverterCubit, ConverterState>(
      // Jump to the result after a successful conversion.
      listenWhen: (a, b) =>
          a.status == ConversionStatus.converting &&
          b.status == ConversionStatus.success,
      listener: (context, _) => setState(() => _tab = 2),
      child: Column(
        children: [
          WorkspaceTabs(
            labels: const ['HTML', 'Preview', 'Flutter', 'Dart'],
            icons: const [
              Icons.code_rounded,
              Icons.language_rounded,
              Icons.flutter_dash_rounded,
              Icons.terminal_rounded,
            ],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(index: _tab, children: panels),
          ),
          const ConvertBar(compact: true),
        ],
      ),
    );
  }

  void _toast(BuildContext context, ActionFeedback f) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              f.isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 18,
              color: f.isError ? EF.error : EF.success,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(f.message)),
          ],
        ),
      ),
    );
  }
}
