//
//  APICaller.swift
//  Instagram Clone
//
//  Created by Sweety on 26/05/2023.
//

import Foundation
import UIKit

struct APICaller {
    
    static let shared = APICaller()
    let baseURL = "http://127.0.0.1:5000/"
    
    func createPost(withData post: toPost, image: UIImage, completion: @escaping (Bool) -> ()) {
        
        //================= convert image into imageData =================================
        guard let imageData = image.pngData() else {
            print("error convert to jpeg data!")
            return
        }
        
        //================= convert json into jsonData ===================================
        let json = [
            "uid": post.uid,
            "caption": post.caption,
            "createDate": Date().getFormattedTime()
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("error convert to json data!")
            return
        }
        
        //================= body =========================================================
        let boundary = UUID().uuidString
        let body = NSMutableData()
        
        //================= image1 =================
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\" \r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        //================= json =================
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"json\" \r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append(jsonData)
        body.append("\r\n".data(using: .utf8)!)
        
        //================= closing =================
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        //==================================================================================
        var request = URLRequest(url: URL(string: baseURL + "upload")!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            
            completion(true)
        }
        
        task.resume()
    }
    
    func fetchPost(withUID userUID: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        var request = URLRequest(url: URL(string: baseURL + "data")!)
        
        let json = [
            "uid": userUID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("json serialization error orcurred!")
            return
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                print("error fetching post!")
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }
        
        task.resume()
    }
    
    func fetchImage(fromUrl url: String, completion: @escaping (_ result: Result<UIImage, Error>) -> Void) {
        
        guard let url = URL(string: url) else {
            print("invalid url from fetchImage!")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error occured while fetch post image")
                completion(.failure(error!))
                return
            }
            
            if let image = UIImage(data: data) {    // data convert to image
                completion(.success(image))
            }

            
        }
        task.resume()
    }
    
    func createUser(with userInfo: [String: Any], completion: @escaping (Error?) -> Void) {
        
        //================= convert image into imageData =================================
        guard let imageData = (userInfo["profilePic"] as? UIImage)?.pngData() else {
            print("cannot convert to jpeg data!")
            return
        }
        
        //================= convert json into jsonData ===================================
        let json = [
            "uid": userInfo["uid"],
            "name": userInfo["name"],
            "email": userInfo["email"],
            "createDate": Date().getFormattedTime()
        ]
        
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("error to convert to data")
            return
        }
        
        //================= body =========================================================
        let boundary = UUID().uuidString
        let body = NSMutableData()
        
        //================= image1 =================
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\" \r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        //================= json =================
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"json\" \r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append(jsonData)
        body.append("\r\n".data(using: .utf8)!)
        
        //================= closing =================
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        //==================================================================================
        
        var request = URLRequest(url: URL(string: baseURL + "adduser")!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("error occured in adduser")
                completion(error)
                return
            }
            
            completion(nil)
        }
        
        task.resume()
    }
    
    func fetchUsers(completion: @escaping (Result<[InstagramUser], Error>) -> Void) {
         
        let request = URLRequest(url: URL(string: baseURL + "users")!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([InstagramUser].self, from: data)
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
        }
        task.resume()
        
    }
    
    func fetchUser(withUserUID userUUID: String, completion: @escaping (Result<InstagramUser, Error>) -> Void) {
        
        let json = [
            "userUID": userUUID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("cannot convert userUUID into jsonData")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "user")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(InstagramUser.self, from: data)
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
        }
        task.resume()
        
    }
    
    
    
    
    func addLike(with like: toLike, completion: @escaping (_ success: Bool) -> Void) {
        
        let json: [String: Any] = [
            "likePostUID": like.likePostUID,
            "userUID": like.userUID,
            "createDate": Date().getFormattedTime()
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("cannot convert addlike dic into jsonData!")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "addlike")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("error occured when addlike")
                completion(false)
                return
            }
            
            completion(true)
        }
        
        task.resume()
        
    }
    
    func addFollowing(with follow: [String: String], completion: @escaping (Bool) -> Void ) {
        
        let json = [
            "followerUUID": follow["followerUUID"],
            "followingUUID": follow["followingUUID"],
            "followTime": Date().getFormattedTime()
        
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("cannot convert toFollow dic into jsonData!")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "addfollow")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print(error?.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
        
        task.resume()
    }
    
    func fetchUserProfile(withUserUID userUUID: String, completion: @escaping (Result<Follow, Error>) -> Void) {
        
        let json = [
            "userUID": userUUID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("cannot convert userUUID into jsonData")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "fetchprofile")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Follow.self, from: data)
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
        }
        task.resume()
        
    }
    
    func fetchPersonalPost(withUserUID userUUID: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        let json = [
            "userUID": userUUID
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("cannot convert userUUID into jsonData from fetchPersonalPost")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "fetchprofilepost")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(result))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
        
    }
    
    func addComment(with comment: [String: Any], completion: @escaping (Error?) -> Void) {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: comment) else {
            print("cannot convert to comment jsonData")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "addcomment")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, reponse, error in
            guard let _ = data, error == nil else {
                completion(error)
                return
            }
            
            completion(nil)
        }
        
        task.resume()
        
        
    }
    
    func fetchComment(with post_id: [String: Int], completion: @escaping (Result<[Comment], Error>) -> Void) {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: post_id) else {
            print("cannot convert to jsonData from fetchComment")
            return
        }
        
        var request = URLRequest(url: URL(string: baseURL + "fetchcomment")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Comment].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }
        task.resume()
    }

}
