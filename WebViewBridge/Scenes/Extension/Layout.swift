//
//  Layout.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import UIKit

extension BridgeInspectorViewController {

    func setupGestures() {
        dividerView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPanDivider(_:)))
        dividerView.addGestureRecognizer(pan)
    }

    @objc private func onPanDivider(_ g: UIPanGestureRecognizer) {
        let translation = g.translation(in: view)
        g.setTranslation(.zero, in: view)

        // 위로 드래그하면 패널 높이 증가
        let newHeight = panelHeightConstraint.constant - translation.y

        // clamp
        let minH: CGFloat = 160
        let maxH: CGFloat = view.bounds.height * 0.75
        panelHeightConstraint.constant = max(minH, min(maxH, newHeight))

        if g.state == .changed {
            UIView.performWithoutAnimation { self.view.layoutIfNeeded() }
        }
    }
}
