//
//  Chat+Utils.swift
//  SPG Client
//
//  Created by Dharmesh Vaghani on 11/02/17.
//  Copyright © 2017 Ahmed Elhosseiny. All rights reserved.
//

import UIKit
import Firebase

class Chat_Utils: NSObject {
    class func updateFUserPersonalDetails() {
        if let user = Auth.auth().currentUser {
            let userRef = Database.database().reference().child(FUserParams.FUSER_PATH).child(user.uid)
            let userInfo = [FUserParams.FUSER_FIRSTNAME : userDefault.string(forKey: FUserParams.FUSER_FIRSTNAME)!,
                            FUserParams.FUSER_LASTNAME  : userDefault.string(forKey: FUserParams.FUSER_LASTNAME)!,
                            FUserParams.FUSER_FULLNAME  : "\(userDefault.string(forKey: FUserParams.FUSER_FIRSTNAME)!) \(userDefault.string(forKey: FUserParams.FUSER_LASTNAME)!)",
                            FUserParams.FUSER_EMAIL     : userDefault.string(forKey: FUserParams.FUSER_EMAIL)!,
                            FUserParams.FUSER_OBJECTID  : user.uid,
                            FUserParams.FUSER_DBID      : userDefault.string(forKey: API_param.Login.UserId)!,
                            FUserParams.FUSER_PICTURE   : ""] // dbv no profile pic
            userRef.setValue(userInfo)
        }
    }

    class func startPrivateChat(email: String, completionHandler: @escaping (Recent) -> Void) {
        let user1 = Auth.auth().currentUser

        fetchUserBasedOnEmail(email: email, completionHandler: { (dict: Dictionary<String, String>) in
            let userId1 = user1?.uid
            let userId2 = dict[FUserParams.FUSER_OBJECTID]!

            let initials1 = initials(firstName: userDefault.string(forKey: FUserParams.FUSER_FIRSTNAME)!, lastName: userDefault.string(forKey: FUserParams.FUSER_LASTNAME)!)
            let initials2 = initials(firstName: dict[FUserParams.FUSER_FIRSTNAME]!, lastName: dict[FUserParams.FUSER_LASTNAME]!)

            let picture1 = ""
            let picture2 = dict[FUserParams.FUSER_PICTURE]!

            let name1   =   "\(userDefault.string(forKey: FUserParams.FUSER_FIRSTNAME)!) \(userDefault.string(forKey: FUserParams.FUSER_LASTNAME)!)"
            let name2   =   dict[FUserParams.FUSER_FULLNAME]!

            let userDbId1   = "\(userDefault.string(forKey: API_param.Login.UserId)!)"
            let userDbId2   = "\(dict[FUserParams.FUSER_DBID]!)"

            let members : [String] =   [userId1!, userId2]

            let sorted      =   members.sorted(by: { $0 < $1 } )
            let groupId     =   md5HashOfString(string: sorted.joined(separator: ""))

            var recent = Recent();

            fetchMembers(groupId: groupId, completionHandler:  { userIds in
                recent = createItem(userId: userId1!, groupId: groupId, initials: initials2, picture: picture2, description: name2, members: members, type: "private", dbId: userDbId2)

                if !userIds.contains(userId2) {
                    _ = createItem(userId: userId2, groupId: groupId, initials: initials1, picture: picture1, description: name1, members: members, type: "private", dbId:  userDbId1)
                }

                completionHandler(recent)
            })
        })
    }

    class func fetchUserBasedOnEmail(email: String, completionHandler: @escaping (Dictionary<String, String>) -> Void) {
        let userRef = Database.database().reference().child(FUserParams.FUSER_PATH)

        userRef.queryOrdered(byChild: FUserParams.FUSER_EMAIL).queryEqual(toValue: email).observe(.childAdded, with: { snapshot in
            print(snapshot.value!)

            completionHandler(snapshot.value as! Dictionary<String, String>)
        }, withCancel: { error in
            print(error)
        })
    }

