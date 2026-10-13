import '../models/component_mapper.dart';
import '../models/conversion_result.dart';

enum ConversionStatus { idle, converting, success, failure }

enum PreviewSize {
  mobile('Mobile', 390, 844),
  tablet('Tablet', 768, 1024),
  desktop('Desktop', 1280, 800);

  const PreviewSize(this.label, this.width, this.height);
  final String label;
  final double width;
  final double height;
}

/// The four areas of the workspace; any combination can be shown.
enum WorkspacePane {
  htmlCode('HTML code'),
  htmlPreview('HTML preview'),
  flutterPreview('Flutter preview'),
  dartCode('Dart code');

  const WorkspacePane(this.label);
  final String label;
}

/// A short-lived message shown as a toast (copy / download / load results).
class ActionFeedback {
  const ActionFeedback(this.id, this.message, {this.isError = false});
  final int id;
  final String message;
  final bool isError;
}

class ConverterState {
  const ConverterState({
    this.html = '',
    this.fileName,
    this.previewHtml = '',
    this.previewVersion = 0,
    this.status = ConversionStatus.idle,
    this.result,
    this.convertedSource,
    this.dartSource,
    this.generatedLines = 0,
    this.error,
    this.previewSize = PreviewSize.mobile,
    this.htmlPreviewSize = PreviewSize.mobile,
    this.visiblePanes = defaultPanes,
    this.previewIssues = const [],
    this.feedback,
    this.mapper,
    this.convertedMapper,
    this.mapperErrors = const [],
  });

  /// Current contents of the editor.
  final String html;

  /// Name of the uploaded file, if the input came from one.
  final String? fileName;

  /// HTML shown in the sandboxed preview (debounced copy of [html]).
  final String previewHtml;

  /// Bumped to force the HTML preview to reload.
  final int previewVersion;

  final ConversionStatus status;

  /// Intermediate representation of the last successful conversion.
  final ConversionResult? result;

  /// Input the last successful conversion was made from.
  final String? convertedSource;

  final String? dartSource;
  final int generatedLines;
  final String? error;
  final PreviewSize previewSize;

  /// Device size of the HTML (browser) preview.
  final PreviewSize htmlPreviewSize;

  /// Panes currently shown in the workspace row.
  final Set<WorkspacePane> visiblePanes;

  static const defaultPanes = {
    WorkspacePane.htmlCode,
    WorkspacePane.flutterPreview,
    WorkspacePane.dartCode,
  };

  /// Layout / rendering problems reported by the Flutter preview.
  final List<String> previewIssues;
  final ActionFeedback? feedback;

  /// Active component mapper (custom widget library), if any.
  final ComponentMapper? mapper;

  /// Mapper used by the last successful conversion.
  final ComponentMapper? convertedMapper;

  /// Problems found in the last mapper that failed to load.
  final List<String> mapperErrors;

  bool get hasInput => html.trim().isNotEmpty;
  bool get isConverting => status == ConversionStatus.converting;

  /// The editor changed after the last conversion.
  bool get isOutdated =>
      result != null &&
      (convertedSource != html || convertedMapper?.source != mapper?.source);

  List<ConversionWarning> get warnings => result?.warnings ?? const [];

  ConverterState copyWith({
    String? html,
    String? fileName,
    bool clearFileName = false,
    String? previewHtml,
    int? previewVersion,
    ConversionStatus? status,
    ConversionResult? result,
    String? convertedSource,
    String? dartSource,
    int? generatedLines,
    String? error,
    bool clearError = false,
    bool clearResult = false,
    PreviewSize? previewSize,
    PreviewSize? htmlPreviewSize,
    Set<WorkspacePane>? visiblePanes,
    List<String>? previewIssues,
    ActionFeedback? feedback,
    ComponentMapper? mapper,
    bool clearMapper = false,
    ComponentMapper? convertedMapper,
    List<String>? mapperErrors,
  }) {
    return ConverterState(
      html: html ?? this.html,
      fileName: clearFileName ? null : (fileName ?? this.fileName),
      previewHtml: previewHtml ?? this.previewHtml,
      previewVersion: previewVersion ?? this.previewVersion,
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      convertedSource: clearResult
          ? null
          : (convertedSource ?? this.convertedSource),
      dartSource: clearResult ? null : (dartSource ?? this.dartSource),
      generatedLines: clearResult ? 0 : (generatedLines ?? this.generatedLines),
      error: clearError ? null : (error ?? this.error),
      previewSize: previewSize ?? this.previewSize,
      htmlPreviewSize: htmlPreviewSize ?? this.htmlPreviewSize,
      visiblePanes: visiblePanes ?? this.visiblePanes,
      previewIssues: previewIssues ?? this.previewIssues,
      feedback: feedback ?? this.feedback,
      mapper: clearMapper ? null : (mapper ?? this.mapper),
      convertedMapper: clearResult
          ? null
          : (convertedMapper ?? this.convertedMapper),
      mapperErrors: mapperErrors ?? this.mapperErrors,
    );
  }
}
