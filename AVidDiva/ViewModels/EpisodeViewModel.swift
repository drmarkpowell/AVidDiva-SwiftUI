//
//  EpisodeViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Combine

class EpisodeViewModel: ObservableObject {
    
    @Published var episode: TVMazeEpisode
    
    init(episode: TVMazeEpisode) {
        self.episode = episode
    }
    
    func toggle() {
        episode.watched?.toggle()
        CloudKitAPI.shared.toggleEpisodeWatched(episode: episode, callback: { error in
            if error != nil {
                self.episode.watched?.toggle()
            }
        })
    }
}
