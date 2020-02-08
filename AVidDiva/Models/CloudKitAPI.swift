//
//  CloudKitAPI.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/23/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import CloudKit
import Combine
import Foundation
import UIKit

class CloudKitAPI {

    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase

    static let shared = CloudKitAPI()
    var showRecords = [Int:CKRecord]()
    var episodeRecords = [Int:CKRecord]()
    var getShowCancellables = [AnyCancellable]()
    var records = [CKRecord]()
    var episodeConsumer: (([TVMazeEpisode])->())?
    var showConsumer: (([TVMazeShow])->())?

    private init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    func checkForNewEpisodes(completionHandler: (UIBackgroundFetchResult) -> Void) {
        getShowCancellables.removeAll()
        if !episodeRecords.isEmpty {
            for (showIndex, showRecord) in showRecords {
                let showName = showRecord.value(forKey: "name") ?? "No Show"
                print("Updating \(showName)")
                if let subUpdated = showRecord.value(forKey: "updated") as? Int {
                    if let cancellable = NetworkAPI.shared.getShow(showIndex, showConsumer: { show in
                        if let show = show {
                            if subUpdated < show.updated {
                                CloudKitAPI.shared.addOrUpdateSubscription(show: show, showConsumer: { error in
                                    if let error = error {
                                        print("Error updating show: \(error.localizedDescription)")
                                    }
                                })
                                NetworkAPI.shared.getEpisodes(show, episodeConsumer: { episodes in
                                    for episode in episodes {
                                        print("Updating \(showName) episode: \(episode.name ?? "Untitled")")
                                        CloudKitAPI.shared.addOrUpdateEpisode(episode: episode, show: show, episodeConsumer: { error in
                                            if let error = error {
                                                print("Error updating: \(error.localizedDescription)")
                                            }
                                        })
                                    }
                                })
                            } else {
                                print("\(showName) is up to date.")
                            }
                        }
                    }) {
                        getShowCancellables.append(cancellable)
                    }
                }
            }
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    func toggleEpisodeWatched(episode: TVMazeEpisode, callback: @escaping (Error?)->()) {
        if let episodeRecord = episodeRecords[episode.id] {
            episodeRecord.setValue(episode.watched ?? false, forKey: "watched")
            episodeRecords[episode.id] = episodeRecord
            addOrUpdate(record: episodeRecord, update: true, callback: callback)
        }
    }
    
    func querySubscribedShows(showConsumer: @escaping ([TVMazeShow])->()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SubscribedShow", predicate: predicate)
        self.showConsumer = showConsumer
        let queryOp = CKQueryOperation(query: query)
        queryOp.recordFetchedBlock = recordFetched(record:)
        queryOp.queryCompletionBlock = showFetchCompletion(cursor:error:)
        privateDB.add(queryOp)
    }
    
    func querySubscribedEpisodes(showId: Int, episodeConsumer: @escaping ([TVMazeEpisode])->()) {
        querySubscribedEpisodes(predicate: NSPredicate(format: "mazeShowId == %d", showId),
                                episodeConsumer: episodeConsumer)
    }
    
    func queryAllSubscribedEpisodes(episodeConsumer: @escaping ([TVMazeEpisode])->()) {
        querySubscribedEpisodes(predicate: NSPredicate(value: true), episodeConsumer: episodeConsumer)
    }
    
    func queryUnwatchedEpisodes(episodeConsumer: @escaping ([TVMazeEpisode])->()) {
//        if episodeRecords.isEmpty {
            let predicate = NSPredicate(format: "watched == %@", NSNumber(booleanLiteral: false))
            querySubscribedEpisodes(predicate: predicate, episodeConsumer: episodeConsumer)
//        } else {
//            var episodes = [TVMazeEpisode]()
//            for (_, record) in episodeRecords {
//                if let mazeId = record.value(forKey: "mazeId") as? Int {
//                    let watched = (record.value(forKey: "watched") as? NSNumber)?.boolValue
//                    if watched == false {
//                        episodes.append(makeEpisode(mazeId, record))
//                    }
//                }
//            }
//            episodes.sort()
//            episodeConsumer(episodes)
//        }
    }
    
    func recordFetched(record: CKRecord) {
        records.append(record)
    }
    
    func showFetchCompletion(cursor: CKQueryOperation.Cursor?, error: Error?) {
        if let error = error {
            print("Error reading from CloudKit DB: \(error)")
        } else if let cursor = cursor { //more data to fetch
            print("Got back max number of records")
            let nextOperation = CKQueryOperation(cursor: cursor)
            nextOperation.recordFetchedBlock = recordFetched(record:)
            nextOperation.queryCompletionBlock = showFetchCompletion(cursor:error:)
            self.privateDB.add(nextOperation)
        } else {
            var shows = [TVMazeShow]()
            for record in records {
                if let mazeId = record.value(forKey: "mazeId") as? Int {
                    var show = TVMazeShow(id: mazeId, updated: 0)
                    show.name = record.value(forKey: "name") as? String
                    show.premiered = record.value(forKey: "premiered") as? String
                    show.officialSite = record.value(forKey: "officialSite") as? String
                    if let updated = record.value(forKey: "updated") as? Int {
                        show.updated = updated
                    }
                    if let imageLocator = record.value(forKey: "mediumImageLocator") as? String {
                        show.image = TVMazeImage(medium: imageLocator)
                    }
                    show.summary = record.value(forKey: "summary") as? String
                    shows.append(show)
                    self.showRecords[show.id] = record
                }
            }
            shows.sort()
            showConsumer?(shows)
            showConsumer = nil
            records.removeAll()
        }
    }
    
    func episodeFetchCompletion(cursor: CKQueryOperation.Cursor?, error: Error?) {
        if let error = error {
            print("Error reading from CloudKit DB: \(error)")
        } else if let cursor = cursor { //more data to fetch
            print("Got back max number of records")
            let nextOperation = CKQueryOperation(cursor: cursor)
            nextOperation.recordFetchedBlock = recordFetched(record:)
            nextOperation.queryCompletionBlock = episodeFetchCompletion(cursor:error:)
            self.privateDB.add(nextOperation)
        } else {
            print("CloudKit return total of \(records.count) records.")
            var episodes = [TVMazeEpisode]()
            for record in records {
                if let mazeId = record.value(forKey: "mazeId") as? Int {
                    let episode = self.makeEpisode(mazeId, record)
                    episodes.append(episode)
                    self.episodeRecords[episode.id] = record
                }
            }
            episodes.sort()
            episodeConsumer?(episodes)
            episodeConsumer = nil //clean up reference to consumer closure
            records.removeAll()   //clean up record cache
        }
    }
        
    func querySubscribedEpisodes(predicate: NSPredicate, episodeConsumer: @escaping ([TVMazeEpisode])->()) {
        let query = CKQuery(recordType: "SubscribedEpisode", predicate: predicate)
        self.episodeConsumer = episodeConsumer
        let queryOp = CKQueryOperation(query: query)
        queryOp.recordFetchedBlock = recordFetched(record:)
        queryOp.queryCompletionBlock = episodeFetchCompletion(cursor:error:)
        privateDB.add(queryOp)
    }
        
    func makeEpisode(_ mazeId: Int, _ record: CKRecord) -> TVMazeEpisode {
        var episode = TVMazeEpisode(id: mazeId, showId: 0)
        episode.name = record.value(forKey: "name") as? String
        if let showId = record.value(forKey: "mazeShowId") as? Int {
            episode.showId = showId
        }
        if let showRecord = record.value(forKey: "showRecord") as? CKRecord {
            episode.showRecord = showRecord
        }
        episode.showName = record.value(forKey: "showName") as? String
        episode.season = record.value(forKey: "season") as? Int
        episode.number = record.value(forKey: "number") as? Int
        episode.airdate = record.value(forKey: "airdate") as? String
        episode.airtime = record.value(forKey: "airtime") as? String
        if let imageLocator = record.value(forKey: "mediumImageLocator") as? String {
            episode.image = TVMazeImage(medium: imageLocator)
        }
        episode.summary = record.value(forKey: "summary") as? String
        episode.watched = (record.value(forKey: "watched") as? NSNumber)?.boolValue
        return episode
    }
    
    func addOrUpdateSubscription(show: TVMazeShow, showConsumer: @escaping (Error?)->()) {
        var record:CKRecord
        var update = false
        if let rec = showRecords[show.id] {
            update = true
            record = rec
        }
        else {
            record = CKRecord(recordType: "SubscribedShow",
                              recordID: CKRecord.ID(recordName: "SubscribedShow\(show.id)"))
        }
        
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
        record.setValue(show.updated, forKey: "updated")
        self.showRecords[show.id] = record
        addOrUpdate(record: record, update: update, callback: showConsumer)
    }
    
    func addOrUpdateEpisode(episode: TVMazeEpisode, show: TVMazeShow,
                            episodeConsumer: @escaping (Error?)->()) {
        var record:CKRecord
        var update = false
        if let rec = episodeRecords[episode.id] {
            update = true
            record = rec
        }
        else {
            record = CKRecord(recordType: "SubscribedEpisode",
                              recordID: CKRecord.ID(recordName: "SubscribedEpisode\(episode.id)"))
        }
        record.setValue(episode.id, forKey: "mazeId")
        record.setValue(show.id, forKey: "mazeShowId")
        if let showName = show.name {
            record.setValue(showName, forKey: "showName")
        }
        if let showRecord = showRecords[show.id] {
            let ref = CKRecord.Reference(record: showRecord, action: .deleteSelf)
            record.setValue(ref, forKey: "showRecord")
        }
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
        if let watched = record.value(forKey: "watched") as? Bool {
            record.setValue(watched, forKey: "watched") //updating a record preserves its watched value
        } else {
            record.setValue(false, forKey: "watched") //a new record always gets an unwatched status
        }
        
        self.episodeRecords[episode.id] = record
        addOrUpdate(record: record, update: update, callback: episodeConsumer)
    }

    private func addOrUpdate(record: CKRecord, update: Bool, callback: @escaping (Error?)->()) {
        if update {
            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [record])
            modifyRecordsOperation.modifyRecordsCompletionBlock = { (records, ids, error) in
                DispatchQueue.main.async {
                    callback(error)
                }
            }
            privateDB.add(modifyRecordsOperation)
        } else {
            privateDB.save(record) { (record, error) in
                if error != nil {
                    print("Error saving \(String(describing: record)): \(String(describing: error))")
                }
                DispatchQueue.main.async {
                    callback(error)
                }
            }
        }
    }
}
