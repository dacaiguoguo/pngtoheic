# PNG to HEIC Conversion Tool

This Swift command-line tool processes image assets in a specified folder by converting PNG images to HEIC format. The tool specifically handles `.xcassets` folders commonly used in macOS and iOS projects, updating the `Contents.json` file to reference the new HEIC images. It removes the original PNG files after conversion.

## Features
- Converts PNG images to HEIC format with configurable compression quality.
- Automatically updates the `Contents.json` file with the new HEIC image references.
- Removes the original PNG images after successful conversion.
- Processes all JSON files in the specified folder to identify and convert images.

## Prerequisites
- macOS system with Swift installed.
- Xcode or a compatible Swift toolchain.
- The folder to process should contain a valid `Contents.json` file that defines the images used.

## Installation
1. Ensure Swift is installed on your system.
2. Clone or copy the script into a file, e.g., `png2heic.swift`.
3. Compile the script using Swift's command-line tool:

   ```bash
   swiftc png2heic.swift -o png2heic
   ```

## Usage
1. After compiling the script, run the executable by passing the folder path as an argument:

   ```bash
   ./png2heic /path/to/your/assets.xcassets
   ```

   Example:

   ```bash
   ./png2heic /Users/youruser/Developer/Project/Assets.xcassets
   ```

2. The tool will:
   - Convert all PNG images referenced in the `Contents.json` file to HEIC format.
   - Update the `Contents.json` file to reference the new HEIC images.
   - Remove the original PNG images.

3. After the script finishes running, you will see a message indicating that the process is complete.

## Code Overview

### Main Functions

1. **`processImagesInFolder(fromFolderPath:fileType:)`**:
   - Traverses the specified folder, identifies JSON files (like `Contents.json`), and processes image data.
   - For each image listed in the `Contents.json`, it converts PNG images to HEIC format and updates the JSON.

2. **`getFilesAsJSON(fromFolderPath:fileType:)`**:
   - Enumerates through the folder and collects all JSON files (or files of the specified type) for further processing.

3. **`convertPNGToHEIC(pngImageData:quality:)`**:
   - Converts PNG image data to HEIC format with the specified compression quality (default: 1.0).

### Error Handling
The tool includes basic error handling, such as:
- Failure to parse the JSON file.
- Failure to find the image files.
- Failure during the HEIC conversion or file write operations.

## Dependencies
- **AppKit**: Used for handling image conversions.
- **ImageIO**: Utilized for writing HEIC files.
- **UniformTypeIdentifiers**: Modern type identifiers for handling HEIC output.
  
## License
This project is open-source under the MIT License. You are free to use, modify, and distribute this code as long as proper credit is given.

---

Feel free to customize the script for more advanced use cases or optimization!
