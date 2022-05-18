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

struct HelperSettingsView: View {
    
    @State var connectionTestResult: String = "Unknown"
    @State var helperToolVersionString: String = "Unknown"
    @State var helperToolInstalledState: String = "Unknown"
    @State var helperToolTopQuote: String = ""
    
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
        VStack {
            Text("Helper Tool")
                .font(.title2)
                .bold()
            
            Text(self.helperToolTopQuote)
            
            HStack {
                Text("Installed: \(self.helperMonitor.helperToolExists ? "Yes" : "No")")
                Text("Version: \(self.helperMonitor.helperToolBundleVersion?.rawValue ?? "N/A")")
            }
            
            HStack(spacing: 8) {
                Button {
                    self.installHelper()
                } label: {
                    Text("Install")
                }

                Button {
                    self.updateHelper()
                } label: {
                    Text("Update")
                }

                Button {
                    self.uninstallHelper()
                } label: {
                    Text("Uninstall")
                }
            }
            
            Divider()
            
            Text("Debug Only")
                .font(.title2)
                .bold()
            
            HStack {
                Button {
                    DiagnosticSigningInfo.printDiagnosticInfo()
                } label: {
                    Text("Print Diagnostic Info")
                }
                
                Button {
                    self.testRun()
                } label: {
                    Text("Test Connection")
                }
                
                Text("Connection: \(self.connectionTestResult == "" ? (self.helperMonitor.connectionValid ? "Connected" : "Failure") : self.connectionTestResult)")
            }
        }.onAppear {
            self.determineHelperStatus()
        }
    }
    
    /// Install the helper tool
    private func installHelper() {
        do {
            try LaunchdManager.authorizeAndBless(message: "Do you want to install the sample helper tool?")
        } catch AuthorizationError.canceled {
        } catch {
            self.helperToolTopQuote = "Helper Tool Install Failed"
            return
        }
        self.helperToolTopQuote = "Helper Tool Install Succeeded"
    }
    
    /// Call the helper to uninstall itself
    private func uninstallHelper() {
        self.xpcService.send(to: SharedConstants.uninstallRoute) { response in
            if case .failure(let error) = response {
                switch error {
                case .connectionInterrupted:
                    return
                default:
                    print("Uninstall error: \(error.localizedDescription)")
                    self.helperToolTopQuote = "Helper Tool Uninstall Failed"
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
                self.connectionTestResult = "Connected"
            case .failure(let error):
                self.connectionTestResult = "Failure"
                print("Failed to connect: \(error.localizedDescription)")
            }
        }
    }
    
    /// Run to determine or update the status of the helper tool
    private func determineHelperStatus() {
        //TODO: Make this function :) I refuse
        
        
    }
}
