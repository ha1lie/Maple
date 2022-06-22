//
//  HelperSettingsView.swift
//  Maple
//
//  Created by Hallie on 5/1/22.
//

import SwiftUI
import Blessed
import SecureXPC
import EmbeddedPropertyList

/// Settings section to display information on the helper
struct HelperSettings: View {
    
    @State var helperToolTopQuote: String = ""
    @State var quoteShown: Bool = false
    @State var connectionTestResult: String = ""
    
    let xpcService: XPCClient
    let sharedConstants: SharedConstants
    let bundledLocation: URL
    @ObservedObject var helperMonitor: HelperToolMonitor
    
    init() {
        guard let tsc = (NSApplication.shared.delegate as? AppDelegate)?.sharedConstants else {
            fatalError("Could not find AppDelegate's SharedConstants")
        }
        
        guard let bl = tsc.bundledLocation else {
            fatalError("Helper Tool Location Shouldn't Not Exist")
        }
        
        self.sharedConstants = tsc
        self.bundledLocation = bl
        self.xpcService = XPCClient.forMachService(named: sharedConstants.machServiceName)
        
        guard let hm = (NSApplication.shared.delegate as? AppDelegate)?.helperMonitor else {
            fatalError("Helper Monitor should be accessible")
        }
        self.helperMonitor = hm
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                Text("Maple's Helper")
                    .font(.title2)
                    .bold()
                
                if self.quoteShown {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(Color(nsColor: .darkGray))
                        Text(self.helperToolTopQuote)
                            .foregroundColor(self.helperToolTopQuote.contains("Fail") ? .red : .white)
                            .fontWeight(.medium)
                            .padding(6)
                    }
                    .transition(.move(edge: .top))
                    .animation(.easeInOut(duration: 0.5), value: self.quoteShown)
                }
                
                if self.helperMonitor.helperToolExists {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Maple's helper \(self.helperMonitor.helperToolBundleVersion?.rawValue ?? ", with an unknown version,") is installed")
                            .fontWeight(.medium)
                    }.foregroundColor(.green)
                    .padding(.vertical, 6)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Maple's helper is not installed. Click install")
                            .fontWeight(.medium)
                    }.foregroundColor(.red)
                    .padding(.vertical, 6)
                }
                
                //TODO: Show here if it needs an update
                
                HStack(spacing: 8) {
                    MapleButton(action: {
                        self.installHelper()
                    }, title: "Install", andSize: .small)

                    MapleButton(action: {
                        self.updateHelper()
                    }, title: "Update", andSize: .small)

                    MapleButton(action: {
                        self.uninstallHelper()
                    }, title: "Uninstall", withColor: .red, andSize: .small)
                }
                
                Divider()
                
                #if DEBUG
                Text("Debug Only")
                    .font(.title2)
                    .bold()
                
                HStack {
                    MapleButton(action: {
                        DiagnosticSigningInfo.printDiagnosticInfo()
                    }, title: "Print Diagnostics", andSize: .small)
                    
                    MapleButton(action: {
                        self.testRun()
                    }, title: "Test Connection", andSize: .small)
                }
                #endif
            }.padding()
        }.onChange(of: self.helperToolTopQuote, perform: { newValue in
            withAnimation {
                self.quoteShown = newValue != ""
            }
            if newValue != "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.helperToolTopQuote = ""
                }
            }
        }).onAppear {
            self.helperMonitor.determineStatus()
        }
    }
    
    /// Install the helper tool
    private func installHelper() {
        do {
            try LaunchdManager.authorizeAndBless(message: "Do you want to install the sample helper tool?")
        } catch AuthorizationError.canceled {
            self.helperToolTopQuote = "Cancelled install of Maple's helper tool"
        } catch {
            self.helperToolTopQuote = "Failed to install Maple's helper tool"
            return
        }
        self.helperToolTopQuote = "Succeeded to install Maple's helper tool"
    }
    
    /// Call the helper to uninstall itself
    private func uninstallHelper() {
        self.xpcService.send(to: SharedConstants.uninstallRoute) { response in
            if case .failure(let error) = response {
                switch error {
                case .connectionInterrupted:
                    self.helperToolTopQuote = "Succeeded to uninstall Maple's helper tool"
                    return
                default:
                    print("Uninstall error: \(error.localizedDescription)")
                    self.helperToolTopQuote = "Failed to uninstall Maple's helper tool"
                }
            }
        }
    }
    
    /// Call the helper to update itself
    private func updateHelper() {
        self.xpcService.sendMessage(self.bundledLocation, to: SharedConstants.updateRoute) { response in
            if case .failure(let error) = response {
                switch error {
                case .connectionInterrupted:
                    return
                default:
                    print("Update error: \(error.localizedDescription)")
                    self.helperToolTopQuote = "Helper Tool Update Failed"
                }
            }
        }
    }
    
    /// Check the connection for the user
    private func testRun() {
        self.xpcService.send(to: SharedConstants.mapleInjectionTestConnection) { result in
            switch result {
            case .success(let reply):
                print("Reply: \(reply)")
                self.helperToolTopQuote = "Maple's helper is connected"
            case .failure(let error):
                self.helperToolTopQuote = "Maple's helper could not establish a connection"
                print("Failed to connect: \(error.localizedDescription)")
            }
        }
    }
}
