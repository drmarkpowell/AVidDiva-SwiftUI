//
//  AVidDivaTest.swift
//  AVidDivaTests
//
//  Created by Powell, Mark W (397M) on 10/28/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Quick
import Nimble

class AVidSpec: QuickSpec {
    override func spec() {
        describe("test Network API") {
            context("query shows by title") {
                it("should return some shows") {
                    let api = NetworkAPI.shared
                    api.getShows("Doctor", showConsumer: { shows in
                        for show in shows {
                            print("\(String(describing: show.name))")
                        }
                        expect(10).to(equal(shows.count))
                    })
                }
            }
        }
        
        describe("test String URL encoding") {
            context("url encode a string") {
                it("should return a percent encoded URL slug") {
                    let urlSlug = "doctor who"
                    let encoded = urlSlug.stringByAddingPercentEncodingForRFC3986()
                    expect(encoded).to(equal("doctor%20who"))
                }
            }
        }
    }
}
