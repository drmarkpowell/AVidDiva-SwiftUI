//
//  WatchListViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Combine
import Foundation
import SwiftDate

class WatchListViewModel: ObservableObject {
    
    @Published var showNames = [String]()
    @Published var episodes = [String:[TVMazeEpisode]]()
    var shows = [Int:TVMazeShow]()
    
    init() {
        CloudKitAPI.shared.querySubscribedShows(showConsumer: { shows in
            shows.forEach { show in
                self.shows[show.id] = show
            }
            CloudKitAPI.shared.queryUnwatchedEpisodes(episodeConsumer: { episodes in
                episodes.forEach { episode in
                    guard let showId = episode.showId else {
                        return
                    }
                    if let show = self.shows[showId] {
                        if let showName = show.name {
                            if !self.showNames.contains(showName) {
                                self.showNames.append(showName)
                            }
                            
                            var showEpisodes = self.episodes[showName] ?? [TVMazeEpisode]()
                            showEpisodes.append(episode)
                            self.episodes[showName] = showEpisodes
                        }
                    }
                }
            })
        })
    }
    
    func timeName(for airDate: Date) -> String {
        let localToday = DateInRegion(Date(), region: Region.local).dateAt(.startOfDay)
        let aired = DateInRegion(airDate, region: .UTC)
        if aired.isBeforeDate(localToday, granularity: .day) {
            return "Previously"
        }
        let daysUntil = localToday.getInterval(toDate: aired, component: .day)
        switch daysUntil {
        case 0:
            return "Today"
        case 1,2,3,4,5:
            return aired.weekdayName(.default)
        default:
            return "Coming Soon"
        }
    }
}
