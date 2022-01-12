//
//  FavoriteViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

class FavoriteViewModel {
    public let canyons: Observable<[Canyon]>
    private let canyonsSubject: PublishSubject<[Canyon]>
    
    private let favoriteService = FavoriteService()
    private let service: RopeWikiServiceInterface
    private let bag = DisposeBag()
    
    init(service: RopeWikiServiceInterface = RopeWikiService()) {
        self.service = service
        
        self.canyonsSubject = PublishSubject()
        self.canyons = self.canyonsSubject.asObservable()
    }
    
    func refresh() {        
        self.service.canyons().map { canyons in
            return canyons.filter { canyon in self.favoriteService.isFavorite(canyon: canyon) }
        }.subscribe { canyons in
            self.canyonsSubject.onNext(canyons)
        } onFailure: { error in
            Global.logger.error("\(String(describing: error))")
        }.disposed(by: self.bag)
    }
}
