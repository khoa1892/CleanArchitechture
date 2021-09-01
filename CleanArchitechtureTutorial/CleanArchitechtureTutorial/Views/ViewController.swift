//
//  ViewController.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol AnimeItemPresentableListener: AnyObject {
    var loadMoreTrigger: PublishRelay<Void> { get }
    var searchTrigger: PublishRelay<String> { get }
    var clickOnAnimeTrigger: PublishRelay<AnimeCellViewModel> { get }
}

class ViewController: UIViewController, AnimeItemPresentable {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchBar: UISearchBar!

    let viewModel = AnimeViewModel.init(animeRepository: AnimeRepository.init(animeService: AnimeService.init()))
    
    var listener: AnimeItemPresentableListener?
    
    var animeCellViewModels = BehaviorRelay<[AnimeCellViewModel]>.init(value: [])
    var isSearchText = BehaviorRelay<[AnimeCellViewModel]?>.init(value: [])
    
    var isShowEmptyView = BehaviorRelay<Bool>.init(value: false)
    
    var isCanLoadMore = BehaviorRelay<Bool>.init(value: false)
    
    let disposeBag = DisposeBag()
    
    typealias Section = SectionModel<String, AnimeCellViewModel>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource = initDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureListener()
        configurePresenter()
    }
}

// MARK: - Configure
extension ViewController {
    
    private func configureViewModel() {
        viewModel.presenter = self
        viewModel.router = self
        viewModel.didBecomeActive()
    }
    
    private func configureListener() {
        guard let listener = self.listener else { return }
        
        tableView.rx.modelSelected(AnimeCellViewModel.self)
            .bind(to: listener.clickOnAnimeTrigger).disposed(by: disposeBag)
        
        tableView.rx.reachedBottom.filter { [weak self] _ in
            guard let `self` = self else {
                return false
            }
            return self.isCanLoadMore.value
        }.bind(to: listener.loadMoreTrigger).disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty.bind(to: listener.searchTrigger).disposed(by: disposeBag)
    }
    
    private func configurePresenter() {
        
        animeCellViewModels
            .asDriver(onErrorJustReturn: [])
            .map({ [Section(model: "", items: $0)] })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension ViewController: AnimeRouting {
    
    func routeToDetail(_ model: Ghibli) {
        
    }
}

extension ViewController {
    
    func initDataSource() -> RxTableViewSectionedReloadDataSource<Section> {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { (_, tableView, indexPath, model) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "GhibliCell", for: indexPath) as? GhibliCell
                cell?.model = model
                return cell ?? UITableViewCell()
        }, canEditRowAtIndexPath: { _, _ in
            return false
        })
    }
}
