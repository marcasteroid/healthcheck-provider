@testable import HealthCheckProvider
@testable import Vapor
import Testing
import XCTest

extension Droplet {
  static func testable() throws -> Droplet {
    var config = try! Config(arguments: ["vapor", "--env=test"])
    try! config.set("healthcheck.url", "healthcheck")
    try! config.addProvider(HealthCheckProvider.Provider.self)
    return try Droplet(config)
  }

  func servInBackground() throws {
    background {
      try! self.run()
    }
    console.wait(seconds: 0.5)
  }
}

final class ProviderTests: XCTestCase {

    let drop = try! Droplet.testable()

    override func setUp() {
      Testing.onFail = XCTFail
    }

    func testHealthCheck() {
      try! drop
        .testResponse(to: .get, at: "healthcheck")
        .assertStatus(is: .ok)
        .assertJSON("status", equals: "up")
    }

    static var allTests = [
        ("testHealthCheck", testHealthCheck),
    ]
}
