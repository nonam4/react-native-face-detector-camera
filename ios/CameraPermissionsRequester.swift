import ExpoModulesCore
import AVFoundation

let cameraKey = "NSCameraUsageDescription"

protocol BaseCameraRequester {
  var mediaType: AVMediaType { get }
  func permissionWith(status systemStatus: AVAuthorizationStatus) -> [AnyHashable: Any]
  func permissions(for key: String, service: String) -> [AnyHashable: Any]
  func requestAccess(handler: @escaping (Bool) -> Void)
}

extension BaseCameraRequester {
  func permissions(for key: String, service: String) -> [AnyHashable: Any] {
    var systemStatus: AVAuthorizationStatus
    let description = Bundle.main.infoDictionary?[key] as? String

    if let description {
      systemStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
    } else {
      EXFatal(EXErrorWithMessage("""
      This app is missing \(key),
      so \(service) service will fail. Add this entry to your bundle's Info.plist.
      """))
      systemStatus = .denied
    }

    return permissionWith(status: systemStatus)
  }

  func permissionWith(status systemStatus: AVAuthorizationStatus) -> [AnyHashable: Any] {
    var status: EXPermissionStatus

    switch systemStatus {
    case .authorized:
      status = EXPermissionStatusGranted
    case .denied, .restricted:
      status = EXPermissionStatusDenied
    case .notDetermined:
      fallthrough
    @unknown default:
      status = EXPermissionStatusUndetermined
    }

    return [
      "status": status.rawValue
    ]
  }

  func requestAccess(handler: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: mediaType, completionHandler: handler)
  }
}

class CameraOnlyPermissionRequester: NSObject, EXPermissionsRequester, BaseCameraRequester {
  let mediaType: AVMediaType = .video

  static func permissionType() -> String {
    "camera"
  }

  func getPermissions() -> [AnyHashable: Any] {
    return permissions(for: cameraKey, service: "video")
  }

  func requestPermissions(resolver resolve: @escaping EXPromiseResolveBlock, rejecter reject: EXPromiseRejectBlock) {
    requestAccess { [weak self] _ in
      resolve(self?.getPermissions())
    }
  }
}

class CameraPermissionRequester: NSObject, EXPermissionsRequester, BaseCameraRequester {
  let mediaType: AVMediaType = .video

  static func permissionType() -> String {
    "camera"
  }

  func getPermissions() -> [AnyHashable: Any] {
    var systemStatus: AVAuthorizationStatus
    let cameraUsuageDescription = Bundle.main.infoDictionary?[cameraKey] as? String

    if let cameraUsuageDescription {
      systemStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
    } else {
      EXFatal(EXErrorWithMessage("""
      This app is missing either NSCameraUsageDescription, so video 
      service will fail. Add this entry to your bundle's Info.plist
      """))
      systemStatus = .denied
    }

    return permissionWith(status: systemStatus)
  }

  func requestPermissions(resolver resolve: @escaping EXPromiseResolveBlock, rejecter reject: EXPromiseRejectBlock) {
    requestAccess { [weak self] _ in
      resolve(self?.getPermissions())
    }
  }
}
