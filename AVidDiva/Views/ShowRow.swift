//
//  ShowRow.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/24/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct ShowRow: View {
    
    var showsViewModel: ShowsSearchViewModel
    var show: TVMazeShow
    var searchingForShows: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ShowImage(urlPath: show.image?.medium ?? "")
            Text(show.name ?? "No name")
            Spacer()
            if searchingForShows {
                Button(action: {
                    self.showsViewModel.addOrUpdateSubscription(show: self.show)
                }) {
                    Text("Add")
                }
            }
        }
    }
}
