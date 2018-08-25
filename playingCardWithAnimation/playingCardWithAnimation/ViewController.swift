//
//  ViewController.swift
//  playingCardWithAnimation
//
//  Created by 임지후 on 2018. 8. 24..
//  Copyright © 2018년 임지후. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
    
    //IBOutlet Collection
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            
            //animation
            cardBehavior.addItem(cardView)
           
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1 }
    }
    
    private var faceUpCardViewMatch: Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView,  faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                
                UIView.transition(with: chosenCardView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                                  },
                                  completion: { finished in
                                    let cardsToAnimate = self.faceUpCardViews
                                    if self.faceUpCardViewMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                            },
                                            completion: { position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.75,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x:0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                    },
                                                    completion: { position in
                                                            cardsToAnimate.forEach {
                                                               $0.isHidden = true
                                                               $0.alpha = 1
                                                               $0.transform = .identity
                                                            }
                                                    }
                                                )
                                            }
                                        )
                                    } else if cardsToAnimate.count == 2 {
                                        if chosenCardView == self.lastChosenCardView {
                                            cardsToAnimate.forEach { cardView in
                                                UIView.transition(with: cardView,
                                                                  duration: 0.5,
                                                                  options: [.transitionFlipFromLeft],
                                                                  animations: {
                                                                    cardView.isFaceUp = false
                                                                    },
                                                                  completion: { finished in
                                                                    self.cardBehavior.addItem(cardView)
                                                                    }
                                                )
                                            }
                                        }
                                        
                                    } else {
                                        if !chosenCardView.isFaceUp {
                                            self.cardBehavior.addItem(chosenCardView)
                                        }
                                    }
                    }
                )
            }
            
        default: break
        }
    }
}

//how dynamic ~
public extension CGFloat {
    var arc4random: CGFloat {
        let max:Float = 100000
        let value:Float = Float(self+5) * max
        var result: CGFloat = 0
        if self > 0 {
            result = CGFloat(Float(arc4random_uniform(UInt32(value)))/max)
            print("origin value == \(self)  random value == \(result)")
            return result
            
        } else if self <  0 {
            result = -CGFloat(Float(arc4random_uniform(UInt32(abs(value))))/max)
            print("origin value == \(self)  random value == \(result)")
            return result
        } else {
            result = CGFloat(Float(arc4random_uniform(UInt32(max)))/max)
            print("origin value == \(self)  random value == \(result)")
            return result
           // return 0
        }
    }
}
