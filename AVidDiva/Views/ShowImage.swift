//
//  ShowImage.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/10/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct ShowImage: View {
    @ObservedObject var imageViewModel: TVImageModel
    init(urlPath: String) {
        self.imageViewModel = TVImageModel(urlPath: urlPath)
    }
    var body: some View {
        Image(uiImage: (imageViewModel.imageData != nil) ?
            UIImage(data: imageViewModel.imageData!)! :
            UIImage(named: "television")!)
        .resizable()
        .scaledToFit()
        .cornerRadius(10)
        .frame(width: 60, height: 60, alignment: .leading)
    }
}

struct ShowImage_Previews: PreviewProvider {
    static var previews: some View {
        ShowImage(urlPath: "https://cdn.playbuzz.com/cdn/UserImages/a4ef90f9-3394-4ef4-b14c-f24be95ef5bd.jpg")
    }
}
