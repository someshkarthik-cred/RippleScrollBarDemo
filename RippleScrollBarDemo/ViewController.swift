//
//  ViewController.swift
//  RippleScrollBarDemo
//
//  Created by Somesh Karthik on 23/09/22.
//

import UIKit

final class ViewController: UIViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 15)
        return collectionView
    }()
    private let scrollBar = RippleScrollBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(red: 241/255, green: 237/255, blue: 228/255, alpha: 1.0)

        collectionView.delegate = self
        collectionView.backgroundColor = view.backgroundColor
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        view.addSubview(scrollBar)
        scrollBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollBar.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            scrollBar.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            scrollBar.widthAnchor.constraint(equalToConstant: 200),
            scrollBar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollViewDidScroll(collectionView)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentInset = scrollView.contentInset
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let currentContentOffset = contentOffset.x + contentInset.left

        let totalContentOffset = contentSize.width + contentInset.left + contentInset.right - view.frame.width
        
        scrollBar.setPercentage(max(min(currentContentOffset/totalContentOffset, 1.0), 0))
    }
}
