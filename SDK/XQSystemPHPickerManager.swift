//
//  XQSystemPhotoPickerManager.swift
//  XQSystemImagePickerDemo
//
//  Created by WXQ on 2020/9/18.
//

import UIKit

import PhotosUI
import MobileCoreServices

@objc public enum XQSystemPhotoPickerManagerResourceType: Int {
    /// 全部
    case all = 0
    /// 选择图片
    case image = 1
    /// 选择视频
    case video = 2
}

/// 根据手机版本，自动判断使用 XQSystemUIImagePickerManager 还是 XQSystemPHPickerManager
public class XQSystemPhotoPickerManager: NSObject {
    
    /// imgs 是 UIImage
    /// urls 是视频的URL
    /// 如果是空, 那代表用户什么都不选, 或者点取消
    public typealias XQSystemPhotoPickerManagerCallback = (_ imgs: [UIImage], _ urls:[URL] ) -> ()
    /// 点击取消回调
    public typealias XQSystemPhotoPickerManagerCancelCallback = () -> ()
    
    /// 选择文件
    ///
    /// - note: 根据手机版本，自动判断使用 XQSystemUIImagePickerManager 还是 XQSystemPHPickerManager
    ///
    /// - Parameters:
    ///   - selectionLimit: 最多可选多少张( iOS 14 才支持这个属性, iOS14以下，则只可选一张)
    ///   - filter: 选择资源类型
    ///   - callback: 返回已选资源
    @objc public class func showPicker(with vc: UIViewController, selectionLimit: Int = 1, filter: XQSystemPhotoPickerManagerResourceType = .all, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?, cancelCallback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCancelCallback? = nil) {
        
        if #available(iOS 14, *) {
            
            var f: PHPickerFilter?
            
            switch filter {
            
            case .all:
                break
                
            case .image:
                f = .images
                
            case .video:
                f = .videos
                
            default:
                break
                
            }
            
            XQSystemPHPickerManager.showPicker(with: vc, selectionLimit: selectionLimit, filter: f, callback: callback, cancelCallback: cancelCallback)
        }else {
            XQSystemUIImagePickerManager.showPicker(with: vc, filter: filter, callback: callback, cancelCallback: cancelCallback)
        }
        
    }
    
    /// 退出选择照片
    public static func dismissPicker(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if #available(iOS 14, *) {
            XQSystemPHPickerManager.dismissPicker(animated: flag, completion: completion)
        }else {
            XQSystemUIImagePickerManager.dismissPicker(animated: flag, completion: completion)
        }
    }
    
}

/// 很早就一直支持的系统选择图片库，14.0 版本之后，苹果推荐使用 PhotosUI 系统库
public class XQSystemUIImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 选择图片
    public static func showPicker(with vc: UIViewController, filter: XQSystemPhotoPickerManagerResourceType? = .all, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?, cancelCallback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCancelCallback? = nil) {
        
        if (!UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            print("不支持打开相册")
            return
        }
        
        if let _ = _systemPhotoPickerManager {
            return
        }
        
        _systemPhotoPickerManager = XQSystemUIImagePickerManager()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
                        
        // 设置资源来源（相册、相机、图库之一）
        imagePickerController.sourceType = .photoLibrary
        
        // 允许的视屏质量（如果质量选取的质量过高，会自动降低质量）
//        imagePickerController.videoQuality = .typeHigh
        
        var mediaTypes = [String]()
        
        switch filter {
        
        case .all:
            let typeImage = String(kUTTypeImage)
            mediaTypes.append(typeImage)
            
            let typeMovie = String(kUTTypeMovie)
            mediaTypes.append(typeMovie)
        
        case .image:
            let typeImage = String(kUTTypeImage)
            mediaTypes.append(typeImage)
            
        case .video:
            let typeMovie = String(kUTTypeMovie)
            mediaTypes.append(typeMovie)
            
        default:
            break
        }
        
        imagePickerController.mediaTypes = mediaTypes
                        
        // 设置代理，遵守UINavigationControllerDelegate, UIImagePickerControllerDelegate 协议
        imagePickerController.delegate = _systemPhotoPickerManager
        
        // 是否允许编辑（YES：图片选择完成进入编辑模式）
        //                imagePickerVC.allowsEditing = YES;
        
        _systemPhotoPickerManager?.callback = callback
        _systemPhotoPickerManager?.cancelCallback = cancelCallback
        
        vc.present(imagePickerController, animated: true, completion: nil)
        _systemPhotoPickerManager?.imagePickerController = imagePickerController
    }
    
    /// 退出选择照片
    public static func dismissPicker(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let obj = _systemPhotoPickerManager {
            obj.imagePickerController?.dismiss(animated: flag, completion: completion)
            _systemPhotoPickerManager = nil
        }
    }
    
    private static var _systemPhotoPickerManager: XQSystemUIImagePickerManager?
    
    private var callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?
    private var cancelCallback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCancelCallback?
    
    private var imagePickerController: UIImagePickerController?
    
    private var imgs = [UIImage]()
    private var urls = [URL]()
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        print(#function, info)
        
        picker.dismiss(animated: true) { [unowned self] in
            
            if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imgs.append(img)
            }
            
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.urls.append(url)
            }
            
            self.callback?(self.imgs, self.urls)
            XQSystemUIImagePickerManager._systemPhotoPickerManager = nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print(#function)
        picker.dismiss(animated: true) { [unowned self] in
//            self.callback?(self.imgs, self.urls)
            self.cancelCallback?()
            XQSystemUIImagePickerManager._systemPhotoPickerManager = nil
        }
    }
    
