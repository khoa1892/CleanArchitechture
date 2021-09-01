//
//  AnimeItemViewModelSpec.swift
//  CleanArchitechtureTutorialTests
//
//  Created by Khoa Mai on 9/1/21.
//

import Foundation
import RxCocoa
import RxSwift
import Quick
import Nimble
import ObjectMapper

final class AnimeItemViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: AnimeViewModel!
        var mockRespository: MockAnimeRepository!
        var mockPresenter: MockAnimeItemPresenter!
        var mockRouting: MockAnimeItemRouting!
        
        let anime = Ghibli.init(JSONString: animeJson)!
        
        beforeEach {
            
            mockRespository = MockAnimeRepository()
            mockPresenter = MockAnimeItemPresenter()
            mockRouting = MockAnimeItemRouting()
            
            sut = AnimeViewModel.init(animeRepository: mockRespository)
            
            sut.presenter = mockPresenter
            sut.router = mockRouting
            
            mockPresenter.stubbedListener = sut
            
            mockPresenter.stubbedIsCanLoadMore = BehaviorRelay<Bool>.init(value: false)
            mockPresenter.stubbedAnimeCellViewModels = BehaviorRelay<[AnimeCellViewModel]>.init(value: [])
            
            mockRespository.stubbedGetListGhibliResult = .just([anime])
            
            sut.didBecomeActive()
        }
        
        describe("ViewModel is becomeactive") {
            context("when setup view model") {
                beforeEach {
                    sut.didBecomeActive()
                }
                it("should listener will be setup") {
                    expect(mockPresenter.listener).toNot(beNil())
                }
            }
            context("When get list response success") {
                it("should list will response") {
                    expect(sut.list.count) == 1
                }
                
                it("should presenter will send 1 cellModels") {
                    expect(mockPresenter.invokedAnimeCellViewModelsGetter).to(equal(true))
                    expect(mockPresenter.animeCellViewModels.value.count) == 1
                }
            }
        }
        
//        describe("User full loadmore page") {
//            beforeEach {
//                sut.loadMoreTrigger.accept(())
//            }
//
//            it("should presenter will send 2 cellModels") {
//                expect(mockPresenter.invokedAnimeCellViewModelsGetter) == true
//                expect(mockPresenter.animeCellViewModels.value.count) == 2
//            }
//
//            it("should presenter will call isLoading") {
//                expect(mockPresenter.invokedIsCanLoadMoreGetter) == true
//            }
//        }
        
        describe("User search by keyword") {
            beforeEach {
                sut.searchTrigger.accept("Ca")
            }
            it("should presenter will send 1 cellModels") {
                expect(mockPresenter.invokedAnimeCellViewModelsGetter) == true
                expect(mockPresenter.animeCellViewModels.value.count) == 1
            }
        }
        
        describe("User click go to room detail") {
            
            context("when status room is active") {
                beforeEach {
                    sut.clickOnAnimeTrigger.accept(AnimeCellViewModel.init(item: anime))
                }
                it("should will route to room detail view") {
                    expect(mockRouting.invokedRouteToDetailParameters?.0.id) === anime.id
                    expect(mockRouting.invokedRouteToDetailCount) == 1
                    expect(mockRouting.invokedRouteToDetail) == true
                }
            }
        }
        
    }
    
    let animeJson = """
        {
            "id": "2baf70d1-42bb-4437-b551-e5fed5a87abe",
            "title": "Castle in the Sky",
            "original_title": "天空の城ラピュタ",
            "original_title_romanised": "Tenkū no shiro Rapyuta",
            "description": "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa. With the help of resourceful Pazu and a rollicking band of sky pirates, she makes her way to the ruins of the once-great civilization. Sheeta and Pazu must outwit the evil Muska, who plans to use Laputa's science to make himself ruler of the world.",
            "director": "Hayao Miyazaki",
            "producer": "Isao Takahata",
            "release_date": "1986",
            "running_time": "124",
            "rt_score": "95",
            "people": [
            "https://ghibliapi.herokuapp.com/people/"
            ],
            "species": [
            "https://ghibliapi.herokuapp.com/species/af3910a6-429f-4c74-9ad5-dfe1c4aa04f2"
            ],
            "locations": [
            "https://ghibliapi.herokuapp.com/locations/"
            ],
            "vehicles": [
            "https://ghibliapi.herokuapp.com/vehicles/"
            ],
            "url": "https://ghibliapi.herokuapp.com/films/2baf70d1-42bb-4437-b551-e5fed5a87abe"
        }
        """
}
