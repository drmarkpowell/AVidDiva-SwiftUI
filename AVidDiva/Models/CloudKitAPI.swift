//
//  CloudKitAPI.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/23/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitAPI {

    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase

    static let shared = CloudKitAPI()

    private init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    func querySubscribedShows(showConsumer: @escaping ([TVMazeShow])->()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SubscribedShow", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let records = records {
                var shows = [TVMazeShow]()
                for record in records {
                    if let mazeId = record.value(forKey: "mazeId") as? Int {
                        var show = TVMazeShow(id: mazeId, name: nil, premiered: nil, officialSite: nil, image: nil, summary: nil)
                        show.name = record.value(forKey: "name") as? String
                        show.premiered = record.value(forKey: "premiered") as? String
                        show.officialSite = record.value(forKey: "officialSite") as? String
                        if let imageLocator = record.value(forKey: "mediumImageLocator") as? String {
                            show.image = TVMazeImage(medium: imageLocator)
                        }
                        show.summary = record.value(forKey: "summary") as? String
                        shows.append(show)
                    }
                }
                showConsumer(shows)
            }
        }
    }
    
    func querySubscribedEpisodes(episodeConsumer: @escaping ([TVMazeEpisode])->()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SubscribedEpisode", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let records = records {
                var episodes = [TVMazeEpisode]()
                for record in records {
                    if let mazeId = record.value(forKey: "mazeId") as? Int {
                        var episode = TVMazeEpisode(id: mazeId, showId: 0, name: nil, season: nil, number: nil, airdate: nil, airtime: nil, image: nil, summary: nil, watched: nil)
                        episode.name = record.value(forKey: "name") as? String
                        if let showId = record.value(forKey: "showId") as? Int {
                            episode.showId = showId
                        } else {
                            continue
                        }
                        episode.season = record.value(forKey: "season") as? Int
                        episode.number = record.value(forKey: "number") as? Int
                        episode.airdate = record.value(forKey: "airdate") as? String
                        episode.airtime = record.value(forKey: "airtime") as? String
                        if let imageLocator = record.value(forKey: "mediumImageLocator") as? String {
                            episode.image = TVMazeImage(medium: imageLocator)
                        }
                        episode.summary = record.value(forKey: "summary") as? String
                        episode.watched = (record.value(forKey: "watched") as? NSNumber)?.boolValue
                        episodes.append(episode)
                    }
                }
            }
        }
    }
    
    func addOrUpdateSubscription(show: TVMazeShow, showConsumer: @escaping ()->(), update: Bool = false) {
        let record = CKRecord(recordType: "SubscribedShow")
        record.setValue(show.id, forKey: "mazeId")
        if let imageLocator = show.image?.medium {
            record.setValue(imageLocator, forKey: "mediumImageLocator")
        }
        if let name = show.name {
            record.setValue(name, forKey: "name")
        }
        if let premiered = show.premiered {
            record.setValue(premiered, forKey: "premiered")
        }
        if let officialSite = show.officialSite {
            record.setValue(officialSite, forKey: "officialSite")
        }
        if let summary = show.summary {
            record.setValue(summary, forKey: "summary")
        }
        addOrUpdate(record: record, update: update, callback: showConsumer)
    }
    
    func addOrUpdateEpisode(episode: TVMazeEpisode, showId: Int, episodeConsumer: @escaping ()->(), update: Bool = false) {
        let record = CKRecord(recordType: "SubscribedEpisode")
        record.setValue(episode.id, forKey: "mazeId")
        record.setValue(showId, forKey: "mazeShowId")
        if let name = episode.name {
            record.setValue(name, forKey: "name")
        }
        if let season = episode.season {
            record.setValue(season, forKey: "season")
        }
        if let number = episode.number {
            record.setValue(number, forKey: "number")
        }
        if let airdate = episode.airdate {
            record.setValue(airdate, forKey: "airdate")
        }
        if let airtime = episode.airtime {
            record.setValue(airtime, forKey: "airtime")
        }
        if let imageLocator = episode.image?.medium {
            record.setValue(imageLocator, forKey: "mediumImageLocator")
        }
        if let summary = episode.summary {
            record.setValue(summary, forKey: "summary")
        }
        record.setValue(false, forKey: "watched")
        
        addOrUpdate(record: record, update: update, callback: episodeConsumer)
    }

    private func addOrUpdate(record: CKRecord, update: Bool, callback: @escaping ()->()) {
        if update {
            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [record])
            modifyRecordsOperation.modifyRecordsCompletionBlock = { (records, ids, error) in
                DispatchQueue.main.async {
                    callback()
                }
            }
            privateDB.add(modifyRecordsOperation)
        } else {
            privateDB.save(record) { (record, error) in
                if error != nil {
                    print("Error saving \(String(describing: record)): \(String(describing: error))")
                }
                DispatchQueue.main.async {
                    callback()
                }
            }
        }
    }
}
