//
//  EpisodeViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Combine
import Foundation

extension Notification.Name {
    static let toggleWatched = Notification.Name("toggleWatched")
}

class EpisodeViewModel: ObservableObject {
    
    @Published var episode: TVMazeEpisode
    var toggleWatchedCancellable: AnyCancellable?
    
    init(episode: TVMazeEpisode) {
        self.episode = episode
        self.toggleWatchedCancellable = NotificationCenter.Publisher(center: .default,
                                                                     name: .toggleWatched,
                                                                     object: nil)
        .sink { [unowned self] notification in
            if let episode = notification.object as? TVMazeEpisode,
                let myAirdate = self.episode.airdate,
                let otherAirdate = episode.airdate {
                if myAirdate < otherAirdate &&
                    episode.showId == self.episode.showId &&
                    self.episode.watched != true {
                    self.toggleWatched(false)
                }
            }
        }
    }
    
    func imageUrlPath() -> String? {
        if let path = episode.image?.medium {
            return path
        }
        if let showId = episode.showId,
            let showRecord = CloudKitAPI.shared.showRecords[showId] {
            return showRecord.value(forKey: "mediumImageLocator") as? String
        }
        return nil
    }
    
    func toggleWatched(_ includePreviousEpisodes: Bool) {
        episode.watched?.toggle()
        CloudKitAPI.shared.toggleEpisodeWatched(episode: episode, callback: { error in
            if error != nil {
                self.episode.watched?.toggle()
            }
        })
        if includePreviousEpisodes {
            NotificationCenter.default.post(name: .toggleWatched, object: episode)
        }
    }
}
