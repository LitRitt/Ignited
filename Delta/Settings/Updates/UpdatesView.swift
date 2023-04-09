//
//  UpdatesView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 3/3/23.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import SwiftUI
import SafariServices

private extension NavigationLink where Label == EmptyView, Destination == EmptyView
{
    // Copied from https://stackoverflow.com/a/66891173
    static var empty: NavigationLink {
        self.init(destination: EmptyView(), label: { EmptyView() })
    }
}

extension UpdatesView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var updates: [Update]?
        
        @Published
        var error: Error?
        
        @Published
        var webViewURL: URL?
        
        weak var hostingController: UIViewController?
        
        func loadUpdates()
        {
            guard self.updates == nil else { return }
            
            do
            {
                let fileURL = Bundle.main.url(forResource: "Updates", withExtension: "plist")!
                let data = try Data(contentsOf: fileURL)
                
                let updates = try PropertyListDecoder().decode([Update].self, from: data)
                self.updates = updates
            }
            catch
            {
                self.error = error
            }
        }
    }
    
    static func makeViewController() -> UIHostingController<some View>
    {
        let viewModel = ViewModel()
        let updatesView = UpdatesView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: updatesView)
        hostingController.title = NSLocalizedString("Updates", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct UpdatesView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.updates ?? []) { update in
                Section {
                    // First row = Update version
                    VersionCell(version: update.version, url: update.url) { webViewURL in
                        viewModel.webViewURL = webViewURL
                    }
                    
                    // Remaining rows = Update changes
                    ForEach(update.changes) { change in
                        ChangeCell(type: change.type, description: Text(change.description), url: change.url) { webViewURL in
                            viewModel.webViewURL = webViewURL
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(viewModel)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Unable to Load Updates"), message: Text(viewModel.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")) {
                guard let hostingController = viewModel.hostingController else { return }
                hostingController.navigationController?.popViewController(animated: true)
            })
        }
        .onReceive(viewModel.$error) { error in
            guard error != nil else { return }
            showErrorAlert = true
        }
        .onReceive(viewModel.$webViewURL) { webViewURL in
            guard let webViewURL else { return }
            openURL(webViewURL)
        }
        .onAppear {
            viewModel.loadUpdates()
        }
    }
    
    fileprivate init(updates: [Update]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let updates
        {
            // Don't overwrite passed-in viewModel.updates if updates is nil.
            viewModel.updates = updates
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct VersionCell: View
{
    var version: String
    var url: URL?
    
    var action: (URL) -> Void
    
    var body: some View {
        
        let body = Button {
            guard let url else { return }
            
            Task { @MainActor in
                // Dispatch Task to avoid "Publishing changes from within view updates is not allowed, this will cause undefined behavior." runtime error on iOS 16.
                self.action(url)
            }
            
        } label: {
            HStack {
                Text("Version " + self.version)
                    .bold()
                    .font(.system(size: 17))
                
                Spacer()
                
                if url != nil
                {
                    NavigationLink.empty
                        .fixedSize()
                }
            }
        }
        .accentColor(.primary)
        
        if url != nil
        {
            body
        }
        else
        {
            // No URL to open, so disable cell highlighting.
            body.buttonStyle(.plain)
        }
    }
}

struct ChangeCell: View
{
    var type: String
    var description: Text
    var url: URL?
    
    var action: (URL) -> Void
    
    var body: some View {
        
        let body = Button {
            guard let url else { return }
            
            Task { @MainActor in
                // Dispatch Task to avoid "Publishing changes from within view updates is not allowed, this will cause undefined behavior." runtime error on iOS 16.
                self.action(url)
            }
            
        } label: {
            HStack {
                if self.type != nil
                {
                    switch self.type
                    {
                    case "feature":
                        Text("Feature").bold()
                            .foregroundColor(.green)
                            .font(.system(size: 17))
                    case "update":
                        Text("Update").bold()
                            .foregroundColor(.yellow)
                            .font(.system(size: 17))
                    case "bugfix":
                        Text("BugFix").bold()
                            .foregroundColor(.red)
                            .font(.system(size: 17))
                    default:
                        Text("Change").bold()
                            .font(.system(size: 17))
                    }
                }
                
                self.description
                    .font(.system(size: 17))
                
                Spacer()
                
                if url != nil
                {
                    NavigationLink.empty
                        .fixedSize()
                }
            }
        }
        .accentColor(.primary)
        
        if url != nil
        {
            body
        }
        else
        {
            // No URL to open, so disable cell highlighting.
            body.buttonStyle(.plain)
        }
    }
}

private extension UpdatesView
{
    func openURL(_ url: URL)
    {
        guard let hostingController = viewModel.hostingController else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        hostingController.present(safariViewController, animated: true)
    }
}
