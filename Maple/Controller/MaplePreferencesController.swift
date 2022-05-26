//
//  MaplePreferencesController.swift
//  Maple
//
//  Created by Hallie on 5/26/22.
//

import Foundation

class MaplePreferencesController: ObservableObject {
    
    static let shared: MaplePreferencesController = MaplePreferencesController()
    
    private let ud: UserDefaults = .standard
    
    static let developmentEnabledKey: String = "mapleDevelopmentEnabled"
    
    @Published var developmentEnabled: Bool = false {
        didSet {
            self.ud.set(self.developmentEnabled, forKey: MaplePreferencesController.developmentEnabledKey)
            if self.developmentEnabled {
                MapleDevelopmentHelper.shared.configure()
            } else {
                MapleDevelopmentHelper.shared.disconfigure()
            }
        }
    }
    
    init() {
        self.developmentEnabled = self.ud.bool(forKey: MaplePreferencesController.developmentEnabledKey)
    }
}
