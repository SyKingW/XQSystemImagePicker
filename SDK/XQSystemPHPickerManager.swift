//
//  XQSystemPhotoPickerManager.swift
//  XQSystemImagePickerDemo
//
//  Created by WXQ on 2020/9/18.
//

import UIKit

import PhotosUI
import MobileCoreServices

import SVProgressHUD
import XQAlert

public class XQSystemPhotoPickerManager: NSObject {
    
    public enum ResourceType: Int {
        case all = 0
        case image = 1
        case video = 2
    }
    
    /// imgs 是 UIImage, urls 是视频的URL
    /// 如果是空, 那代表用户什么都不选, 或者点取消
    public typealias XQSystemPhotoPickerManagerCallback = (_ imgs: [UIImage], _ urls:[URL] ) -> ()
    
    /// 选择图片
    /// - Parameters:
    ///   - selectionLimit: 最多可选多少张( iOS 14 才支持这个属性, iOS14以下，则只可选一张)
    ///   - filter: 选择资源类型
    ///   - callback: 返回已选资源
    public static func showPicker(with vc: UIViewController, selectionLimit: Int = 1, filter: XQSystemPhotoPickerManager.ResourceType? = .all, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?) {
        
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
            
            XQSystemPHPickerManager.showPicker(with: vc, selectionLimit: selectionLimit, filter: f, callback: callback)
        }else {
            XQSystemUIImagePickerManager.showPicker(with: vc, filter: filter, callback: callback)
        }
        
        
    }
    
}

public class XQSystemUIImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 选择图片
    public static func showPicker(with vc: UIViewController, filter: XQSystemPhotoPickerManager.ResourceType? = .all, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?) {
        
        if (!UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            print("不支持打开相册")
            //            XQSystemAlert.alert(withTitle: "当前手机不支持相机", message: nil, contentArr: nil, cancelText: "确定", vc: vc, contentCallback: nil, cancelCallback: nil)
            return
        }
        
        if let _ = _systemPhotoPickerManager {
            return
        }
        
        _systemPhotoPickerManager = XQSystemUIImagePickerManager()
        
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        if status == .restricted || status == .denied {
//            XQSystemAlert.alert(withTitle: "提示", message: "相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，开启相机功能", contentArr: ["前去设置"], cancelText: "取消", vc: vc, contentCallback: { (alert, index) in
//
//                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//
//            }, cancelCallback: nil)
//            return
//        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
                        
        // 设置资源来源（相册、相机、图库之一）
        imagePickerController.sourceType = .photoLibrary
        
        // 允许的视屏质量（如果质量选取的质量过高，会自动降低质量）
//        imagePickerController.videoQuality = .typeMedium
        
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
        
        vc.present(imagePickerController, animated: true, completion: nil)
        _systemPhotoPickerManager?.imagePickerController = imagePickerController
    }
    
    public static func hidePicker(animated flag: Bool = true) {
        if let obj = _systemPhotoPickerManager {
            obj.imagePickerController?.dismiss(animated: flag, completion: nil)
            _systemPhotoPickerManager = nil
        }
    }
    
    private static var _systemPhotoPickerManager: XQSystemUIImagePickerManager?
    
    private var callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?
    
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
        
        //        [__C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerMediaType): public.image, __C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerImageURL): file:///private/var/mobile/Containers/Data/Application/C6D2D065-A742-4577-8B8E-3845E91FF2BE/tmp/20130466-BED4-4F1B-A99B-D5B7AA84F57E.png, __C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerReferenceURL): assets-library://asset/asset.PNG?id=FE197B0E-82F6-4D01-9E71-0C285B1D3C60&ext=PNG, __C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerOriginalImage): <UIImage:0x282dde520 anonymous {750, 1334}>]
                
        //        imagePickerController(_:didFinishPickingMediaWithInfo:) [__C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerReferenceURL): assets-library://asset/asset.MP4?id=8000D1E5-0E9A-4646-BEC0-6E629F13A7CA&ext=MP4, __C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerMediaType): public.movie, __C.UIImagePickerControllerInfoKey(_rawValue: UIImagePickerControllerMediaURL): file:///private/var/mobile/Containers/Data/PluginKitPlugin/A2959739-2844-4B91-B4C5-0F3E079ECEB4/tmp/trim.E220586A-B04D-4003-9552-3B4385D594E1.MOV]
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function)
        picker.dismiss(animated: true) { [unowned self] in
            self.callback?(self.imgs, self.urls)
            XQSystemUIImagePickerManager._systemPhotoPickerManager = nil
        }
    }
    
    deinit {
        print(#function)
    }
    
}

