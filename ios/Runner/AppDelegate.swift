import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }

    let channel = FlutterMethodChannel(name: "/gallery", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      switch (call.method) {
      case "getItemCount": result(self.getGalleryImageCount())
      case "getItem":
        let index = call.arguments as? Int ?? 0
        self.dataForGalleryItem(index: index, completion: { (data, id, created, location) in
            result([
                "data": data ?? Data(),
                "id": id,
                "created": created,
                "location": location
            ])
        })
      case "getItemHD":
        let index = call.arguments as? Int ?? 0
        self.dataForGalleryItemHD(index: index, completion: { (data, id, created, location) in
            result([
                "data": data ?? Data(),
                "id": id,
                "created": created,
                "location": location
            ])
        })
      default: result(FlutterError(code: "0", message: nil, details: nil))
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func dataForGalleryItem(index: Int, completion: @escaping (Data?, String, Int, String) -> Void) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
    
    let collection: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
    if (index >= collection.count) {
      return
    }

    let asset = collection.object(at: index)

    let options = PHImageRequestOptions()
    options.deliveryMode = .fastFormat
    options.isSynchronous = true

    let imageSize = CGSize(width: 250,
                           height: 250)

    let imageManager = PHCachingImageManager()
    imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: options) { (image, info) in
      if let image = image {
        let data = UIImageJPEGRepresentation(image, 0.9)
        completion(data,
                   asset.localIdentifier,
                   Int(asset.creationDate?.timeIntervalSince1970 ?? 0),
                   "\(asset.location ?? CLLocation())")
      } else {
        completion(nil, "", 0, "")
      }
    }
  }

  func dataForGalleryItemHD(index: Int, completion: @escaping (Data?, String, Int, String) -> Void) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
    
    let collection: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
    if (index >= collection.count) {
      return
    }

    let asset = collection.object(at: index)

    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isSynchronous = true

    let imageManager = PHCachingImageManager()
    imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, info) in
      if let image = image {
        let data = UIImageJPEGRepresentation(image, 1.0)
        completion(data,
                   asset.localIdentifier,
                   Int(asset.creationDate?.timeIntervalSince1970 ?? 0),
                   "\(asset.location ?? CLLocation())")
      } else {
        completion(nil, "", 0, "")
      }
    }
  }

  func getGalleryImageCount() -> Int {
    let fetchOptions = PHFetchOptions()
    fetchOptions.includeHiddenAssets = true

    let collection: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
    return collection.count
  }
}
