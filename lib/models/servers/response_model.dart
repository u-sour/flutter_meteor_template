import 'package:toastification/toastification.dart';

class ResponseModel {
  final int status;
  final String? title;
  final String description;
  final ToastificationType type;

  const ResponseModel(
      {required this.status,
      this.title,
      required this.description,
      required this.type});
}
