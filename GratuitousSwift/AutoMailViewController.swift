//
//  AutoMailViewController.swift
//  Gratuity
//
//  Created by Jeffrey Bergier on 11/8/18.
//  Copyright © 2018 SaturdayApps. All rights reserved.
//

import MessageUI
import MobileCoreServices

class AutoMailViewController: MFMailComposeViewController {

    typealias Completion = (Bool) -> Void
    private var completion: Completion?

    static func newVC(with completion: Completion?) -> UIViewController {
        switch MFMailComposeViewController.canSendMail() {
        case true:
            let vc = AutoMailViewController()
            vc.completion = completion
            vc.mailComposeDelegate = vc
            vc.setSubject(AutoMailViewController.LocalizedString.EmailSubject)
            vc.setToRecipients([AutoMailViewController.Recipient])
            vc.setMessageBody(AutoMailViewController.LocalizedString.EmailBody, isHTML: false)
            return vc
        case false:
            let vc = UIAlertController(title: nil, message: LocalizedString.CopyEmail, preferredStyle: .alert)
            let copyAction = UIAlertAction(kind: .copyEmailAddress) { _ in
                UIPasteboard.general.setValue(AutoMailViewController.Recipient, forPasteboardType: kUTTypeUTF8PlainText as String)
                completion?(true)
            }
            let dismissAction = UIAlertAction(kind: .dismiss) { _ in
                completion?(false)
            }
            vc.addAction(copyAction)
            vc.addAction(dismissAction)
            return vc
        }
    }
}

extension AutoMailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?)
    {
        switch result {
        case .cancelled, .failed, .saved:
            self.completion?(false)
        case .sent:
            self.completion?(true)
        }
    }

}
