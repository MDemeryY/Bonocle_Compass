//
//  BaseViewController.swift
//  BonocleLearn
//
//  Created by Mahmoud ELDemery on 12/06/2021.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }    

    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func doInBackground(_ block: @escaping () -> ()) {
        DispatchQueue.global(qos: .default).async {
        block()
      }
    }

    func doOnMain(_ block: @escaping () -> ()) {
      DispatchQueue.main.async {
        block()
      }
    }
    func doOnMain(deadline: Double,_ block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline) {
            block()
        }
    }
    
    func showConfirmAlert(withTitle:String, message:String, completion: (()->())? = nil  )  {
        let alertController = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)
        alertController.view.tintColor = .mainColor
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) in
        }))
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            completion?()
        }))
        doOnMain {
            self.present(alertController, animated: true, completion: nil)
        }
    }


}
