//
//  AnimeCellViewModel.swift
//  CleanArchitechtureTutorial
//
//  Created by Khoa Mai on 8/20/21.
//

import Foundation

struct AnimeCellViewModel {
    
    let tilte: String?
    let item: Ghibli
    
    init(item: Ghibli) {
        self.item = item
        self.tilte = item.title
    }
}
