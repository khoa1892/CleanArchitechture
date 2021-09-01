//
//  MockAnimeService.swift
//  CleanArchitechtureTutorialTests
//
//  Created by Khoa Mai on 9/1/21.
//

import Foundation
import RxCocoa
import RxSwift

final class MockAnimeService: AnimeServiceType {

    var invokedGetListGhibli = false
    var invokedGetListGhibliCount = 0
    var invokedGetListGhibliParameters: (limit: Int?, Void)?
    var invokedGetListGhibliParametersList = [(limit: Int?, Void)]()
    var stubbedGetListGhibliResult: Observable<[Ghibli]?>!

    func getListGhibli(_ limit: Int?) -> Observable<[Ghibli]?> {
        invokedGetListGhibli = true
        invokedGetListGhibliCount += 1
        invokedGetListGhibliParameters = (limit, ())
        invokedGetListGhibliParametersList.append((limit, ()))
        return stubbedGetListGhibliResult
    }
}
