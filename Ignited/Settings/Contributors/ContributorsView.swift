//
//  ContributionsView.swift
//  Ignited
//
//  Created by Riley Testut on 2/2/23.
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

extension ContributorsView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var contributors: [Contributor]?
        
        @Published
        var error: Error?
        
        @Published
        var webViewURL: URL?
        
        weak var hostingController: UIViewController?
        
        func loadContributors()
        {
            guard self.contributors == nil else { return }
            
            do
            {
                guard let url = try URL(string: "https://raw.githubusercontent.com/LitRitt/Ignited/main/Resources/contributors.plist") else { return }
                
                let request = URLRequest(url: url)

                URLSession.shared.dataTask(with: request) { data, response, error in
                    do
                    {
                        if let data = data
                        {
                            let contributors = try PropertyListDecoder().decode([Contributor].self, from: data)
                            DispatchQueue.main.async {
                                self.contributors = contributors
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
        let contributorsView = ContributorsView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: contributorsView)
        hostingController.title = NSLocalizedString("Contributors", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct ContributorsView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section(content: {}, footer: {
                Text("These individuals have contributed to the open-source Ignited project on GitHub.\n\nThank you to all our contributors, your help is much appreciated 🧡")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.contributors ?? []) { contributor in
                Section {
                    // First row = contributor
                    ContributionCell(name: Text(contributor.name).bold(), url: contributor.url, linkName: contributor.linkName) { webViewURL in
                        viewModel.webViewURL = webViewURL
                    }
                    
                    // Remaining rows = contributions
                    ForEach(contributor.contributions) { contribution in
                        ContributionCell(name: Text(contribution.name), url: contribution.url) { webViewURL in
                            viewModel.webViewURL = webViewURL
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(viewModel)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Unable to Load Contributors"), message: Text(viewModel.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")) {
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
            viewModel.loadContributors()
        }
    }
    
    fileprivate init(contributors: [Contributor]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let contributors
        {
            // Don't overwrite passed-in viewModel.contributors if contributors is nil.
            viewModel.contributors = contributors
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct ContributionCell: View
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

private extension ContributorsView
{
    func openURL(_ url: URL)
    {
        guard let hostingController = viewModel.hostingController else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        hostingController.present(safariViewController, animated: true)
    }
}
