//
//  PatronsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/17/23.
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

extension PremiumPatronsView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var patrons: [PremiumPatron]?
        
        @Published
        var error: Error?
        
        @Published
        var webViewURL: URL?
        
        weak var hostingController: UIViewController?
        
        func loadPatrons()
        {
            guard self.patrons == nil else { return }
            
            do
            {
                // TODO: Make patrons load dynamically from Patreon directly
                guard let url = try URL(string: "https://raw.githubusercontent.com/LitRitt/Ignited/develop/Resources/patrons.plist") else { return }
                
                let request = URLRequest(url: url)

                URLSession.shared.dataTask(with: request) { data, response, error in
                    do
                    {
                        if let data = data
                        {
                            let patrons = try PropertyListDecoder().decode([PremiumPatron].self, from: data)
                            DispatchQueue.main.async {
                                self.patrons = patrons
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
        let contributorsView = PremiumPatronsView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: contributorsView)
        hostingController.title = NSLocalizedString("Premium", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct PremiumPatronsView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section(content: {}, footer: {
                Text("These individuals have become patrons of the highest tier. Their support helps make the continued development of this app possible. Please consider visiting their links below and supporting them in some way as well. ❤️‍🔥")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.patrons ?? []) { patron in
                Section {
                    // First row = contributor
                    PremiumPatronCell(name: Text(patron.name).bold(), url: patron.url, linkName: patron.linkName) { webViewURL in
                        viewModel.webViewURL = webViewURL
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(viewModel)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Unable to Load Patrons"), message: Text(viewModel.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")) {
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
            viewModel.loadPatrons()
        }
    }
    
    fileprivate init(patrons: [PremiumPatron]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let patrons
        {
            // Don't overwrite passed-in viewModel.contributors if contributors is nil.
            viewModel.patrons = patrons
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct PremiumPatronCell: View
{
    var name: Text
    var url: URL?
    var linkName: String?
    
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
                Text("🔥")
                
                self.name
                    .font(.system(size: 17)) // Match Settings screen
                
                Spacer()
                
                if let linkName
                {
                    Text(linkName)
                        .font(.system(size: 17)) // Match Settings screen
                        .foregroundColor(.gray)
                }
                
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

private extension PremiumPatronsView
{
    func openURL(_ url: URL)
    {
        guard let hostingController = viewModel.hostingController else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        hostingController.present(safariViewController, animated: true)
    }
}

