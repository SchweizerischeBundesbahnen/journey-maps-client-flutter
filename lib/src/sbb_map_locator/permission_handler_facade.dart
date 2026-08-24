import 'package:permission_handler/permission_handler.dart';

/// Facade for the permission_handler package.
///
/// This class is used by [SBBMapLocator] as a facade to the
/// [permission_handler package](https://pub.dev/packages/permission_handler).
///
/// It allows primarily for unit testing using mockito.
class PermissionHandlerFacade {
  /// Indicates whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    return serviceStatus.isEnabled;
  }

  /// Indicates whether the app has been granted the
  /// [Permission.locationWhenInUse] permission by the user.
  Future<PermissionStatus> checkLocationPermission() {
    return Permission.locationWhenInUse.status;
  }

  /// Request permission to access the location of the device while in use.
  ///
  /// Returns a [Future] which when completes indicates if
  /// the user granted permission to access the device's location.
  ///
  /// If the permission has been permanently denied, the request will not
  /// prompt the user and completes with [PermissionStatus.permanentlyDenied].
  Future<PermissionStatus> requestLocationPermission() {
    return Permission.locationWhenInUse.request();
  }
}
