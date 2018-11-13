//
//  FRAlertView.swift
//  Frinck
//
//  Created by sirez-ios on 04/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRAlertView: UIView
{
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var getPointLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("FRAlertView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func crossButtonAction(_ sender: Any)
    {
    }
}
