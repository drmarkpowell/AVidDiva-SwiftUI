//
//  WatchListView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/28/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct WatchListView: View {
    @State private var listMode = 0
    var settings = ["List", "Calendar"]

    var body: some View {
        VStack {
            Picker("", selection: $listMode) {
                ForEach(0 ..< settings.count) { index in
                    Text(self.settings[index])
                        .tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = WatchListView()
        return view
    }
}
