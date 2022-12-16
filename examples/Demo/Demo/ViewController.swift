//
//  ViewController.swift
//  Demo
//
//  Created by xq on 2022/12/15.
//

import UIKit
import XQSystemImagePicker
import SnapKit
import PhotosUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
    }
    
    
    
    let tableView = UITableView()
    let cellReuseIdentifier = "tbaleView"
    var data: [String] = ["自动判断版本", "14.0之前(UIImagePickerController)", "14.0之后(PhotosUI)", "14.0之后原数据callback(PhotosUI)"]
    
    func initTableView() {
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            XQSystemPhotoPickerManager.showPicker(with: self, selectionLimit: 2) { imgs, urls in
                print("imgs: \(imgs) \nurls:\(urls)")
            } cancelCallback: {
                print("cancel 选择")
            }
            
        case 1:
            
            XQSystemUIImagePickerManager.showPicker(with: self) { imgs, urls in
                print("imgs: \(imgs) \nurls:\(urls)")
            } cancelCallback: {
                print("cancel 选择")
            }
            
        case 2:
            
            if #available(iOS 14, *) {
                XQSystemPHPickerManager.showPicker(with: self, selectionLimit: 2) { imgs, urls in
                    print("imgs: \(imgs) \nurls:\(urls)")
                } cancelCallback: {
                    print("cancel 选择")
                }
            }
            
        case 3:
            
            if #available(iOS 14, *) {
                XQSystemPHPickerManager.presentPicker(with: self, selectionLimit: 10) { results in
                    print("results: \(results.count)")
                    self.handlePickerResults(results)
                }
            }
            
            break
        default:
            break
        }
    }
    
    @available(iOS 14.0, *)
    func handlePickerResults(_ results: [PHPickerResult]) {
        if results.isEmpty {
            // 取消选择
        }else {
            
            // 创建默认文件夹
            let directoryPath = XQSystemPHPickerManager.normalDirectoryPath()
            if let path = directoryPath {
                if !FileManager.default.fileExists(atPath: path) {
                    let url = URL.init(fileURLWithPath: path)
                    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                }
            }
            
//            var imgs: [UIImage] = []
//            var urls: [URL] = []
            
            for item in results {
                for registeredTypeIdentifier in item.itemProvider.registeredTypeIdentifiers {
                    // 有部分系统会出现 first 不是 UIType 的问题, 所以这里循环去获取一下
                    guard let type = UTType.init(registeredTypeIdentifier) else {
                        continue
                    }
                    
                    // 对 results 进行数据处理
                    if type == UTType.image ||
                        type.isSubtype(of: UTType.image) {
                        
                        // 获取图片
                        item.itemProvider.loadObject(ofClass: UIImage.classForCoder() as! NSItemProviderReading.Type) { (itemProviderReading, error) in
                            print("image: \(itemProviderReading!), \(String(describing: error))")
                            if let img = itemProviderReading as? UIImage {
                                print("img: \(img)")
//                                imgs.append(img)
                            }
                        }
                        
                    }else if type.isSubtype(of: UTType.movie) {
                        // 获取视频
                        
                        // 这个获取 url, 不能直接播放, 需要拷贝到自己本地. 然后才能进行播放
                        item.itemProvider.loadFileRepresentation(forTypeIdentifier: registeredTypeIdentifier) { (url, error) in
                            print("movie: \(url!), \(String(describing: error))")
                            
//                            if let url = url {
//                                var u: URL?
//                                if let lp = directoryPath {
//                                    // 拷贝到本地
//                                    let p = lp + "/" + "\(Int(Date.init().timeIntervalSince1970)).\(url.pathExtension)"
//                                    u = URL.init(fileURLWithPath: p)
//                                    try? FileManager.default.copyItem(at: url, to: u!)
//                                    //                            print("拷贝结束: \(p)")
//                                    urls.append(u!)
//                                }
//                            }
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
    }
    
    
}

