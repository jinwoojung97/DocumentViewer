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

    let pdfView = PDFView()
    
    private var naviBar = UINavigationBar().then {
        $0.isTranslucent = false
    }

    private var pageInfoContainer = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 6
        $0.backgroundColor = UIColor.gray
    }

    private var currentPageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textColor = UIColor.white
    }

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        addComponent()
        setConstraints()
        initDocument()
        pdfViewSetting()
        naviBarSetting()
    }

    deinit {
        timer?.invalidate()
    }

    private func addComponent(){
        [pdfView, pageInfoContainer, naviBar].forEach(view.addSubview)
        pageInfoContainer.addSubview(currentPageLabel)
    }

    private func setConstraints(){
        naviBar.snp.makeConstraints{
//            $0.height.equalTo(44)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }

        pdfView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(naviBar.snp.bottom)
        }

        pageInfoContainer.snp.makeConstraints {
            $0.top.leading.equalTo(pdfView).inset(20)
        }

        currentPageLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }

    private func initDocument(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePageChange),
                                               name: .PDFViewPageChanged,
                                               object: nil)

        /// local file
        guard let url = Bundle.main.url(forResource: "pdfsample", withExtension: ".pdf") else { return }
        guard let document = PDFDocument(url: url) else { return }

        /// download file
//        let url = "https://www.africau.edu/images/default/sample.pdf"
//        guard let url = URL(string: url) else { return }
//        guard let document = PDFDocument(url: url) else { return }

        pdfView.document = document
    }

    private func pdfViewSetting(){
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.accessibilityNavigationStyle = .combined
    }

    private func naviBarSetting() {
        let naviItem = UINavigationItem()
        naviItem.title = "file name"
        naviItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action))
        naviBar.items = [naviItem]
    }
}

// MARK: - PDFView PDFViewPageChanged
extension ViewController {
    @objc private func handlePageChange() {
        view.bringSubviewToFront(currentPageLabel)
        if let currentPage: PDFPage = pdfView.currentPage,
           let pageIndex: Int = pdfView.document?.index(for: currentPage) {
            UIView.animate(withDuration: 0.5, animations: {
                self.pageInfoContainer.alpha = 1
            }) { (finished) in
                if finished {
                    self.startTimer()
                }
            }
            currentPageLabel.text = "\(pageIndex + 1) of \(pdfView.document?.pageCount ?? .zero)"
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(whenTimerEnds), userInfo: nil, repeats: false)
    }

    @objc private func whenTimerEnds() {
        UIView.animate(withDuration: 1) {
            self.pageInfoContainer.alpha = 0
        }
    }
}

// MARK: - NaviBar Action
extension ViewController {
    @objc private func done(){
        print("던던")
    }

    @objc private func action(){
        print("액숀")
        guard let url = Bundle.main.url(forResource: "pdfsample", withExtension: ".pdf") else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil) // url을 공유해야 한다.
        activityVC.popoverPresentationController?.sourceView = self.view

        // 공유하기 기능 중 제외할 기능이 있을 때 사용
        // activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
}
