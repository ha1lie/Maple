//
//  PreferencesGroupView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct PreferencesGroupView: View {
    @StateObject var group: PreferenceGroup
    @State var shouldShow: Bool = false
    
    @State var listener: ShowListener?
    
    class ShowListener {
        
        private let groupView: PreferencesGroupView
        private let key: String
        
        @objc func updateModal(_ notification: Notification) {
            if let showable = notification.userInfo?["newValue"] as? Bool {
                self.groupView.updateShow(showable)
            }
        }
        
        init(forKey key: String, _ groupView: PreferencesGroupView) {
            self.key = key
            self.groupView = groupView
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(updateModal(_:)), name: Notification.Name(self.key), object: nil, suspensionBehavior: .deliverImmediately)
        }
    }
    
    fileprivate func updateShow(_ toShow: Bool) {
        self.shouldShow = toShow
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if self.shouldShow {
                Text(self.group.name)
                    .font(.title)
                    .bold()
                if let _ = self.group.description {
                    Text(self.group.description!)
                        .font(.headline)
                }
                
                if let _ = self.group.preferences {
                    ForEach(0..<self.group.preferences!.count, id: \.self) { i in
                        PreferenceView(preference: self.group.preferences![i])
                    }
                }
            } else {
                EmptyView()
            }
        }.onAppear {
            if let showKey = self.group.optionallyShownKey {
                self.listener = ShowListener(forKey: showKey, self)
                if let preference = Preferences.valueForKey(showKey, inContainer: self.group.containerName) {
                    switch preference {
                    case .bool(let optional):
                        if let optional = optional {
                            self.shouldShow = optional
                        }
                    default:
                        self.shouldShow = false
                    }
                } else {
                    self.shouldShow = false
                }
            } else {
                self.shouldShow = true
            }
        }
    }
}
