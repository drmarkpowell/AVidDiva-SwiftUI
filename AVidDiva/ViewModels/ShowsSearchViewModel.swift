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
        
    func showSubscribedShows() {
        showSearchResults = subscribedShows
    }
    
    func addOrUpdateSubscription(show: TVMazeShow) {
        CloudKitAPI.shared.addOrUpdateSubscription(show: show, showConsumer: { error in
            self.subscribedShows.append(show)
            print("show added")
            self.queryEpisodes(show: show)
        })
    }
    
    func addToSubscribedEpisodes(episodes: [TVMazeEpisode], show: TVMazeShow) {
        for episode in episodes {
            CloudKitAPI.shared.addOrUpdateEpisode(episode: episode, show: show,
                                                  episodeConsumer: { error in
                print("added subscribed episode")
            })
        }
    }
    
    func querySubscribedShows() {
        CloudKitAPI.shared.querySubscribedShows(showConsumer: { shows in
            DispatchQueue.main.async {
                self.showSearchResults = shows
                self.subscribedShows = shows
                print("subscribed shows queried")
            }
        })
    }
        
    func queryEpisodes(show: TVMazeShow) {
        NetworkAPI.shared.getEpisodes(show, episodeConsumer: { episodes in
            print("episodes queried")
            self.addToSubscribedEpisodes(episodes: episodes, show: show)
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

