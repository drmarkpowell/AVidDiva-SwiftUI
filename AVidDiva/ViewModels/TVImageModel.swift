//
//  TVImageModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/10/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

class TVImageModel: ObservableObject {
    
    @Published var imageData: Data? = nil
    
    var urlPath: String? {
        didSet {
            if let urlPath = urlPath {
                fetchImageData(urlPath: urlPath)
            }
        }
    }
    
    init(urlPath: String) {
        defer { //otherwise didSet will not invoke from init
            self.urlPath = urlPath
        }
    }
    
    func fetchImageData(urlPath: String) {
        guard let url = URL(string: urlPath.replacingOccurrences(of: "http:", with: "https:")) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                self.imageData = data
            }
        }.resume()
    }
}
