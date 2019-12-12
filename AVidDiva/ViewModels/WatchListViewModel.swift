//
//  WatchListViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Combine
import Foundation

class WatchListViewModel: ObservableObject {
    
    @Published var episodes = [String:[TVMazeEpisode]]()
    @Published var showNames = [String]()
    var shows = [String:TVMazeShow]()
    var dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func queryUnwatchedEpisodes() {
        CloudKitAPI.shared.queryUnwatchedEpisodes(episodeConsumer: { episodes in
            let nowTime = self.dateFormatter.string(from: Date())
            var newShowNames = [String]()
            var newEpisodes = [String:[TVMazeEpisode]]()
            
            for episode in episodes {
                if let airdate = episode.airdate {
                    if airdate.isEmpty { //skip if empty airdate
                        continue
                    }
                    if airdate > nowTime { //skip if hasn't aired yet
                        continue
                    }
                } else {  //skip if no airdate set
                    continue
                }
                
                if let showName = episode.showName {
                    if !newShowNames.contains(showName) {
                        newShowNames.append(showName)
                    }
                    var showEpisodes = newEpisodes[showName] ?? [TVMazeEpisode]()
                    if let index = showEpisodes.firstIndex(of: episode) {
                        showEpisodes[index] = episode
                    } else {
                        showEpisodes.append(episode)
                    }
                    newEpisodes[showName] = showEpisodes
                }
            }
            
            DispatchQueue.main.async {
                self.showNames = newShowNames
            }
            DispatchQueue.main.async { //why did this seem to work better in two separate async calls?
                self.episodes = newEpisodes
            }
        })
    }
}
