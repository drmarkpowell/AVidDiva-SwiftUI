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
    var subscribedShows = [TVMazeShow]()
    
    init() {
        querySubscribedShows()
    }
    
    func showSubscribedShows() {
        showSearchResults = subscribedShows
    }
    
    func addOrUpdateSubscription(show: TVMazeShow) {
        CloudKitAPI.shared.addOrUpdateSubscription(show: show, showConsumer: {
            self.subscribedShows.append(show)
            print("show added")
            self.queryEpisodes(showId: show.id)
        })
    }
    
    func addToSubscribedEpisodes(episodes: [TVMazeEpisode], showId: Int) {
        for episode in episodes {
            CloudKitAPI.shared.addOrUpdateEpisode(episode: episode, showId: showId, episodeConsumer: {
                print("added subscribed episode")
            })
        }
    }
    
    func querySubscribedShows() {
        self.clearShows()
        CloudKitAPI.shared.querySubscribedShows(showConsumer: { shows in
            DispatchQueue.main.async {
                self.showSearchResults = shows
                self.subscribedShows = shows
                print("subscribed shows queried")
            }
        })
    }
    
    func queryEpisodes(showId: Int) {
        NetworkAPI.shared.getEpisodes(showId, episodeConsumer: { episodes in
            print("episodes queried")
            self.addToSubscribedEpisodes(episodes: episodes, showId: showId)
        })
    }
    
    func queryShows(_ titleText: String) {
        NetworkAPI.shared.getShows(titleText, showConsumer: { shows in
            DispatchQueue.main.async {
                self.showSearchResults = shows
                print("shows update after search")
            }
        })
    }
    
    func clearShows() {
        showSearchResults.removeAll()
        print("shows cleared")
    }
}

