//
//  AnimeRepository.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation
import RxSwift

protocol AnimeRepositoryType {
    func getListGhibli(_ limit: Int?) -> Observable<[Ghibli]>
}

final class AnimeRepository: AnimeRepositoryType {
    let animeService: AnimeServiceType
    
    init(animeService: AnimeServiceType) {
        self.animeService = animeService
    }
}

extension AnimeRepository {
    
    func getListGhibli(_ limit: Int?) -> Observable<[Ghibli]> {
        return animeService.getListGhibli(limit).map({ $0 ?? [] })
    }
}
