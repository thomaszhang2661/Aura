//
//  ProgressIndicatorManager.swift
//  Aura
//

import UIKit

private var spinnerVC: ProgressSpinnerViewController?

extension UIViewController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        let spinner = ProgressSpinnerViewController()
        spinnerVC = spinner
        
        addChild(spinner)
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        spinnerVC?.willMove(toParent: nil)
        spinnerVC?.view.removeFromSuperview()
        spinnerVC?.removeFromParent()
    }
}

