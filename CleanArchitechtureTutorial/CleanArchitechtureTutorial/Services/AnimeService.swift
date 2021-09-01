//
//  AnimeService.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation
import RxSwift

protocol AnimeServiceType {
    func getListGhibli(_ limit: Int?) -> Observable<[Ghibli]?>
}

final class AnimeService: AnimeServiceType {
    
    let executionScheduler: SchedulerType
    let resultScheduler: SchedulerType
    
    public init(
        executionScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()),
        resultScheduler: SchedulerType = MainScheduler.instance
    ) {
        self.executionScheduler = executionScheduler
        self.resultScheduler = resultScheduler
    }
}

extension AnimeService {
    
    func getListGhibli(_ limit: Int?) -> Observable<[Ghibli]?> {
        return AnimeTargets.FetchGhibliListTarget(ghibliParams: GhibliConstant.GetListParams.init(limit: limit)).execute().observeOn(resultScheduler)
    }
}
