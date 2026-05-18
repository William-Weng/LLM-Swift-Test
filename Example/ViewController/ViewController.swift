//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/9/21.
//

import UIKit
import WWHUD
import LLM

// MARK: - ViewController
final class ViewController: UIViewController {

    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var llmTextTextView: UITextView!
    
    private var bot: LLM?
    private let gguf: String = "qwen1_5-0_5b-chat-q2_k.gguf"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBot()
    }
    
    @IBAction func prompt(_ sender: UIBarButtonItem) {
        
        WWHUD.shared.display()
        
        Task {
            WWHUD.shared.closeLabelSetting(title: "關閉")
            await demo(prompt: promptTextField.text)
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
        
        guard let bot = llmMaker(gguf: gguf) else { llmTextTextView.text = "LLM Model error"; return }
        self.bot = bot
        
        WWHUD.shared.delegate = self
    }
    
    func demo(prompt: String?) async {
        
        guard let prompt = prompt,
              let bot
        else {
            llmTextTextView.text = "Bot error"; return
        }
        
        let question = bot.preprocess(prompt, [])
        let answer = await bot.getCompletion(from: question)
        
        bot.stop()
        llmTextTextView.text = answer
    }
    
    func llmMaker(gguf: String) -> LLM? {
        
        guard let gguflUrl = Bundle.main.url(forResource: gguf, withExtension: nil) else { return nil }
        return LLM(from: gguflUrl, template: .chatML())
    }
}
