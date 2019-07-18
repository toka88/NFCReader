//
//  ViewController.swift
//  NFCReader
//
//  Created by toka88 on 07/18/2019.
//  Copyright (c) 2019 toka88. All rights reserved.
//

import NFCReader
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action

    @IBAction private func scanNFCTapped(_ sender: Any) {
        guard NFCReader.shared.readingAvailable else {
            showAlert(withMessage: "NFC reader is unavailable.")
            return
        }

        guard !NFCReader.shared.isReading else {
            showAlert(withMessage: "NFC reader is already running.")
            return
        }

        self.label.text = ""

        NFCReader.shared.scanTag { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .failure(let error):
                self.showAlert(withMessage: error.localizedDescription)
            case .success(let nfcString):
                self.label.text = nfcString
            }
        }
    }

    // MARK: - Alert

    private func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in

        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

