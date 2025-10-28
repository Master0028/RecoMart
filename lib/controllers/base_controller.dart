import 'package:recomart/components/custom/dialog.dart';
import 'package:recomart/services/app_exceptions.dart';

mixin BaseController {
  void handleError(error) {
    var message = error.message;
    if (error is BadRequestException) {
      DialogHelper.showDialog(description: message);
    } else if (error is FetchDataException) {
      DialogHelper.showDialog(description: message);
    } else if (error is ApiNotRespondingException) {
      DialogHelper.showDialog(description: 'Oops! Server is not responding');
    } else if (error is UnAuthorizedException) {
      DialogHelper.showDialog(description: 'Unauthorized');
    } else {}
  }
}
