# XQSystemImagePicker

对系统图片选择器的封装



# 导入

```
pod 'XQSystemImagePicker', :git => 'https://github.com/SyKingW/XQSystemImagePicker.git'
```


# 使用


选择图片或视频，根据手机版本，自动判断使用 XQSystemUIImagePickerManager 还是 XQSystemPHPickerManager

```swift
XQSystemPhotoPickerManager.showPicker(with: self, selectionLimit: 2) { imgs, urls in
    print("imgs: \(imgs) \n 视频 urls:\(urls)")
} cancelCallback: {
    print("cancel 选择")
}
```

主动调用退出选择照片
    
```swift
XQSystemPhotoPickerManager.dismissPicker()
```

14.0 之前系统选择图片(UIImagePickerController)

```swift
XQSystemUIImagePickerManager.showPicker(with: self) { imgs, urls in
    print("imgs: \(imgs) \nurls:\(urls)")
} cancelCallback: {
    print("cancel 选择")
}
``` 

14.0 之后系统选择图片(PhotosUI, PHPickerViewController)

```swift
XQSystemPHPickerManager.showPicker(with: self, selectionLimit: 2) { imgs, urls in
    print("imgs: \(imgs) \nurls:\(urls)")
} cancelCallback: {
    print("cancel 选择")
}
```


