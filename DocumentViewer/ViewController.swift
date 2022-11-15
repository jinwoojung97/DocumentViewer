//
//  ViewController.swift
//  DocumentViewer
//
//  Created by inforex on 2022/11/15.
//
 
import PDFKit
import UIKit

class ViewController: UIViewController {
    
    let pdfView = PDFView()
    
    private var pageInfoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor.gray
        return view
    }()

    private var currentPageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white
        return label
    }()

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        initDocument()
        pdfViewSetting()
    }

    deinit {
            timer?.invalidate()
        }

    private func setUpUI() {
        view.addSubview(pdfView)
        view.addSubview(pageInfoContainer)

        pdfView.frame = view.bounds
        pageInfoContainer.addSubview(currentPageLabel)

        NSLayoutConstraint.activate([
            pageInfoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageInfoContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            currentPageLabel.topAnchor.constraint(equalTo: pageInfoContainer.topAnchor, constant: 5),
            currentPageLabel.leadingAnchor.constraint(equalTo: pageInfoContainer.leadingAnchor, constant: 10),
            currentPageLabel.trailingAnchor.constraint(equalTo: pageInfoContainer.trailingAnchor, constant: -10),
            currentPageLabel.bottomAnchor.constraint(equalTo: pageInfoContainer.bottomAnchor, constant: -5),
        ])
    }

    private func initDocument(){
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange), name: .PDFViewPageChanged, object: nil)

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
    }
}

// MARK: - PDFView PDFViewPageChanged
extension ViewController {
    @objc
    private func handlePageChange() {
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

    @objc
    private func whenTimerEnds() {
        UIView.animate(withDuration: 1) {
            self.pageInfoContainer.alpha = 0
        }
    }
}
