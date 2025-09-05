//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/9/21.
//

import UIKit
import LLM
import WWPrint
import WWHUD

// MARK: - ViewController
final class ViewController: UIViewController {

    private var bot: LLM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBot()
    }
    
    @IBAction func prompt(_ sender: UIBarButtonItem) {
        
        WWHUD.shared.display()
        
        Task {
            
            WWHUD.shared.closeLabelSetting(title: "關閉")
            
            let prompt = "你會說日文嗎?可以當我的日文老師嗎？說一句日文聽聽"
            await demo(prompt: prompt)
            
            WWHUD.shared.dismiss()
        }
    }
}

// MARK: - WWHUD.Delegate
extension ViewController: WWHUD.Delegate {

    func forceClose(hud: WWHUD) {
        bot?.stop()
    }
}

// MARK: - 小工具
private extension ViewController {

    func initBot() {
        
        guard let bot = llmMaker() else { wwPrint("error"); return }
        self.bot = bot
        
        WWHUD.shared.delegate = self
    }
    
    func demo(prompt: String) async {
        
        guard let bot else { wwPrint("error"); return }
        
        let question = bot.preprocess(prompt, [])
        let answer = await bot.getCompletion(from: question)
        
        bot.stop()
        wwPrint(answer)
    }
    
    func llmMaker() -> LLM? {
        
        guard let gguflUrl = Bundle.main.url(forResource: "qwen1_5-0_5b-chat-q2_k", withExtension: "gguf") else { return nil }
        return LLM(from: gguflUrl, template: .chatML())
    }
}
