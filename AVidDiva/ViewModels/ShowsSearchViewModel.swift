//
//  ShowsViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 10/27/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation
import Combine

class ShowsSearchViewModel: ObservableObject {
    @Published var showSearchResults = [TVMazeShow]()
    
    func queryShows(_ titleText: String) {
        NetworkAPI.shared.getShows(titleText, showConsumer: { shows in
            DispatchQueue.main.async {
                self.showSearchResults = shows
            }
        })
    }
}

