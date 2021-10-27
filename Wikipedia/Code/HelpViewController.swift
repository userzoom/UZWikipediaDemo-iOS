import MessageUI

@objc(WMFHelpViewController)
class HelpViewController: SinglePageWebViewController {
    static let faqURLString = "https://m.mediawiki.org/wiki/Wikimedia_Apps/iOS_FAQ"
    static let emailAddress = "mobile-ios-wikipedia@wikimedia.org"
    static let emailSubject = "Bug:"
    
    @objc init?(dataStore: MWKDataStore, theme: Theme) {
        guard let faqURL = URL(string: HelpViewController.faqURLString) else {
            return nil
        }
        super.init(url: faqURL, theme: theme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(url: URL, theme: Theme) {
        fatalError("init(url:theme:) has not been implemented")
    }

    required init(url: URL, theme: Theme, doesUseSimpleNavigationBar: Bool = false) {
        fatalError("init(url:theme:doesUseSimpleNavigationBar:) has not been implemented")
    }

    lazy var sendEmailToolbarItem: UIBarButtonItem = {
        return UIBarButtonItem(title: WMFLocalizedString("button-report-a-bug", value: "Report a bug", comment: "Button text for reporting a bug"), style: .plain, target: self, action: #selector(sendEmail))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = nil
        setupToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupToolbar() {
        enableToolbar()
        toolbar.items = [UIBarButtonItem.flexibleSpaceToolbar(), sendEmailToolbarItem, UIBarButtonItem.wmf_barButtonItem(ofFixedWidth: 8)]
        setToolbarHidden(false, animated: false)
    }
    
    @objc func sendEmail() {
        let address = HelpViewController.emailAddress
        let subject = HelpViewController.emailSubject
        let body = "\n\n\n\nVersion: \(WikipediaAppUtils.versionedUserAgent())"
        let mailto = "mailto:\(address)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let encodedMailto = mailto, let mailtoURL = URL(string: encodedMailto), UIApplication.shared.canOpenURL(mailtoURL) else {
            WMFAlertManager.sharedInstance.showErrorAlertWithMessage(WMFLocalizedString("no-email-account-alert", value: "Please setup an email account on your device and try again.", comment: "Displayed to the user when they try to send a feedback email, but they have never set up an account on their device"), sticky: false, dismissPreviousAlerts: false)
            return
        }

        UIApplication.shared.open(mailtoURL)
    }

}
