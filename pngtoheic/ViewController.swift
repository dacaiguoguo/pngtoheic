//
//  ViewController.swift
//  pngtoheic
//
//  Created by yanguo sun on 2024/3/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonList = getFilesAsJSON(fromFolderPath: "/Users/yanguosun/Developer/aiheadshot/Aihelper/Assets.xcassets", fileType: "json")
        //        let sss = getFilesAsJSON(fromFolderPath: "/Users/yanguosun/Developer/aiheadshot/Aihelper/Assets.xcassets", fileType: "png")
        // print(jsonList)
        let fileManager = FileManager.default

        jsonList.forEach { url in
            let jsonURL = url.deletingLastPathComponent().appendingPathComponent("Contents.json")
            do {
                let data = try Data(contentsOf: jsonURL)
                var json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                guard let images = json?["images"] as? [[String: Any]] else { return }
                
                var updatedImages = [[String: Any]]()
                
                for var imageInfo in images {
                    guard let filename = imageInfo["filename"] as? String,
                          let scale = imageInfo["scale"] as? String,
                          let imgData = try? Data(contentsOf: url.deletingLastPathComponent().appendingPathComponent(filename)),
                          let heicData = convertPNGToHEIC(pngImageData: imgData, quality: 1.0) else {
                        updatedImages.append(imageInfo)
                        continue
                    }
                    
                    let pureName = url.deletingLastPathComponent().lastPathComponent.components(separatedBy: ".").first ?? ""
                    let heicFilename = "\(pureName)@\(scale).heic"
                    let heicURL = url.deletingLastPathComponent().appendingPathComponent(heicFilename)
                    
                    try heicData.write(to: heicURL)
                    try fileManager.removeItem(at: url.deletingLastPathComponent().appendingPathComponent(filename))
                    
                    imageInfo["filename"] = heicFilename // 更新文件名
                    updatedImages.append(imageInfo)
                }
                
                json?["images"] = updatedImages // 更新images数组
                
                // 将修改后的JSON数据写回文件
                if let updatedData = try? JSONSerialization.data(withJSONObject: json!, options: .prettyPrinted) {
                    try updatedData.write(to: jsonURL)
                }
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

//        jsonList.forEach { url in
//            do {
//                // Users/yanguosun/Developer/aiheadshot/Aihelper/Assets.xcassets/settingicon.imageset/Contents.json
//                // let jsonPath = url.deletingLastPathComponent().appendingPathComponent("Contents.json")
//                do {
//                    let data = try Data(contentsOf: url)
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        var jsonNew = json
//                        if let images = json["images"] as? [[String: Any]] {
//                            images.forEach { ainfo in
//                                if let filename = ainfo["filename"] as? String, let scale = ainfo["scale"] as? String {
//                                    let imgPath = url.deletingLastPathComponent().appendingPathComponent(filename)
//                                    print("sss")
//                                    // 确保文件夹 URL 是有效的
//                                    var isDirectory: ObjCBool = false
//                                    let exists = fileManager.fileExists(atPath: imgPath.path, isDirectory: &isDirectory)
//                                    if exists {
//                                        if let imgData = try? Data(contentsOf: imgPath) {
//                                            
//                                            guard let pureName = url.deletingLastPathComponent().lastPathComponent.components(separatedBy: ".").first else {
//                                                return
//                                            }
//                                            
//                                            let pureNameFull = "\(pureName)@\(scale).heic"
//                                            let imgPathHeic = url.deletingLastPathComponent().appendingPathComponent(pureNameFull)
//                                            
//                                            if let heicData = convertPNGToHEIC(pngImageData: imgData, quality: 1.0) {
//                                                // try? heicData.write(to: URL(fileURLWithPath: "/Users/yanguosun/Developer/pngtoheic/output").appendingPathComponent("\(pureName)@\(scale).heic"))
//                                                jsonNew["filename"] = imgPathHeic
//                                                try? heicData.write(to: imgPathHeic)
//                                                try? fileManager.removeItem(at: imgPath)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
//                    // 处理解析后的 JSON 对象
//                } catch {
//                    print("Error reading JSON file: \(error.localizedDescription)")
//                }
//                //
//            } catch {
//                print("sss")
//            }
//        }
        // Do any additional setup after loading the view.
    }
    
    func getFilesAsJSON(fromFolderPath path: String, fileType: String? = nil) -> [URL] {
        let fileManager = FileManager.default
        var filesArray = [URL]()
        
        // 获取文件夹 URL
        let folderURL = URL(fileURLWithPath: path)
        
        // 确保文件夹 URL 是有效的
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        
        guard exists, isDirectory.boolValue else {
            return []
        }
        
        // 枚举文件夹中的文件和子文件夹
        let fileEnumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) { (url, error) -> Bool in
            return true
        }
        
        while let fileURL = fileEnumerator?.nextObject() as? URL {
            // 如果指定了文件类型，且文件类型匹配
            if let fileType = fileType, fileURL.pathExtension == fileType {
                filesArray.append(fileURL)
            } else if fileType == nil { // 如果没有指定文件类型，则添加所有文件
                filesArray.append(fileURL)
            }
        }
        
        return filesArray
    }
    
    func convertPNGToHEIC(pngImageData: Data, quality: CGFloat = 1.0) -> Data? {
        // 首先，尝试从给定的PNG数据中创建一个UIImage对象。
        guard let image = UIImage(data: pngImageData) else { return nil }
        
        // 接下来，准备HEIC格式的输出数据。
        let heicData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(heicData, AVFileType.heic as CFString, 1, nil) else { return nil }
        
        // 获取UIImage的CGImage，并确保它存在。
        guard let cgImage = image.cgImage else { return nil }
        
        // 设置转换质量。
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        
        // 添加图片到目标中，并指定HEIC格式和质量。
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        
        // 执行转换。
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        // 返回转换后的HEIC数据。
        return heicData as Data
    }
    
}

