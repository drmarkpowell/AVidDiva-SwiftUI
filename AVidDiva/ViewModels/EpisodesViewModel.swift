//
//  EpisodesViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/24/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation
import Combine

class EpisodesViewModel: ObservableObject {
    @Published var episodes = [TVMazeEpisode]()
    var subscribedEpisodes = [TVMazeEpisode]()
    var showId: Int
    
    init(showId: Int) {
        self.showId = showId
        querySubscribedEpisodes()
    }
    
    func querySubscribedEpisodes() {
        NetworkAPI.shared.getEpisodes(showId, episodeConsumer: { episodes in
            self.episodes = episodes
        })
    }
}
