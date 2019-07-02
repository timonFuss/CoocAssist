//
//  SpeechDetectionManager.swift
//  Flavr
//
//  Created by Timon Fuß on 14.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import Speech
import PromiseKit

class SpeechDetectionManager: UIViewController{
    /// sharedInstance: the SpeechDetectionManager singleton
    public static let sharedInstance = SpeechDetectionManager()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "de-DE"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var detectionTimer:Timer?
    
    var inputSpeech: String = ""
    var timerSet: Bool = false
    
    
    /**
     Start recording user speech, filtering final String -> After 0.5 seconds speech is detected as finished
     */
    func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){
            buffer, _ in self.request.append(buffer)
        }
        
        if !audioEngine.isRunning {
            do {
                audioEngine.prepare()
                try audioEngine.start()
            } catch{
                return print(error)
            }
        }
        
        /*guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        
        if !myRecognizer.isAvailable {
            return
        }*/
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            var isFinal = false
            var bestString = ""
            
            //Getting final string
            if result != nil {
                bestString = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
            }
            
            if let timer =  self.detectionTimer, timer.isValid{
                //Invalidate Timer if user is not finished speaking
                if isFinal {
                    self.detectionTimer?.invalidate()
                }
            } else {
                //Setting Timer if final string is detected (for end of speech)
                if self.inputSpeech == bestString {
                    self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {(timer) in
                        isFinal = true
                        timer.invalidate()
                        self.stopRecording()
                    })
                } else {
                    self.inputSpeech = bestString
                }
                
            }
            
        })
    }
    
    /**
     Stop user speech, pass on for sending Request to NLP
     */
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.finish()
        RequestHandler.sharedInstance.newRequest(msg: self.inputSpeech)
    }
    
    /**
     Stops recognition for finished Modules
     */
    func stopRecordingTimer() {
        audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.finish()
    }
    
    func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordAndRecognizeSpeech()
                case .denied:
                    print("DENIED")
                case .restricted:
                    print("restricted")
                case .notDetermined:
                    print("notDetermined")
                }
            }
        }
    }
    
    /*func requestSpeechAuthorization(button: UIButton, label: UILabel) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    button.isEnabled = true
                case .denied:
                    button.isEnabled = false
                    label.text = "User denied access to speech recognition"
                case .restricted:
                    button.isEnabled = false
                    label.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    button.isEnabled = false
                    label.text = "Speech recognition not yet authorized"
                }
            }
        }
    }*/
}


