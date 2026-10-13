import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/conversion_result.dart';
import '../services/conversion_service.dart';
import '../services/dart_code_generator.dart';
import '../services/samples.dart';
import '../services/web_bridge.dart';
import 'converter_state.dart';

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit({
    ConversionService? converter,
    DartCodeGenerator? generator,
    this.previewDebounce = const Duration(milliseconds: 400),
  }) : _converter = converter ?? ConversionService(),
       _generator = generator ?? DartCodeGenerator(),
       super(const ConverterState());

  final ConversionService _converter;
  final DartCodeGenerator _generator;
  final Duration previewDebounce;

  Timer? _debounce;
  int _feedbackId = 0;

  static const downloadName = 'generated_page.dart';

  // ----------------------------------------------------------- input

  /// Called for every editor change. The iframe preview follows after a
  /// short debounce so typing stays smooth.
  void updateHtml(String html) {
    if (html == state.html) return;
    emit(state.copyWith(html: html, clearError: true));
    _debounce?.cancel();
    _debounce = Timer(previewDebounce, () {
      if (!isClosed) emit(state.copyWith(previewHtml: state.html));
    });
  }

  void loadSample(HtmlSample sample) {
    _setInput(sample.html, fileName: null);
    _feedback('Loaded sample: ${sample.name}');
  }

  /// Loads an uploaded file. Reading happens locally; nothing is uploaded.
  void loadHtmlFile(String name, Uint8List bytes) {
    final lower = name.toLowerCase();
    if (!lower.endsWith('.html') && !lower.endsWith('.htm')) {
      _feedback('"$name" is not an .html or .htm file', error: true);
      return;
    }
    String text;
    try {
      text = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      text = utf8.decode(bytes, allowMalformed: true);
      _feedback(
        '"$name" is not valid UTF-8; some characters were replaced',
        error: true,
      );
    }
    if (text.trim().isEmpty) {
      _feedback('"$name" is empty', error: true);
      return;
    }
    _setInput(text, fileName: name);
    _feedback('Loaded $name');
  }

  void reportFileError(String message) => _feedback(message, error: true);

  void clearInput() {
    _debounce?.cancel();
    emit(
      ConverterState(
        previewSize: state.previewSize,
        previewVersion: state.previewVersion + 1,
      ),
    );
  }

  void _setInput(String html, {required String? fileName}) {
    _debounce?.cancel();
    emit(
      state.copyWith(
        html: html,
        previewHtml: html,
        fileName: fileName,
        clearFileName: fileName == null,
        clearError: true,
        previewVersion: state.previewVersion + 1,
      ),
    );
  }

  void refreshHtmlPreview() {
    emit(
      state.copyWith(
        previewHtml: state.html,
        previewVersion: state.previewVersion + 1,
      ),
    );
  }

  // ------------------------------------------------------- conversion

  Future<void> convertToFlutter() async {
    if (state.isConverting) return;
    if (!state.hasInput) {
      emit(
        state.copyWith(
          status: ConversionStatus.failure,
          error: 'Nothing to convert: paste some HTML or upload a file first.',
          clearResult: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ConversionStatus.converting,
        clearError: true,
        previewIssues: const [],
      ),
    );
    // Let the spinner paint before the synchronous conversion starts.
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final source = state.html;
    try {
      final result = _converter.convert(source);
      final code = _generator.generate(result);
      emit(
        state.copyWith(
          status: ConversionStatus.success,
          result: result,
          convertedSource: source,
          dartSource: code.source,
          generatedLines: code.lineCount,
          previewHtml: source,
          clearError: true,
        ),
      );
    } on ConversionException catch (e) {
      emit(
        state.copyWith(
          status: ConversionStatus.failure,
          error: e.message,
          clearResult: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConversionStatus.failure,
          error: 'Conversion failed unexpectedly: $e',
          clearResult: true,
        ),
      );
    }
  }

  void setPreviewSize(PreviewSize size) {
    if (size == state.previewSize) return;
    emit(state.copyWith(previewSize: size));
  }

  void setHtmlPreviewSize(PreviewSize size) {
    if (size == state.htmlPreviewSize) return;
    emit(state.copyWith(htmlPreviewSize: size));
  }

  /// Shows or hides a workspace pane. At least one pane stays visible.
  void togglePane(WorkspacePane pane) {
    final panes = {...state.visiblePanes};
    if (!panes.remove(pane)) panes.add(pane);
    if (panes.isEmpty) return;
    emit(state.copyWith(visiblePanes: panes));
  }

  /// Rendering problems found while painting the Flutter preview.
  void reportPreviewIssue(String message) {
    if (state.previewIssues.contains(message) ||
        state.previewIssues.length >= 5) {
      return;
    }
    emit(state.copyWith(previewIssues: [...state.previewIssues, message]));
  }

  // ----------------------------------------------------------- export

  Future<void> copyCode() async {
    final code = state.dartSource;
    if (code == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: code));
      _feedback('Dart code copied to clipboard');
    } catch (_) {
      _feedback(
        'Could not access the clipboard. Select the code and copy it manually.',
        error: true,
      );
    }
  }

  void downloadCode() {
    final code = state.dartSource;
    if (code == null) return;
    if (downloadTextFile(downloadName, code)) {
      _feedback('Downloaded $downloadName');
    } else {
      _feedback('The download was blocked by the browser', error: true);
    }
  }

  void _feedback(String message, {bool error = false}) {
    emit(
      state.copyWith(
        feedback: ActionFeedback(++_feedbackId, message, isError: error),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
