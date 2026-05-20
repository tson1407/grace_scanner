/// Static strings for non-i18n MVP.
class AppStrings {
  AppStrings._();

  // ── App ──
  static const String appName = 'ScanFlow';

  // ── Home ──
  static const String recentDocuments = 'Recent Documents';
  static const String noDocuments = 'No documents yet';
  static const String noDocumentsSubtitle = 'Tap the scan button to get started';

  // ── Camera ──
  static const String cameraPermissionTitle = 'Camera Access Required';
  static const String cameraPermissionMessage =
      'ScanFlow needs camera access to scan documents.';
  static const String capture = 'Capture';
  static const String pagesCaputred = 'pages captured';

  // ── Flash ──
  static const String flashOff = 'Off';
  static const String flashOn = 'On';
  static const String flashAuto = 'Auto';

  // ── Actions ──
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String rename = 'Rename';
  static const String done = 'Done';

  // ── Errors ──
  static const String genericError = 'Something went wrong';
  static const String cameraError = 'Camera error occurred';
  static const String storageError = 'Could not access storage';
}
