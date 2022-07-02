//
//  LogWindowView.swift
//  Maple
//
//  Created by Hallie on 6/26/22.
//

import SwiftUI

struct LogWindowView: View {
    
    @State var selectiveShow: Int = 0
    @State var selectedLog: Log? = nil
    @State var searchValue: String = ""
    
    @ObservedObject var logController: MapleLogController = .shared
    
    @State var showLogExporter: Bool = false
    
    var title: String {
        get {
            if self.selectiveShow == 0 {
                return "All Logs"
            } else if self.selectiveShow == 1 {
                return "Maple App Logs"
            } else {
                return "Development Logs"
            }
        }
    }
    
    private func exportLogs() {
        
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(self.title)
                        .bold()
                        .font(.title)
                    
                    Button {
                        self.showLogExporter = true
                    } label: {
                        HStack(alignment: .center) {
                            Text("Export \(self.title)")
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                        }.foregroundColor(.accentColor)
                    }.buttonStyle(PlainButtonStyle())
                    .fileExporter(isPresented: self.$showLogExporter, document: LogFile(initialText: MapleLogController.shared.exportLogFile()), contentType: .log) { result in
                        switch result {
                        case .success(let exportedURL):
                            MapleLogController.shared.local(log: "Successfully exported Maple's logs to \(exportedURL.path)")
                        case .failure(let error):
                            MapleLogController.shared.local(log: "ERROR Failed to export Maple's logs \(error.localizedDescription)")
                        }
                    }
                }
                
                Spacer()

                MapleTextField(title: "Search", value: self.$searchValue)
                    .frame(width: 200)
            }.padding([.horizontal, .top])
            
            MapleSegmentPicker(withOptions: ["All Logs", "Maple App Logs", "Development Logs"], andValue: self.$selectiveShow)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    ForEach(self.logController.logs.filter({ log in
                        if self.searchValue == "" {
                            if self.selectiveShow == 0 {
                                return true
                            } else if self.selectiveShow == 1 {
                                return log.bundle == "dev.halz.Maple"
                            } else {
                                return log.bundle != "dev.halz.Maple"
                            }
                        } else {
                            if self.selectiveShow == 0 {
                                return log.log.lowercased().contains(self.searchValue) || log.bundle.lowercased().contains(self.searchValue)
                            } else if self.selectiveShow == 1 {
                                return log.log.lowercased().contains(self.searchValue) || log.bundle.lowercased().contains(self.searchValue) && log.bundle == "dev.halz.Maple"
                            } else {
                                return log.log.lowercased().contains(self.searchValue) || log.bundle.lowercased().contains(self.searchValue) && log.bundle != "dev.halz.Maple"
                            }
                        }
                    }), id: \.self) { log in
                        if log != self.logController.logs[0] {
                            Divider()
                        }
                        
                        Button {
                            if self.selectedLog == log {
                                self.selectedLog = nil
                            } else {
                                self.selectedLog = log
                            }
                        } label: {
                            LogView(highLightedLog: self.$selectedLog, log: log)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.horizontal)
            }.padding(.vertical)
        }
    }
}
