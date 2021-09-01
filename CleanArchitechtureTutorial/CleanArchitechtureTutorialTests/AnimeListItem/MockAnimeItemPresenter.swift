//
//  MockAnimeItemPresenter.swift
//  CleanArchitechtureTutorialTests
//
//  Created by Khoa Mai on 9/1/21.
//

import Foundation
import RxCocoa
import RxSwift

class MockAnimeItemPresenter: AnimeItemPresentable {

    var invokedListenerSetter = false
    var invokedListenerSetterCount = 0
    var invokedListener: AnimeItemPresentableListener?
    var invokedListenerList = [AnimeItemPresentableListener?]()
    var invokedListenerGetter = false
    var invokedListenerGetterCount = 0
    var stubbedListener: AnimeItemPresentableListener!

    var listener: AnimeItemPresentableListener? {
        set {
            invokedListenerSetter = true
            invokedListenerSetterCount += 1
            invokedListener = newValue
            invokedListenerList.append(newValue)
        }
        get {
            invokedListenerGetter = true
            invokedListenerGetterCount += 1
            return stubbedListener
        }
    }

    var invokedAnimeCellViewModelsGetter = false
    var invokedAnimeCellViewModelsGetterCount = 0
    var stubbedAnimeCellViewModels: BehaviorRelay<[AnimeCellViewModel]>!

    var animeCellViewModels: BehaviorRelay<[AnimeCellViewModel]> {
        invokedAnimeCellViewModelsGetter = true
        invokedAnimeCellViewModelsGetterCount += 1
        return stubbedAnimeCellViewModels
    }

    var invokedIsCanLoadMoreGetter = false
    var invokedIsCanLoadMoreGetterCount = 0
    var stubbedIsCanLoadMore: BehaviorRelay<Bool>!

    var isCanLoadMore: BehaviorRelay<Bool> {
        invokedIsCanLoadMoreGetter = true
        invokedIsCanLoadMoreGetterCount += 1
        return stubbedIsCanLoadMore
    }
}
