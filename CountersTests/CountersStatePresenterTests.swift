//
//  CountersTests.swift
//  CountersTests
//
//

import XCTest
@testable import Counters

class CountersStatePresenterTests: XCTestCase {

    private let statePresenter = CountersStatePresenter()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let presenter = CountersListViewPresenter()
        let barPresenter = CountersBarPresenter()
        let viewController = CountersListViewController(presenter: presenter, barPresenter: barPresenter)

        self.statePresenter.countersListViewController = viewController
        self.statePresenter.barPresenter = barPresenter
        self.statePresenter.countersListpresenter = presenter
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetLoadingState() throws {
        statePresenter.setLoadingState()
        XCTAssertEqual(statePresenter.countersListViewController.innerView.currentState , .loading)
    }

    func testSetErrorState() throws {
        statePresenter.setErrorState()
        XCTAssertEqual(statePresenter.countersListViewController.innerView.currentState , .error)
    }

    func testSetEmptyState() throws {
        statePresenter.setEmptyState()
        XCTAssertEqual(statePresenter.countersListViewController.innerView.currentState , .empty)
    }

    func testSetContentState() throws {
        statePresenter.setContentState()
        XCTAssertEqual(statePresenter.countersListViewController.innerView.currentState , .content)
    }
}
