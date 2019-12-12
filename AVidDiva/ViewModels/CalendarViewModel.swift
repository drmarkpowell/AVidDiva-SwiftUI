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
    var timePairs = [(String, Int)]()
    var shows = [String:TVMazeShow]()
    let dateFormat = DateFormatter()

    init() {
        dateFormat.dateFormat = "yyyy-MM-dd"
    }
    
    func queryUnwatchedEpisodes() {

        CloudKitAPI.shared.queryUnwatchedEpisodes(episodeConsumer: { episodes in
            var newTimes = [String]()
            var newEpisodes = [String:[TVMazeEpisode]]()
            self.timePairs.removeAll()
            for episode in episodes {
                if let airdate = episode.airdate {
                    let timePair = self.timeName(for: airdate)
                    let time = timePair.0
                    if !newTimes.contains(time) {
                        self.timePairs.append(timePair)
                        newTimes.append(time)
                    }
                    var showEpisodes = newEpisodes[time] ?? [TVMazeEpisode]()
                    showEpisodes.append(episode)
                    newEpisodes[time] = showEpisodes
                }
            }
            self.timePairs.sort(by: {$0.1 < $1.1})
            newTimes = self.timePairs.compactMap { $0.0 } //array of sorted time names
            for time in newEpisodes.keys {
                if let episodes = newEpisodes[time] {
                    newEpisodes[time] = episodes.sorted(by: {
                        "\($0.airdate ?? "9999")\($0.showName ?? "")" < "\($1.airdate ?? "9999")\($1.showName ?? "")"
                    })
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

    func timeName(for airdateText: String) -> (String, Int) {
        let airDate = dateFormat.date(from: airdateText) ?? Date(timeIntervalSince1970: 31557600*129) //year 2099
        let localToday = DateInRegion(Date(), region: Region.local).dateAt(.startOfDay)
        let aired = DateInRegion(airDate, region: .UTC)
        if aired.isBeforeDate(localToday, granularity: .day) {
            return ("Previously", -1)
        }
        let daysUntil = Int(localToday.getInterval(toDate: aired, component: .day))
        switch daysUntil {
        case 0:
            return ("Today", 0)
        case 1,2,3,4,5,6:
            return (aired.weekdayName(.default), daysUntil)
        default:
            return ("Coming Soon", 7)
        }
    }
}
