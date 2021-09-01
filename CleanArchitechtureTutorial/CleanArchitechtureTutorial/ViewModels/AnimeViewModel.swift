//
//  AnimeViewModel.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Action

// MARK: - Presentable
protocol AnimeItemPresentable: AnyObject {
    var listener: AnimeItemPresentableListener? { get set }
    var animeCellViewModels: BehaviorRelay<[AnimeCellViewModel]> { get }
    var isCanLoadMore: BehaviorRelay<Bool> { get }
}

// MARK: - Routing
protocol AnimeRouting: AnyObject {
    func routeToDetail(_ model: Ghibli)
}

final class AnimeViewModel: AnimeItemPresentableListener {
    
    weak var presenter: AnimeItemPresentable?
    weak var router: AnimeRouting?
    
    var loadMoreTrigger = PublishRelay<Void>.init()
    var searchTrigger = PublishRelay<String>.init()
    var clickOnAnimeTrigger = PublishRelay<AnimeCellViewModel>.init()
    
    let disposeBag = DisposeBag()
    var list: [Ghibli] = [] {
        didSet {
            updateCellViewModels()
        }
    }
    
    lazy var buildLoadListingAction = buildGetListAction()
    
    let animeRepository: AnimeRepositoryType
    
    private var limit = 10
    
    init(animeRepository: AnimeRepositoryType) {
        self.animeRepository = animeRepository
    }
    
    func didBecomeActive() {
        presenter?.listener = self
        configurePresenter()
        configureTrigger()
        configureRouter()
    }
    
}

extension AnimeViewModel {
    
    private func configureRouter() {
        
        clickOnAnimeTrigger.subscribeNext { [weak self] viewModel in
            self?.router?.routeToDetail(viewModel.item)
        }.disposed(by: disposeBag)
    }
    
    private func updateCellViewModels() {
        let cellModels = list.map { item in
            AnimeCellViewModel.init(item: item)
        }
        presenter?.animeCellViewModels.accept(cellModels)
    }
    
    private func configureTrigger() {
        
        loadMoreTrigger.subscribeNext { [weak self] _ in
            self?.limit += 10
            self?.refreshList()
        }.disposed(by: disposeBag)
        
        searchTrigger.subscribeNext { [weak self] query in
            
            let list = self?.list.filter({ $0.title?.lowercased().contains(query.lowercased()) ?? false })
            if !query.isEmpty && list?.count ?? 0 > 0 {
                let cellModels = list?.map({ item in
                    AnimeCellViewModel.init(item: item)
                })
                self?.presenter?.animeCellViewModels.accept(cellModels ?? [])
            }
        }.disposed(by: disposeBag)
    }
    
    private func configurePresenter() {
        
        guard let presenter = presenter else {
            return
        }
        
        buildLoadListingAction.elements.subscribeNext { [weak self] items in
            guard let `self` = self else {
                return
            }
            let ids = self.list.map({ $0.id })
            var temps = [Ghibli]()
            for item in items {
                if !ids.contains(item.id) {
                    temps.append(item)
                }
            }
            self.list += temps
            if temps.count > 0 {
                presenter.isCanLoadMore.accept(true)
            } else {
                presenter.isCanLoadMore.accept(false)
            }
        }.disposed(by: disposeBag)
        
        refreshList()
    }
}

// MARK: - private logics
extension AnimeViewModel {
    
    private func refreshList() {
        buildLoadListingAction.execute(limit)
    }
}

// MARK: - Actions
extension AnimeViewModel {
    
    private func buildGetListAction() -> Action<Int?, [Ghibli]> {
        Action<Int?, [Ghibli]> { [unowned self] limit in
            self.animeRepository.getListGhibli(limit)
        }
    }
}
