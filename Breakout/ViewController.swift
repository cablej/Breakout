//
//  ViewController.swift
//  Breakout
//
//  Created by Jack Cable on 7/9/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    @IBOutlet var livesLabel: UILabel!
    
    let BALL_RADIUS : CGFloat = 10.0
    let PADDLE_WIDTH : CGFloat = 80.0
    let PADDLE_HEIGHT : CGFloat = 20.0
    
    let BRICK_COLUMNS = 20
    let BRICK_ROWS = 20
    let BRICK_MARGIN = 3.0
    
    var dynamicAnimator = UIDynamicAnimator()
    var collisionBehavior = UICollisionBehavior()
    var paddle = UIView()
    var ball = UIView()
    var bricks : [UIView] = []
    var lives = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeGame()

        
    }
    
    func initializeGame() {
        
        dynamicAnimator = UIDynamicAnimator()
        collisionBehavior = UICollisionBehavior()
        paddle = UIView()
        ball = UIView()
        bricks = []
        lives = 5
        
        ball = UIView(frame: CGRectMake(view.center.x - BALL_RADIUS, view.center.y - BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2))
        ball.backgroundColor = UIColor.blackColor()
        ball.layer.cornerRadius = BALL_RADIUS
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        paddle = UIView(frame: CGRectMake(view.center.x - (PADDLE_WIDTH / 2), view.center.y * 1.7, PADDLE_WIDTH, PADDLE_HEIGHT))
        paddle.backgroundColor = UIColor.redColor()
        view.addSubview(paddle)
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        let width = (view.frame.width - (CGFloat(BRICK_MARGIN) * (CGFloat(BRICK_COLUMNS) - 1.0))) / CGFloat(BRICK_COLUMNS)
        let height = ((view.frame.height * 0.3) - (CGFloat(BRICK_MARGIN) * (CGFloat(BRICK_ROWS) - 1.0))) / CGFloat(BRICK_ROWS)
        
        for(var brickNum = 0; brickNum < BRICK_COLUMNS * BRICK_ROWS; brickNum++) {
            
            let column = brickNum % BRICK_COLUMNS
            let row = brickNum / BRICK_ROWS
            
            let x = width * CGFloat(column) + CGFloat(BRICK_MARGIN) * CGFloat(column)
            let y = height * CGFloat(row) + CGFloat(BRICK_MARGIN) * CGFloat(row)
            
            let brick = UIView(frame: CGRectMake(x, y, width, height))
            
            if(row <= 1) {
                brick.backgroundColor = UIColor.greenColor()
            } else if(row <= 3) {
                brick.backgroundColor = UIColor.yellowColor()
            } else {
                brick.backgroundColor = UIColor.redColor()
            }
            
            view.addSubview(brick)
            
            bricks.append(brick)
            
            let brickDynamicBehavior = UIDynamicItemBehavior(items: [brick])
            brickDynamicBehavior.density = 10000
            brickDynamicBehavior.resistance = 100
            brickDynamicBehavior.allowsRotation = false
            dynamicAnimator.addBehavior(brickDynamicBehavior)
            
        }
        
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.2
        dynamicAnimator.addBehavior(pushBehavior)
        
        collisionBehavior = UICollisionBehavior(items: [ball, paddle] + bricks)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        livesLabel.text = "Lives: \(lives)"
    }

    @IBAction func dragPaddle(sender: UIPanGestureRecognizer) {
        let panGesture = sender.locationInView(view)
        
        if(panGesture.x >= (PADDLE_WIDTH / 2) && panGesture.x <= view.frame.width - (PADDLE_WIDTH / 2)) {
            paddle.center = CGPointMake(panGesture.x, paddle.center.y)
            dynamicAnimator.updateItemUsingCurrentState(paddle)
        }
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives--
            if lives > 0 {
                livesLabel.text = "Lives: \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
            } else {
                livesLabel.text = "Game over"
                ball.removeFromSuperview()
                alert("Game over")
                collisionBehavior.removeItem(ball)
                ball.removeFromSuperview()
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        var brickLeft = false
        for brick in bricks {
            if (item1.isEqual(ball) && item2.isEqual(brick)) ||
                (item2.isEqual(ball) && item1.isEqual(brick)) {
                    if brick.backgroundColor == UIColor.greenColor() {
                        brick.backgroundColor = UIColor.yellowColor()
                    } else if brick.backgroundColor == UIColor.yellowColor() {
                        brick.backgroundColor = UIColor.redColor()
                    } else {
                        brick.hidden = true
                        collisionBehavior.removeItem(brick)
                    }
            }
            
            if !brick.hidden {
                brickLeft = true
            }
        }
        
        if !brickLeft {
            livesLabel.text = "You win!"
            alert("You win!")
            collisionBehavior.removeItem(ball)
            ball.removeFromSuperview()
            dynamicAnimator.updateItemUsingCurrentState(ball)
        }
        
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Play again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.resetGame()
        }))
        alert.addAction(UIAlertAction(title: "Quit", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func resetGame() {
        paddle.removeFromSuperview()
        for brick in bricks {
            brick.removeFromSuperview()
        }
        initializeGame()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}




