    class func updateLastMessage(lastMessage: String, groupId: String) {
        fetchMembers(groupId: groupId, completionHandler: { userIds in
            let recentRef = Database.database().reference(withPath: FRecentParams.FRECENT_PATH)

            var count = 0

            for userId in userIds {
                let temp = "\(groupId)\(userId)"
                let objectId    =   md5HashOfString(string: temp)

                let recentUserRef = recentRef.child(objectId)

                recentUserRef.observe(DataEventType.value, with: { (snapshot) in
                    if count < userIds.count {
                        if let postDict = snapshot.value as? Dictionary<String, Any> {
                            var counter = Int("\(postDict[FRecentParams.FRECENT_COUNTER]!)")

                            var recentDict = postDict

                            counter = userId == (Auth.auth().currentUser?.uid)! ? 0 : counter! + 1

                            recentDict[FRecentParams.FRECENT_LASTMESSAGEDATE] = Date().timeIntervalSince1970
                            recentDict[FRecentParams.FRECENT_COUNTER] = "\(counter!)"
                            recentDict[FRecentParams.FRECENT_LASTMESSAGE] = lastMessage

                            recentUserRef.setValue(recentDict)

                            count += 1
                        }
                    }
                })
            }

        })
    }

    class func resetCounter(objectId: String) {

        let recentRef = Database.database().reference(withPath: FRecentParams.FRECENT_PATH).child(objectId)

        recentRef.observe(DataEventType.value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, Any> {
                var recentDict = postDict

                if "\(recentDict[FRecentParams.FRECENT_USERID]!)" == (Auth.auth().currentUser?.uid)! {
                    recentDict[FRecentParams.FRECENT_COUNTER] = "0"
                    recentRef.setValue(recentDict)
                }
            }
        })
    }

    class func fetchMembers(groupId: String, completionHandler: @escaping ([String]) -> ()) {
        let recentRef = Database.database().reference(withPath: FRecentParams.FRECENT_PATH)

        var userIds = [String]()

        recentRef.queryOrdered(byChild: FRecentParams.FRECENT_GROUPID).queryEqual(toValue: groupId).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    print(rest.value!)

                    if let dict = rest.value as? Dictionary<String, Any> {
                        userIds.append("\(dict[FRecentParams.FRECENT_USERID]!)")
                    }
                }
            }

            completionHandler(userIds)
            recentRef.removeAllObservers()
        })
    }


    class func createItem(userId: String , groupId : String, initials: String, picture : String, description : String, members: [String], type: String, dbId: String) -> Recent {

        let temp = "\(groupId)\(userId)"
        let objectId    =   md5HashOfString(string: temp)

        let recentRef   =   Database.database().reference().child(FRecentParams.FRECENT_PATH).child(objectId)
        let recentDict  =   [FRecentParams.FRECENT_OBJECTID : objectId,
                             FRecentParams.FRECENT_USERID   : userId,
                             FRecentParams.FRECENT_GROUPID  : groupId,
                             FRecentParams.FRECENT_INITIALS : initials,
                             FRecentParams.FRECENT_PICTURE  : picture,
                             FRecentParams.FRECENT_MEMBERS  : members,
                             FRecentParams.FRECENT_PASSWORD : "123456789",
                             FRecentParams.FRECENT_TYPE     : type,
                             FRecentParams.FRECENT_COUNTER  : "0",
                             FRecentParams.FRECENT_DESCRIPTION  : description,
                             FRecentParams.FRECENT_LASTMESSAGE  :   "",
                             FRecentParams.FRECENT_LASTMESSAGEDATE  : Date().timeIntervalSince1970,
                             FRecentParams.FRECENT_ISDELETED    : false,
                             FRecentParams.FRECENT_ISARCHIVED   : false,
                             FRecentParams.FRECENT_DBID         : dbId] as [String : Any]

        recentRef.setValue(recentDict)

        return Recent(dict: recentDict)
    }

    class func initials(firstName: String, lastName: String) -> String {

        if firstName.count > 0  && lastName.count > 0 {
            return "\((firstName as NSString).substring(to: 1))\((lastName as NSString).substring(to: 1))"
        }

        return ""
    }
}

func md5HashOfString(string: String) -> String {
    guard let messageData = string.data(using:String.Encoding.utf8) else { return "" }
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

    _ = digestData.withUnsafeMutableBytes {digestBytes in
        messageData.withUnsafeBytes {messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
        }
    }

    return md5HashOfData(data: digestData)
}

func md5HashOfData(data: Data) -> String {
    return data.map { String(format: "%02hhx", $0) }.joined()
}

func MD5(string: String) -> Data? {
    guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

    _ = digestData.withUnsafeMutableBytes {digestBytes in
        messageData.withUnsafeBytes {messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
        }
    }

    return digestData
}

