//
//  UploadView.swift
//  Instagram
//
//  Created by 徐炜楠 on 11/12/2017.
//  Copyright © 2017 xuweinan. All rights reserved.
//

import UIKit

class UploadView: UIView,UITextViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    class func newInstance(frame:CGRect) -> UploadView?{
        let nibView = Bundle.main.loadNibNamed("UploadView", owner: nil, options: nil)
        if let view = nibView?.first as? UploadView{
            //view.frame = frame
            view.titleTxt.delegate = view
            return view
        }
        return nil
    }
    func textViewDidChange(_ textView: UITextView) { publishBtn.isEnabled = true }
    override func layoutSubviews() {
        super.layoutSubviews()
        let side = max(80, min(bounds.width - 32, bounds.height - 150))
        picImg.frame = CGRect(x: (bounds.width - side) / 2, y: 16, width: side, height: side)
        picImg.contentMode = .scaleAspectFit
        titleTxt.frame = CGRect(x: 16, y: side + 28, width: bounds.width - 88, height: max(60, bounds.height - side - 44))
        publishBtn.frame = CGRect(x: bounds.width - 64, y: bounds.height - 64, width: 48, height: 48)
        saveBtn.frame = publishBtn.frame
        removeBtn.frame = CGRect(x: 20, y: 20, width: 36, height: 36)
    }
    func offlineMode(){
        self.publishBtn.isHidden = true
        self.saveBtn.isHidden = false
        self.titleTxt.isHidden = true
    }
}