@available(iOS 14, *)
public class XQSystemPHPickerManager: NSObject, PHPickerViewControllerDelegate {
    
    /// 跳转选择资源
    /// - Parameters:
    ///   - selectionLimit: 最大可选多少张. 默认1张, 传 0 则是系统可选的上限
    ///   - filter: 要过滤可选内容. nil 就不过滤
    public static func showPicker(with vc: UIViewController, selectionLimit: Int = 1, filter: PHPickerFilter? = nil, callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?) {
        
        if let _ = _systemPhotoPickerManager {
            return
        }
        
        _systemPhotoPickerManager = XQSystemPHPickerManager()
        _systemPhotoPickerManager?.callback = callback
        
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
    
    public static func hidePicker(animated flag: Bool = true) {
        if let obj = _systemPhotoPickerManager {
            obj.pickerViewController?.dismiss(animated: flag, completion: nil)
            _systemPhotoPickerManager = nil
        }
    }
    
    private static var _systemPhotoPickerManager: XQSystemPHPickerManager?
    
    private var pickerViewController: PHPickerViewController?
    
    /// imgs 是 UIImage, urls 是视频的URL
    /// 如果是空, 那代表用户什么都不选, 或者点取消
    var callback: XQSystemPhotoPickerManager.XQSystemPhotoPickerManagerCallback?
    
    private var imgs = [UIImage]()
    private var urls = [URL]()
    
    private var count = 0
    
    // MARK: - PHPickerViewControllerDelegate
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(#function, results)
        
        if results.count == 0 {
//            print("取消")
            picker.dismiss(animated: true, completion: nil)
            XQSystemPHPickerManager._systemPhotoPickerManager = nil
            return
        }
        
        SVProgressHUD.show(withStatus: nil)
        
        // 创建默认文件夹
        let directoryPath = self.normalDirectoryPath()
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
            
            if let registeredTypeIdentifier = item.itemProvider.registeredTypeIdentifiers.first, let type = UTType.init(registeredTypeIdentifier) {
                
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
//                    item.itemProvider.loadDataRepresentation(forTypeIdentifier: registeredTypeIdentifier) { (data, error) in
//                        print("loadDataRepresentation: ", data ?? "没有数据", error ?? "没有错误")
//                    }
                    
                    // 获取路径
                    // 测的时候， Could not create a bookmark: NSError: Cocoa 257 "The file couldn’t be opened because you don’t have permission to view it." }
                    // 一直显示没权限...并且拷贝也不行
                    //                    item.itemProvider.loadItem(forTypeIdentifier: registeredTypeIdentifier, options: nil) { (secureCoding, error) in
                    //                        print(secureCoding ?? "没有数据", error ?? "没有错误")
                    //
                    //                        DispatchQueue.main.async {
                    //                            if let path = secureCoding as? URL {
                    //
                    //                                var url: URL?
                    //                                if let lp = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                    //
                    //                                    let p = lp + "/" + "\(Int(Date.init().timeIntervalSince1970)).mp4"
                    //                                    url = URL.init(fileURLWithPath: p)
                    //                                    try? FileManager.default.copyItem(at: path, to: url!)
                    //                                    print("拷贝结束: \(p)")
                    //
                    //
                    //                                }
                    //
                    //                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //                                    if !FileManager.default.fileExists(atPath: url!.absoluteString) {
                    //                                        print("拷贝失败")
                    //                                    }else {
                    //                                        self.player(url!)
                    //                                    }
                    //
                    //                                }
                    //
                    //                            }
                    //                        }
                    //                    }
                    
                }
                
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
                    SVProgressHUD.dismiss()
                    self.callback?(self.imgs, self.urls)
                    XQSystemPHPickerManager._systemPhotoPickerManager = nil
                }
            }
        }
    }
    
    /// 获取默认文件夹路径
    func normalDirectoryPath() -> String? {
        
        if let lp = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            return lp + "/" + "XQSystemPhotoPickerManager"
        }
        
        return nil
    }
    
    deinit {
        print(#function)
    }

}
