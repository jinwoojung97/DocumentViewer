//
//  ViewController.swift
//  DocumentViewer
//
//  Created by inforex on 2022/11/15.
//
 
import PDFKit
import UIKit

import SnapKit
import Then
import RxSwift
import RxGesture

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private var pdfButton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("PDF", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addComponent()
        setConstraints()
        bind()
    }

    private func addComponent(){
        [pdfButton].forEach(view.addSubview)
    }

    private func setConstraints(){
        pdfButton.snp.makeConstraints{
            $0.height.equalTo(30)
            $0.width.equalTo(50)
            $0.center.equalToSuperview()
        }
    }

    private func bind(){
        pdfButton.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.openPDF()
            }.disposed(by: disposeBag)
    }

    private func openPDF(){
        /// local file
        guard let url = Bundle.main.url(forResource: "pdfsample", withExtension: ".pdf") else { return }
        ///  download file
//        guard let url = URL(string: "https://www.africau.edu/images/default/sample.pdf")

        let pdfVC = PDFViewController(fileURL: url)
        pdfVC.modalPresentationStyle = .fullScreen

        self.present(pdfVC, animated: true, completion: nil)
    }
}
