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
    var isShowEmptyView: BehaviorRelay<Bool> { get }
    var isCanLoadMore: BehaviorRelay<Bool> { get }
}

// MARK: - Routing
protocol AnimeRouting: AnyObject {
    func routeToDetail(_ model: Ghibli)
}

class AnimeViewModel: AnimeItemPresentableListener {
    
    weak var presenter: AnimeItemPresentable?
    weak var router: AnimeRouting?
    
    var loadMoreTrigger = PublishRelay<Void>.init()
    
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
    }
    
    private func configurePresenter() {
        
        guard let presenter = presenter else {
            return
        }
        
        buildLoadListingAction.elements.subscribeNext { [weak self] list in
            guard let `self` = self else {
                return
            }
            let ids = self.list.map({ $0.id })
            for item in list {
                if !ids.contains(item.id) {
                    self.list.append(item)
                }
            }
        }.disposed(by: disposeBag)
        
        buildLoadListingAction.elements.map { [weak self] list in
            guard let `self` = self else {
                return true
            }
            if (list.isEmpty || list.count < 10) && (!(self.list.isEmpty)) {
                return false
            }
            return true
        }.bind(to: presenter.isCanLoadMore).disposed(by: disposeBag)
        
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
