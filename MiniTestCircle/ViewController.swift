//
//  ViewController.swift
//  MiniTestCircle
//
//  Created by Le Ngoc Trung on 7/6/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        circleView.addSubview(CircleView(frame: circleView.bounds))

    }


}

