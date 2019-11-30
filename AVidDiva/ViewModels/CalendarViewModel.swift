//
//  CalendarViewModel.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Combine
import Foundation
import SwiftDate

class CalendarViewModel: ObservableObject {
    
    @Published var episodes = [String:[TVMazeEpisode]]()
    @Published var times = [String]()
    var shows = [String:TVMazeShow]()
    let dateFormat = DateFormatter()

    init() {
        dateFormat.dateFormat = "yyyy-MM-dd"
    }
    
    func queryUnwatchedEpisodes() {

        CloudKitAPI.shared.queryUnwatchedEpisodes(episodeConsumer: { episodes in
            var newTimes = [String]()
            var newEpisodes = [String:[TVMazeEpisode]]()
            
            for episode in episodes {
                if let airdate = episode.airdate {
                    let time = self.timeName(for: airdate)
                    if !newTimes.contains(time) {
                        newTimes.append(time)
                    }
                    var showEpisodes = newEpisodes[time] ?? [TVMazeEpisode]()
                    showEpisodes.append(episode)
                    newEpisodes[time] = showEpisodes
                }
            }
            
            DispatchQueue.main.async {
                self.times = newTimes
            }
            DispatchQueue.main.async {
                self.episodes = newEpisodes
            }                
        })
    }

    func timeName(for airdateText: String) -> String {
        let airDate = dateFormat.date(from: airdateText) ?? Date(timeIntervalSince1970: 31557600*129) //year 2099
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
