//
//  ViewController.swift
//  DocumentViewer
//
//  Created by inforex on 2022/11/15.
//
 
import PDFKit
import UIKit
import QuickLook

import SnapKit
import Then
import RxSwift
import RxGesture

class ViewController: UIViewController, QLPreviewControllerDataSource {
    private let disposeBag = DisposeBag()

    private var pdfKitButton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("PDFKit", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }

    private var quickLookButton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("QLPreview", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }

    var previews: [Preview] = [].filter({QLPreviewController.canPreview($0)})

    override func viewDidLoad() {
        super.viewDidLoad()
        addComponent()
        setConstraints()
        bind()
    }

    private func addComponent(){
        [pdfKitButton, quickLookButton].forEach(view.addSubview)
    }

    private func setConstraints(){
        pdfKitButton.snp.makeConstraints{
            $0.height.equalTo(30)
            $0.width.equalTo(120)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(100)
        }
        
        quickLookButton.snp.makeConstraints{
            $0.height.equalTo(30)
            $0.width.equalTo(120)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(200)
        }
    }

    private func bind(){
        pdfKitButton.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.openPDFKit()
            }.disposed(by: disposeBag)

        quickLookButton.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.openQLPreview()
            }.disposed(by: disposeBag)
    }
    /**
     외부, 내부 URL을 주입해주면 된다.
     PDFKit은 내부 파일URL과 외부 다운로드 URL 둘 다 사용가능 함.
     BUT ppt, xlsx, docx 호환은 더 연구해보아야 함.
     */
    private func openPDFKit(){
        /// local file
        guard let url = Bundle.main.url(forResource: "pdfSample", withExtension: ".pdf") else { return }
        ///  download file
//        guard let url = URL(string: "https://www.africau.edu/images/default/sample.pdf") else { return }

        let pdfVC = PDFViewController(fileURL: url)
        pdfVC.modalPresentationStyle = .fullScreen

        self.present(pdfVC, animated: true, completion: nil)
    }
    /**
     문서 변경할 때는 previews에 내부에 저장된 문서 정보를 append하면 된다.
     QLPreviewController는 외부 URL을 로드할 수 없다.(내부에 파일을 저장 해야함)
     BUT pdf, pptx, xlsx, docx 모두 호환 가능함.
     */
    private func openQLPreview(){
        let previewVC = QLPreviewController()
        previewVC.modalPresentationStyle = .fullScreen
        previewVC.dataSource = self
        previews.append(Preview(fileName: "docxSample", fileExtension: ".docx"))

        self.present(previewVC, animated: true, completion: nil)
        previews = []
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.previews.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previews[index]
    }
}
