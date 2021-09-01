//
//  MockAnimeItemRouter.swift
//  CleanArchitechtureTutorialTests
//
//  Created by Khoa Mai on 9/1/21.
//

import Foundation

class MockAnimeItemRouting: AnimeRouting {
    
    var invokedRouteToDetail = false
    var invokedRouteToDetailCount = 0
    var invokedRouteToDetailParameters: (model: Ghibli, Void)?
    var invokedRouteToDetailParametersList = [(model: Ghibli, Void)]()

    func routeToDetail(_ model: Ghibli) {
        invokedRouteToDetail = true
        invokedRouteToDetailCount += 1
        invokedRouteToDetailParameters = (model, ())
        invokedRouteToDetailParametersList.append((model, ()))
    }
}

