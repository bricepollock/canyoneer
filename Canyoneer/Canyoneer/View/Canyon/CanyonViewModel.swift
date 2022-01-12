//
//  CanyonViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

class CanyonViewModel {
    
    // Rx
    public let canyonObservable: Observable<Canyon>
    private let canyonSubject: PublishSubject<Canyon>
    
    public let isFavorite: Observable<Bool>
    private let isFavoriteSubject: PublishSubject<Bool>
    
    // state
    public var canyon: Canyon?
    private let canyonId: String
    
    // objects
    private let service: RopeWikiServiceInterface
    private let bag = DisposeBag()
    
    init(canyonId: String, service: RopeWikiServiceInterface = RopeWikiService()) {
        self.canyonId = canyonId
        self.service = service
        
        self.canyonSubject = PublishSubject()
        self.canyonObservable = self.canyonSubject.asObservable()
        
        self.isFavoriteSubject = PublishSubject()
        self.isFavorite = self.isFavoriteSubject.asObservable()
    }
    
    // MARK: Actions
    public func refresh() {
        self.service.canyon(for: self.canyonId).subscribe { [weak self] canyon in
            guard let self = self else { return }
            guard let canyon = canyon else { return }
            self.canyon = canyon
            self.canyonSubject.onNext(canyon)
            
            let isFavorite = UserPreferencesStorage.isFavorite(canyon: canyon)
            self.isFavoriteSubject.onNext(isFavorite)
        } onFailure: { error in
            Global.logger.error("\(String(describing: error))")
        }.disposed(by: self.bag)
    }
    
    public func toggleFavorite() {
        guard let canyon = canyon else { return }
        
        let isFavorited = UserPreferencesStorage.isFavorite(canyon: canyon)
        if isFavorited {
            UserPreferencesStorage.removeFavorite(canyon: canyon)
        } else {
            UserPreferencesStorage.addFavorite(canyon: canyon)
        }
        self.isFavoriteSubject.onNext(!isFavorited)
    }
}
