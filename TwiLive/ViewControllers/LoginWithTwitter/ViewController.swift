//
//  LoginWithTwitterViewController.swift
//  TwiLive
//
//  Created by user on 2019/09/14.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import Combine
import Alamofire
import Ikemen

protocol LoginWithTwitterViewControllerDelegate: class {
    func didFinishAuthorize(token: TwitterAuthAccessToken) -> Void
}

class LoginWithTwitterViewController: NSViewController {

    weak var delegate: LoginWithTwitterViewControllerDelegate?
    let viewModel = LoginWithTwitterViewModel()
    
    private var progressIndicatorCancellable: AnyCancellable!
    private var refreshUrlButtonCancellable: AnyCancellable!
    private var authorizeUrlFieldCancellable: AnyCancellable!
    
    var disposeBag: Set<AnyCancellable> = []
    
    override func loadView() {
        let view = LoginWithTwitterView()
        
        // MARK: ViewModel → View
        do {
            let requestTokenIsFetching = viewModel.$requestTokenState
                .map { state -> Bool in
                    if case .loading = state {
                        return true
                    }
                    return false
                }
                .removeDuplicates()
                .receive(on: RunLoop.main)
            
            // animation of progress indicator
            requestTokenIsFetching
                .sink { animation in
                    if animation {
                        view.progressIndicator.startAnimation(self)
                    } else {
                        view.progressIndicator.stopAnimation(self)
                    }
                }
                .store(in: &disposeBag)
            
            // isHidden of progress indicator
            requestTokenIsFetching
                .map { !$0 }
                .assign(to: \.isHidden, on: view.progressIndicator)
                .store(in: &disposeBag)
            
            // isEnabled of refresh button
            requestTokenIsFetching
                .map { !$0 }
                .assign(to: \.isEnabled, on: view.refreshUrlButton)
                .store(in: &disposeBag)
        }
        
        viewModel.$requestTokenState
            .map { state -> NSAttributedString in
                guard let state = state else { return .init() }
                switch state {
                case .loading:
                    return .init(string: "取得中…")
                case .error(let err):
                    switch err {
                    case .native(let error):
                        return .init(string: "エラー(ネイティブ):\n\(error.localizedDescription)\n\nInternal: \(error)")
                    case .http(let code, let message):
                        return .init(string: "エラー(HTTP \(code)):\n\(message)")
                    case .internal(let message):
                        return .init(string: "エラー(内部):\n\(message)")
                    }
                case .success(let token):
                    let url = token.authorizeURL
                    return .init(string: url.absoluteString, attributes: [
                        .link: url,
                        .foregroundColor: NSColor.labelColor,
                    ])
                }
            }
            .receive(on: RunLoop.main)
            .map { attrStr in
                let mutableAttrStr = NSMutableAttributedString(attributedString: attrStr)
                mutableAttrStr.addAttribute(.font, value: view.authorizeUrlField.font!, range: .init(location: 0, length: mutableAttrStr.length))
                return mutableAttrStr
            }
            .assign(to: \.attributedStringValue, on: view.authorizeUrlField)
            .store(in: &disposeBag)

        viewModel.$requestTokenState
            .map { if case .success(_) = $0 { return true } else { return false } }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: view.oauthCodeField)
            .store(in: &disposeBag)

        viewModel.canFetchAccessToken
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: view.fetchAccessTokenButton)
            .store(in: &disposeBag)
        
        // MARK: ViewModel → Other
        viewModel.$accessTokenState
            .compactMap { if case .fetched(let token) = $0 { return token } else { return nil } }
            .receive(on: RunLoop.main)
            .sink(receiveValue: finishAuthorize)
            .store(in: &disposeBag)

        // MARK: View → ViewModel
        view.refreshUrlButton.statePublisher(withInitialValue: true)
            .sink { [viewModel] _ in
                viewModel.getRequestToken()
            }
            .store(in: &disposeBag)

        view.oauthCodeField.stringPublisher
            .assign(to: \.code, on: viewModel)
            .store(in: &disposeBag)

        view.fetchAccessTokenButton.statePublisher()
            .sink { [viewModel] _ in
                viewModel.getAccessToken()
            }
            .store(in: &disposeBag)
        
        // MARK: View → Other
        view.quitButton.statePublisher()
            .sink { _ in
                self.quit()
            }
            .store(in: &disposeBag)

        self.view = view
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.preventsApplicationTerminationWhenModal = false
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        view.window?.preventsApplicationTerminationWhenModal = true
    }
    
    private func quit() {
        self.dismiss(self)
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func refreshUrlButtonClicked(_ sender: Any) {
//        getRequestToken()
    }
    
    func finishAuthorize(_ token: TwitterAuthAccessToken) {
        self.dismiss(self)
        self.delegate?.didFinishAuthorize(token: token)
    }
}
