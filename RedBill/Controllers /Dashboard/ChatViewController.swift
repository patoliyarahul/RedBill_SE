//
//  ChatViewController.swift
//  RedBill
//
//  Created by Dharmesh Vaghani on 09/01/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit

import Firebase
import JSQMessagesViewController
import Photos
import SKPhotoBrowser

final class ChatViewController: JSQMessagesViewController {
    
    //dbv : notification testing reamining for chat...... need to call show chat method
    
    // MARK: Properties
    var channelRef: DatabaseReference = Database.database().reference().child(FMessageParams.FMESSAGE_PATH)
    
    var messages = [JSQMessage]()
    
    var recent : Recent!
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    private var messageRef: DatabaseReference!
    private var newMessageRefHandle: DatabaseHandle?
    
    //Typing indication Properties
    private lazy var userIsTypingRef: DatabaseReference =
        self.channelRef.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    private lazy var usersTypingQuery: DatabaseQuery =
        self.channelRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    //Sending Image properties
    
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://redbill-39ae6.appspot.com")
    private let imageURLNotSetKey = "NOTSET"
    
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    private var updatedMessageRefHandle: DatabaseHandle?
    
    let dateFormatter = DateFormatter()
    
    var isFromNotif = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.ReSetCustomNavigationBar()
        self.navigationController?.isNavigationBarHidden = false
        
        self.senderId = Auth.auth().currentUser?.uid
        
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        self.senderDisplayName = "\(userDefault.string(forKey: FUserParams.FUSER_FIRSTNAME)!) \(userDefault.string(forKey: FUserParams.FUSER_LASTNAME)!)"
        
        self.title = recent.description
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        collectionView.collectionViewLayout.messageBubbleFont = UIFont(name: "ProximaNova-Regular", size: 16)
        
        channelRef = Database.database().reference().child(FMessageParams.FMESSAGE_PATH).child(recent.groupId)
        userIsTypingRef = channelRef.child("typingIndicator").child(self.senderId)
        usersTypingQuery = channelRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
        
        observeMessages()
        
        if isFromNotif {
            let cancelButton = UIBarButtonItem(title: staus.Cancel, style: .done, target: self, action: #selector(self.cancelAction))
            self.navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    //MARK: - sendMessageNotification
    
    func sendMessageNotification(message: String, senderName: String) {
        DispatchQueue.global(qos: .background).async {
            //dbv call notification service in this block
            let service = Service()
            service.delegate = self
            
            let data: [String: Any] = [ChatNotificationParams.senderId : "\(userDefault.string(forKey: API_param.Login.UserId)!)",
                                       ChatNotificationParams.senderName : userDefault.value(forKey: DefaultValues.device_id) ?? "",
                                       ChatNotificationParams.senderEmail : "\(userDefault.string(forKey: API_param.Login.email)!)",
                                       ChatNotificationParams.recieverId : self.recent.dbId,
                                       ChatNotificationParams.pushMessage : "\(senderName): \(message)"]
            service.apiName = ApiName.chatNotification
            service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.chatNotification))!, parameters: data,encodingType:"json",headers:nil)
        }
    }
    
    //JSQMessagesViewController Methods
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "timeStamp" : Date().timeIntervalSince1970] as [String : Any]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        isTyping = false
        
        sendMessageNotification(message: text!, senderName: senderDisplayName!)
        Chat_Utils.updateLastMessage(lastMessage: text, groupId: recent.groupId)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        let sourceSelector = UIAlertController(title: "Add Image", message: "", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            }
            
            self.present(picker, animated: true, completion: nil)
        }
        
        let gallery = UIAlertAction(title: "Upload From Library", style: .default) { action -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            }
            
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: staus.Cancel, style: .cancel, handler: nil)
        
        sourceSelector.addAction(camera)
        sourceSelector.addAction(gallery)
        sourceSelector.addAction(cancelAction)
        
        self.present(sourceSelector, animated: true, completion: nil)
    }
    
    //MARK: - Add Message Methods
    private func addMessage(withId id: String, name: String, text: String, date: Date) {
        
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
//            message.text = "";
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem, date: Date) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    //MARK: - IS Typing Methods
    private func observeMessages() {
        messageRef = channelRef.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if messageData.count == 0 {
                print("no data ")
            }
        
            if let id = messageData["senderId"] as! String?, let name = messageData["senderName"] as! String?, let text = messageData["text"] as! String!, text.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text, date: Date(timeIntervalSince1970: messageData["timeStamp"]! as! TimeInterval))
                
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as! String?, let photoURL = messageData["photoURL"] as! String? { // 1
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem, date: Date())
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                let key = snapshot.key
                if let messageData = snapshot.value as? Dictionary<String, String> {
                    if let photoURL = messageData["photoURL"] as String? {
                        if let mediaItem = self.photoMessageMap[key] {
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                        }
                    }
                }
            }
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
    }
    
    //MARK: - Send Photo Methods
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                //                if (metadata?.contentType == "image/gif") {
                //                    mediaItem.image = UIImage.gifWithData(data!)
                //                } else {
                mediaItem.image = UIImage.init(data: data!)
                //                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView?.textColor = UIColor(red: 28.0/255, green: 29.0/255, blue: 30.0/255, alpha: 1)
        
        let message = messages[indexPath.row]
        cell.cellBottomLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: message.date))
        
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.row]
        if message.isMediaMessage {
            let mediaItem = message.media
            if let photoItem = mediaItem as? JSQPhotoMediaItem {
                if let photoImage = photoItem.image {
                    let browser = SKPhotoBrowser(photos: [SKPhoto.photoWithImage(photoImage)])
                    self.present(browser, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: UI and User Interaction
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(String(describing: Auth.auth().currentUser?.uid))/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

//MARK: - Service Delegate

extension ChatViewController : ServiceDelegate {
    func onResult(resultData: Any?, ServiceName: String) {
        print("\(String(describing: resultData))")
    }
    
    func onFault(resultData: [String : Any]?, ServiceName: String) {
        print("\(String(describing: resultData))")
    }
}
