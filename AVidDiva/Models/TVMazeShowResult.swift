//
//  TVMazeShow.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 10/27/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation

public struct TVMazeShowResult: Codable {
    var show: TVMazeShow
}

public struct TVMazeShow: Codable, Identifiable {
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

//[
//{
//  "score": 30.38829,
//  "show": {
//    "id": 210,
//    "url": "http://www.tvmaze.com/shows/210/doctor-who",
//    "name": "Doctor Who",
//    "type": "Scripted",
//    "language": "English",
//    "genres": [
//      "Drama",
//      "Adventure",
//      "Science-Fiction"
//    ],
//    "status": "Running",
//    "runtime": 45,
//    "premiered": "2005-03-26",
//    "officialSite": "http://www.bbc.co.uk/programmes/b006q2x0",
//    "schedule": {
//      "time": "",
//      "days": [
//        "Sunday"
//      ]
//    },
//    "rating": {
//      "average": 8.6
//    },
//    "weight": 98,
//    "network": {
//      "id": 12,
//      "name": "BBC One",
//      "country": {
//        "name": "United Kingdom",
//        "code": "GB",
//        "timezone": "Europe/London"
//      }
//    },
//    "webChannel": null,
//    "externals": {
//      "tvrage": 3332,
//      "thetvdb": 78804,
//      "imdb": "tt0436992"
//    },
//    "image": {
//      "medium": "http://static.tvmaze.com/uploads/images/medium_portrait/161/404447.jpg",
//      "original": "http://static.tvmaze.com/uploads/images/original_untouched/161/404447.jpg"
//    },
//    "summary": "<p>Adventures across time and space with the time travelling alien and companions.</p>",
//    "updated": 1571902422,
//    "_links": {
//      "self": {
//        "href": "http://api.tvmaze.com/shows/210"
//      },
//      "previousepisode": {
//        "href": "http://api.tvmaze.com/episodes/1561480"
//      }
//    }
//  }
//},
//{
//  "score": 29.91501,
//  "show": {
//    "id": 766,
//    "url": "http://www.tvmaze.com/shows/766/doctor-who",
//    "name": "Doctor Who",
