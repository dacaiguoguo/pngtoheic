import Foundation
import AppKit
import ImageIO
import CoreServices
import UniformTypeIdentifiers // Import the new UTType framework

func processImagesInFolder(fromFolderPath path: String, fileType: String = "json") {
    let jsonList = getFilesAsJSON(fromFolderPath: path, fileType: fileType)
    let fileManager = FileManager.default
    
    jsonList.forEach { url in
        let jsonURL = url.deletingLastPathComponent().appendingPathComponent("Contents.json")
        do {
            let data = try Data(contentsOf: jsonURL)
            guard var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Error: Unable to parse JSON data at \(jsonURL)")
                return
            }
            
            guard let images = json["images"] as? [[String: Any]] else {
                print("Error: 'images' array not found in JSON at \(jsonURL)")
                return
            }
            
            var updatedImages = [[String: Any]]()
            
            for var imageInfo in images {
                guard let filename = imageInfo["filename"] as? String,
                      let scale = imageInfo["scale"] as? String,
                      let imgData = try? Data(contentsOf: url.deletingLastPathComponent().appendingPathComponent(filename)) else {
                    print("Error: Failed to retrieve image data or metadata for \(imageInfo)")
                    updatedImages.append(imageInfo)
                    continue
                }
                
                guard let heicData = convertPNGToHEIC(pngImageData: imgData, quality: 1.0) else {
                    print("Error: Failed to convert PNG to HEIC for \(filename)")
                    updatedImages.append(imageInfo)
                    continue
                }
                
                let pureName = url.deletingLastPathComponent().lastPathComponent.components(separatedBy: ".").first ?? ""
                let heicFilename = "\(pureName)@\(scale).heic"
                let heicURL = url.deletingLastPathComponent().appendingPathComponent(heicFilename)
                
                do {
                    try heicData.write(to: heicURL)
                    try fileManager.removeItem(at: url.deletingLastPathComponent().appendingPathComponent(filename))
                    
                    imageInfo["filename"] = heicFilename // Update filename
                    updatedImages.append(imageInfo)
                } catch {
                    print("Error: Unable to write HEIC file or remove original PNG for \(filename) - \(error.localizedDescription)")
                }
            }
            
            json["images"] = updatedImages // Update the 'images' array
            
            // Write updated JSON back to file
            if let updatedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                try updatedData.write(to: jsonURL)
            }
            
        } catch {
            print("Error: \(error.localizedDescription) while processing JSON at \(jsonURL)")
        }
    }
}

func getFilesAsJSON(fromFolderPath path: String, fileType: String? = nil) -> [URL] {
    let fileManager = FileManager.default
    var filesArray = [URL]()
    
    let folderURL = URL(fileURLWithPath: path)
    
    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    
    guard exists, isDirectory.boolValue else {
        print("Error: The path \(path) does not exist or is not a directory")
        return []
    }
    
    let fileEnumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) { (url, error) -> Bool in
        print("Error while enumerating \(url): \(error.localizedDescription)")
        return true
    }
    
    while let fileURL = fileEnumerator?.nextObject() as? URL {
        if let fileType = fileType, fileURL.pathExtension == fileType {
            filesArray.append(fileURL)
        } else if fileType == nil {
            filesArray.append(fileURL)
        }
    }
    
    return filesArray
}

func convertPNGToHEIC(pngImageData: Data, quality: CGFloat = 1.0) -> Data? {
    guard let image = NSImage(data: pngImageData) else {
        print("Error: Unable to create NSImage from PNG data")
        return nil
    }
    
    let heicData = NSMutableData()
    guard let destination = CGImageDestinationCreateWithData(heicData, UTType.heic.identifier as CFString, 1, nil) else {
        print("Error: Unable to create destination for HEIC conversion")
        return nil
    }
    
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Error: NSImage has no CGImage representation")
        return nil
    }
    
    let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
    CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
    
    guard CGImageDestinationFinalize(destination) else {
        print("Error: Failed to finalize HEIC conversion")
        return nil
    }
    
    return heicData as Data
}

// Get command-line arguments
let arguments = CommandLine.arguments

// Check if a folder path was provided as an argument
guard arguments.count > 1 else {
    print("Error: Please provide a folder path as a command-line argument.")
    exit(1)
}

// Get the folder path from the first argument
let folderPath = arguments[1]

// Call the function to process images
processImagesInFolder(fromFolderPath: folderPath)

print("Processing complete!")
