import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import 'code_highlighter.dart';
import 'converter_toolbar.dart';
import 'panel_frame.dart';

/// Editable HTML/CSS input with syntax highlighting and file upload.
class HtmlEditorPanel extends StatefulWidget {
  const HtmlEditorPanel({super.key});

  @override
  State<HtmlEditorPanel> createState() => _HtmlEditorPanelState();
}

class _HtmlEditorPanelState extends State<HtmlEditorPanel> {
  final _controller = HtmlHighlightController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<ConverterCubit>().state.html;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final cubit = context.read<ConverterCubit>();
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['html', 'htm'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      cubit.loadHtmlFile(file.name, bytes);
    } catch (e) {
      cubit.reportFileError('The file could not be read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocConsumer<ConverterCubit, ConverterState>(
      listenWhen: (a, b) => b.html != _controller.text,
      listener: (context, state) {
        // Programmatic changes (sample, upload, clear).
        _controller.value = TextEditingValue(
          text: state.html,
          selection: const TextSelection.collapsed(offset: 0),
        );
      },
      buildWhen: (a, b) =>
          a.fileName != b.fileName ||
          a.error != b.error ||
          a.status != b.status ||
          a.html.isEmpty != b.html.isEmpty ||
          a.html.length != b.html.length,
      builder: (context, state) {
        final lines = state.html.isEmpty
            ? 0
            : '\n'.allMatches(state.html).length + 1;
        return PanelFrame(
          title: 'HTML / CSS',
          icon: Icons.code_rounded,
          actions: [
            IconAction(
              icon: Icons.upload_file_rounded,
              tooltip: 'Upload an .html or .htm file',
              onPressed: _pickFile,
            ),
            IconAction(
              icon: Icons.delete_sweep_outlined,
              tooltip: 'Clear input',
              onPressed: state.hasInput ? cubit.clearInput : null,
            ),
          ],
          footer: _Footer(
            fileName: state.fileName,
            lines: lines,
            chars: state.html.length,
            error: state.status == ConversionStatus.failure
                ? state.error
                : null,
          ),
          child: Stack(
            children: [
              Scrollbar(
                controller: _scroll,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  scrollController: _scroll,
                  onChanged: cubit.updateHtml,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  autocorrect: false,
                  enableSuggestions: false,
                  spellCheckConfiguration:
                      const SpellCheckConfiguration.disabled(),
                  style: EF.code(size: 12.5),
                  cursorColor: EF.accent,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText:
                        'Paste HTML and CSS here, or upload a file.\n\n'
                        'Inline styles, <style> blocks, class and id selectors, '
                        'images and form controls are supported.',
                    hintStyle: EF.code(size: 12.5, color: EF.faint),
                  ),
                ),
              ),
              if (!state.hasInput)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _QuickStart(onUpload: _pickFile),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickStart extends StatelessWidget {
  const _QuickStart({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SamplesMenu(label: 'Load sample'),
        const SizedBox(width: 8),
        GhostButton(
          label: 'Upload file',
          icon: Icons.upload_file_rounded,
          onPressed: onUpload,
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.fileName,
    required this.lines,
    required this.chars,
    required this.error,
  });

  final String? fileName;
  final int lines;
  final int chars;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: EF.error.withValues(alpha: 0.1),
              border: const Border(top: BorderSide(color: EF.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: EF.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: EF.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: EF.border)),
          ),
          child: Row(
            children: [
              if (fileName != null) ...[
                const Icon(
                  Icons.insert_drive_file_outlined,
                  size: 13,
                  color: EF.accent,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    fileName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: EF.text),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              const Spacer(),
              Text(
                '$lines lines · $chars chars',
                style: const TextStyle(fontSize: 11.5, color: EF.faint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