//    deinit {
//        print(#function)
//    }
    
}

/// 14.0 版本之后，苹果推荐使用 PhotosUI 系统库
@available(iOS 14, *)
public class XQSystemPHPickerManager: NSObject, PHPickerViewControllerDelegate {
    
    /// 跳转选择资源
    /// - Parameters:
    ///   - selectionLimit: 最大可选多少张. 默认1张, 传 0 则是系统可选的上限
    ///   - filter: 要过滤可选内容. nil 就不过滤
    public static func showPicker(with vc: UIViewController, selectionLimit: Int = 1, filter: PHPickerFilter? = nil, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?, cancelCallback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCancelCallback? = nil) {
        
        if let _ = _systemPhotoPickerManager {
            return
        }
        
        _systemPhotoPickerManager = XQSystemPHPickerManager()
        _systemPhotoPickerManager?.callback = callback
        _systemPhotoPickerManager?.cancelCallback = cancelCallback
        
        //        PHPickerConfiguration.init(photoLibrary: PHPhotoLibrary.shared())
        var config = PHPickerConfiguration.init()
        // 可选张数, 默认1张, 传0则系统上限
        config.selectionLimit = selectionLimit
        // 可选类型, 默认所有
        config.filter = filter
        _systemPhotoPickerManager?.pickerViewController = PHPickerViewController.init(configuration: config)
        _systemPhotoPickerManager?.pickerViewController?.delegate = _systemPhotoPickerManager
        _systemPhotoPickerManager?.pickerViewController?.modalPresentationStyle = .fullScreen
        vc.present(_systemPhotoPickerManager!.pickerViewController!, animated: true, completion: nil)
    }
    
    /// 使用 PHPicker 原数据返回
    public static func presentPicker(with vc: UIViewController, selectionLimit: Int = 1, filter: PHPickerFilter? = nil, callback: XQSystemPhotoPickerManagerCallback?) {
        if let _ = _systemPhotoPickerManager {
            return
        }
        
        _systemPhotoPickerManager = XQSystemPHPickerManager()
        _systemPhotoPickerManager?.resultsCallback = callback
        
        var config = PHPickerConfiguration.init()
        // 可选张数, 默认1张, 传0则系统上限
        config.selectionLimit = selectionLimit
        // 可选类型, 默认所有
        config.filter = filter
        _systemPhotoPickerManager?.pickerViewController = PHPickerViewController.init(configuration: config)
        _systemPhotoPickerManager?.pickerViewController?.delegate = _systemPhotoPickerManager
        _systemPhotoPickerManager?.pickerViewController?.modalPresentationStyle = .fullScreen
        vc.present(_systemPhotoPickerManager!.pickerViewController!, animated: true, completion: nil)
    }
    
    /// 退出照片选择
    public static func dismissPicker(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if _systemPhotoPickerManager != nil {
            _systemPhotoPickerManager?.pickerViewController?.dismiss(animated: flag, completion: completion)
            _systemPhotoPickerManager = nil
        }
    }
    
