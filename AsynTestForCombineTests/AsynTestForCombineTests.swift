//
//  AsynTestForCombineTests.swift
//  AsynTestForCombineTests
//
//  Created by rhino Q on 2021/11/22.
//  https://cassiuspacheco.com/synchronising-combines-publishers-for-easy-testing-ck8wl8p2g01d3lcs11t62zixb
// https://www.youtube.com/watch?v=1SUFMcYjCpE&t=1242s&ab_channel=EssentialDeveloper

import XCTest
import Combine

class ViewModel {
    private let valueSubject = CurrentValueSubject<Int, Never>(0)
    
    var valuePublisher:AnyPublisher<String, Never> {
        valueSubject.map { value in
            "\(value)"
        }.eraseToAnyPublisher()
    }
    
    func set(value: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.valueSubject.send(value)
        }
    }
}

class AsynTestForCombineTests: XCTestCase {
    private var cancellable: Set<AnyCancellable> = .init()

    func test_init() {
        let viewModel = ViewModel()
        let spy = ValueSpy(viewModel.valuePublisher)
        XCTAssertEqual(spy.values, ["0"])
    }
    
    func test_set() {
        let exp = expectation(description: "test")
        let viewModel = ViewModel()
        let spy = ValueSpy(viewModel.valuePublisher, prefix: 2)
        spy.exp = exp
        viewModel.set(value: 1)
        
        waitForExpectations(timeout: 2)
        XCTAssertEqual(spy.values, ["0", "1"])
    }
}

private class ValueSpy {
    private(set) var values:[String] = []
    private var cancellable: Set<AnyCancellable> = .init()
    var exp:XCTestExpectation?
    
    init(_ publisher: AnyPublisher<String, Never>, prefix:Int = 999) {
        publisher
            .prefix(prefix)
            .sink( receiveCompletion: { [weak self] sadf in
            self?.exp?.fulfill()
        },receiveValue: { [weak self] value in
            self?.values.append(value)
        }) .store(in: &cancellable)
    }
}
