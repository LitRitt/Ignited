//
//  UpdatesView.swift
//  Delta
//
//  Created by Chris Rittenhouse on 3/3/23.
//  Copyright © 2023 LitRitt. All rights reserved.
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
                guard let url = try URL(string: "https://f005.backblazeb2.com/file/lit-apps/data/ignited/Updates.plist") else { return }
                
                let request = URLRequest(url: url)

                URLSession.shared.dataTask(with: request) { data, response, error in
                    do
                    {
                        if let data = data
                        {
                            let updates = try PropertyListDecoder().decode([Update].self, from: data)
                            DispatchQueue.main.async {
                                self.updates = updates
                            }
                        }
                    }
                    catch
                    {
                        self.error = error
                    }
                }
                .resume()
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
                    VersionCell(version: update.version, date: update.date, url: update.url) { webViewURL in
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
    var date: String
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
                Text("Version " + self.version + " - " + self.date)
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
                switch self.type
                {
                case "feature":
                    Rectangle()
                        .foregroundColor(.green)
                        .frame(minWidth: nil, idealWidth: 15, maxWidth: 15, minHeight: 20, idealHeight: 25, maxHeight: .infinity, alignment: .leading)
                        .cornerRadius(5)
                case "update":
                    Rectangle()
                        .foregroundColor(.yellow)
                        .frame(minWidth: nil, idealWidth: 15, maxWidth: 15, minHeight: 20, idealHeight: 25, maxHeight: .infinity, alignment: .leading)
                        .cornerRadius(5)
                case "bugfix":
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(minWidth: nil, idealWidth: 15, maxWidth: 15, minHeight: 20, idealHeight: 25, maxHeight: .infinity, alignment: .leading)
                        .cornerRadius(5)
                default:
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(minWidth: nil, idealWidth: 15, maxWidth: 15, minHeight: 20, idealHeight: 25, maxHeight: .infinity, alignment: .leading)
                        .cornerRadius(5)
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
