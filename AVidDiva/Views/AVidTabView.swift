//
//  ContentView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 10/27/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct AVidTabView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            ShowsSearchView()
                .tabItem {
                    Image("first")
                    Text("Shows")
                }
                .tag(0)
            WatchListView()
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Watch List")
                    }
                }
                .tag(1)
        }
    }
}

struct AVidTabView_Previews: PreviewProvider {
    static var previews: some View {
        AVidTabView()
    }
}