    private static var _systemPhotoPickerManager: XQSystemPHPickerManager?
    
    private var pickerViewController: PHPickerViewController?
    
    
    private var callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?
    private var cancelCallback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCancelCallback?
    
    public typealias XQSystemPhotoPickerManagerCallback = (_ results: [PHPickerResult]) -> ()
    private var resultsCallback: XQSystemPhotoPickerManagerCallback?
    
    private var imgs = [UIImage]()
    private var urls = [URL]()
    
    private var count = 0
    
    // MARK: - PHPickerViewControllerDelegate
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        print(#function, results)
        
        if self.resultsCallback != nil {
            self.resultsCallback?(results)
            Self.dismissPicker()
            return
        }
        
        if results.count == 0 {
//            print("取消")
            picker.dismiss(animated: true) { [unowned self] in
                self.cancelCallback?()
                XQSystemPHPickerManager._systemPhotoPickerManager = nil
            }
            return
        }
        
//        SVProgressHUD.show(withStatus: nil)
        
        // 创建默认文件夹
        let directoryPath = Self.normalDirectoryPath()
        if let path = directoryPath {
            if !FileManager.default.fileExists(atPath: path) {
                let url = URL.init(fileURLWithPath: path)
                try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
        }
        
        // 解析数据
        self.count = results.count
        
        for item in results {
//            print(item.itemProvider, item.itemProvider.registeredTypeIdentifiers)
            
            for registeredTypeIdentifier in item.itemProvider.registeredTypeIdentifiers {
                // 有部分系统会出现 first 不是 UIType 的问题, 所以这里循环去获取一下
                guard let type = UTType.init(registeredTypeIdentifier) else {
                    continue
                }
                
                if type == UTType.image ||
                    type.isSubtype(of: UTType.image) {
                    
                    // 获取图片
                    item.itemProvider.loadObject(ofClass: UIImage.classForCoder() as! NSItemProviderReading.Type) { (itemProviderReading, error) in
                        
//                        print(itemProviderReading ?? "没有值", error ?? "没有错误")
                        if let img = itemProviderReading as? UIImage {
                            self.imgs.append(img)
                        }
                        
                        self.handleDone()
                    }
                    
                }else if type.isSubtype(of: UTType.movie) {
                    // 获取视频
                    
                    // 这个获取 url, 不能直接播放, 需要拷贝到自己本地. 然后才能进行播放
                    item.itemProvider.loadFileRepresentation(forTypeIdentifier: registeredTypeIdentifier) { (url, error) in
//                        print("loadFileRepresentation: ", url ?? "没有数据", error ?? "没有错误")
                        
                        if let url = url {
                            var u: URL?
                            if let lp = directoryPath {
                                // 拷贝到本地
                                let p = lp + "/" + "\(Int(Date.init().timeIntervalSince1970)).\(url.pathExtension)"
                                u = URL.init(fileURLWithPath: p)
                                try? FileManager.default.copyItem(at: url, to: u!)
    //                            print("拷贝结束: \(p)")
                                self.urls.append(u!)
                            }
                        }
                        
                        self.handleDone()
                    }
                    
                    // 这个能直接获取到数据
//                    item.itemProvider.loadDataRepresentation
                    
                    // 获取路径
                    // 测的时候， Could not create a bookmark: NSError: Cocoa 257 "The file couldn’t be opened because you don’t have permission to view it." }
                    // 一直显示没权限...并且拷贝也不行
                    //  item.itemProvider.loadItem
                    
                }
                
                break
            }
            
        }
        
        
    }
    
    func handleDone() {
        self.count -= 1
        if self.count <= 0 {
            DispatchQueue.main.async {
                
                self.pickerViewController?.dismiss(animated: true, completion: nil)
                self.pickerViewController = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                    SVProgressHUD.dismiss()
                    self.callback?(self.imgs, self.urls)
                    XQSystemPHPickerManager._systemPhotoPickerManager = nil
                }
            }
        }
    }
    
    /// 获取默认文件夹路径
    public static func normalDirectoryPath() -> String? {
        
        if let lp = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return lp + "/" + "XQSystemPhotoPickerManager"
        }
        
        return nil
    }
    
//    deinit {
//        print(#function)
//    }

}
