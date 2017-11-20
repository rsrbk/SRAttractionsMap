/*
 MIT License
 Copyright (c) 2017 Ruslan Serebriakov <rsrbk1@gmail.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 @IBOutlet weak var closeButton: UIButton!
 @IBOutlet weak var detailButtonHeight: NSLayoutConstraint!
 @IBOutlet weak var detailButtonHeight: NSLayoutConstraint!
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

class SRCalloutView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailButtonSeparator: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var detailButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!

    var onCloseTap: (() -> Void)?
    var onDetailTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func hideDetailButton() {
        detailButtonHeight.constant = 0
        detailButtonSeparator.backgroundColor = UIColor.clear
        layoutIfNeeded()
    }

    private func commonInit() {
        let frameworkBundle = Bundle.init(for: type(of: self))
        if let view = frameworkBundle.loadNibNamed("SRCalloutView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.frame = bounds

            view.layer.shadowOffset = CGSize(width: 0, height: 7)
            view.layer.shadowRadius = 5
            view.layer.shadowOpacity = 0.5

            closeButton.layer.cornerRadius = closeButton.frame.width / 2
        }
    }

    @IBAction func detailAction(_ sender: UIButton) {
        onDetailTap?()
    }

    @IBAction func closeAction(_ sender: UIButton) {
        onCloseTap?()
    }
}
