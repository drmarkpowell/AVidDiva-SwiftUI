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

    func addOrUpdateSubscription(show: TVMazeShow, update: Bool = false) {
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

        if update {
            let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [record])
            privateDB.add(modifyRecordsOperation)
        } else {
            privateDB.save(record) { (record, error) in
                if error != nil {
                    print("Error saving \(String(describing: record)): \(String(describing: error))")
                }
            }
        }
    }

}
