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
    var showId: Int
    
    init(showId: Int) {
        self.showId = showId
        querySubscribedEpisodes()
    }
    
    func querySubscribedEpisodes() {
        CloudKitAPI.shared.querySubscribedEpisodes(showId: showId, episodeConsumer: { episodes in
            DispatchQueue.main.async {
                print("Got back episodes: \(episodes.count)")
                self.episodes = episodes
            }
        })
    }

    func toggle(episodeIndex: Int) {
        episodes[episodeIndex].watched?.toggle()
        CloudKitAPI.shared.toggleEpisodeWatched(episode: episodes[episodeIndex], callback: { error in
            if error != nil {
                self.episodes[episodeIndex].watched?.toggle()
            }
        })
    }
}
