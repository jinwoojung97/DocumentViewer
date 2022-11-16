//
//  Preview.swift
//  DocumentViewer
//
//  Created by inforex on 2022/11/16.
//

import Foundation
import QuickLook

/// QLPreviewController에 들어갈 파일 URL
final class Preview: NSObject, QLPreviewItem {
    private var fileName: String
    private var fileExtension: String

    init(fileName: String, fileExtension: String){
        self.fileName = fileName
        self.fileExtension = fileExtension

        super.init()
    }

    var previewItemURL: URL?{
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
}
