//
//  SpeechManager.swift
//  BonocleLearn
//
//  Created by Mahmoud ELDemery on 12/06/2021.
//

import Foundation
import Speech

class SpeechManager {
    
    public var speechRecognizer:SFSpeechRecognizer?
    public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    public var recognitionTask: SFSpeechRecognitionTask?
    public let audioEngine = AVAudioEngine()

    static let sharedInstance: SpeechManager = {
        let instance = SpeechManager()
        // setup code
        return instance
    }()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> ()) {
      
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            completion(isButtonEnabled)
        }
    }
    
    func startSpeechRecognization(language:String, completion: @escaping (String) -> ()){
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))!
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
           
       
       
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (response, error) in
               guard let response = response else {
                   if error != nil {
//                    fatalError(error.debugDescription)
                   }else {
                    fatalError("Problem in giving the response")
                   }
                   return
               }
               

               let message = response.bestTranscription.formattedString
               print("Message : \(message)")
                completion(message)
               
               
           })
        
        
           let node = audioEngine.inputNode
           let recordingFormat = node.outputFormat(forBus: 0)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch { }
           
           node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
           }
           
           audioEngine.prepare()
           do {
               try audioEngine.start()
           } catch let error {
            fatalError("Error comes here for starting the audio listner =\(error.localizedDescription)")
           }
           
           guard let myRecognization = SFSpeechRecognizer() else {
            fatalError("Recognization is not allow on your local")

               return
           }
           
           if !myRecognization.isAvailable {
            fatalError("Recognization is free right now, Please try again after some time.")
           }
        
       }
    func cancelSpeechRecognization() {
        recognitionTask?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil
           
        recognitionRequest?.endAudio()
           audioEngine.stop()
           //audioEngine.inputNode.removeTap(onBus: 0)
           
           //MARK: UPDATED
           if audioEngine.inputNode.numberOfInputs > 0 {
               audioEngine.inputNode.removeTap(onBus: 0)
           }
       }
    
}
