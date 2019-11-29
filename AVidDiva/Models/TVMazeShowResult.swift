//
//  TVMazeShow.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 10/27/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation
import CloudKit

//https://api.tvmaze.com/shows/38963
public struct TVMazeShowResult: Codable {
    var show: TVMazeShow
}

public struct TVMazeShow: Codable, Identifiable, Comparable {
    public static func < (lhs: TVMazeShow, rhs: TVMazeShow) -> Bool {
        if let lhsName = lhs.name, let rhsName = rhs.name {
            return lhsName < rhsName
        }
        return lhs.id < rhs.id
    }
    
    public static func == (lhs: TVMazeShow, rhs: TVMazeShow) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: Int
    var name: String?
    var premiered: String?
    var officialSite: String?
    var image: TVMazeImage?
    var summary: String?
}

public struct TVMazeImage: Codable {
    var medium: String
}

//https://api.tvmaze.com/shows/210/episodes?specials=1
public struct TVMazeEpisodes: Codable {
    var episodes: [TVMazeEpisode]
}

public struct TVMazeEpisode: Codable, Identifiable, Comparable {
    
    public static func < (lhs: TVMazeEpisode, rhs: TVMazeEpisode) -> Bool {
        if let lhsAirdate = lhs.airdate, let rhsAirdate = rhs.airdate {
            if lhsAirdate < rhsAirdate {
                return true
            } else if lhsAirdate == rhsAirdate {
                if let lhsAirtime = lhs.airtime, let rhsAirtime = rhs.airtime {
                    return lhsAirtime < rhsAirtime
                }
            }
        }
        return lhs.id < rhs.id
    }
    
    public static func == (lhs: TVMazeEpisode, rhs: TVMazeEpisode) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: Int
    var showId: Int?
    var name: String?
    var season: Int?
    var number: Int?
    var airdate: String?
    var airtime: String?
    var image: TVMazeImage?
    var summary: String?
    var watched: Bool?
    
    func subtitle() -> String {
        let seasonNum = String("\(season ?? 0)")
        let episodeNum = String("\(number ?? 0)")
        let monthDay = TVMazeEpisode.formatMonthDay(TVMazeEpisode.parseDate(airdate))
        return "S\(seasonNum)E\(episodeNum)  \(monthDay)"
    }
    
    static func parseDate(_ datetext: String?) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        if let text = datetext {
            if let date = dateFormat.date(from: text) {
                return date
            }
        }
        return Date(timeIntervalSince1970: 31557600*129) //year 2099
    }
    
    static func formatMonthDay(_ airDate: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd"
        let monthDay = Date().timeIntervalSince(airDate) > 0 ? "  Aired " : "  Airs "
        return monthDay + dateFormat.string(from: airDate)
    }
    
    func getSummary() -> String {
        if let summary = summary {
            var summaryString = summary.replacingOccurrences(of: "<p>", with: "")
            summaryString = summaryString.replacingOccurrences(of: "</p>", with: "")
            return summaryString
        }
        return "No summary available."
    }

}
