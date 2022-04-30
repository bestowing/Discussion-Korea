//
//  Cache.swift
//  NetworkPlatform
//
//  Created by 이청수 on 2022/04/29.
//

import Foundation
import RxSwift

//protocol AbstractCache {
//
//    associatedtype T
//
////    func save(object: T) -> Completable
//    func save(objects: [T]) -> Completable
////    func fetch(withID id: String) -> Maybe<T>
//    func fetchObjects() -> Maybe<[T]>
//
//}
//
//final class Cache<T: Encodable>: AbstractCache where T == T {
//
//    enum FileNames {
//        static var objectFileName: String {
//            return "\(T.self).dat"
//        }
//        static var objectsFileName: String {
//            return "\(T.self)s.dat"
//        }
//    }
//
//    private let path: String
//    private let cacheScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.CleanAchitecture.Network.Cache.queue")
//
//    init(path: String) {
//        self.path = path
//    }
//
//    func save(objects: [T]) -> Completable {
//        return Completable.create { (observer) -> Disposable in
//            guard let directoryURL = self.directoryURL() else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            let path = directoryURL
//                .appendingPathComponent(FileNames.objectsFileName)
//            self.createDirectoryIfNeeded(at: directoryURL)
//            do {
//                try NSKeyedArchiver.archivedData(withRootObject: objects.map{ $0.encoder })
//                    .write(to: path)
//                observer(.completed)
//            } catch {
//                observer(.error(error))
//            }
//            
//            return Disposables.create()
//        }.subscribe(on: cacheScheduler)
//    }
//
//    func fetchObjects() -> Maybe<[T]> {
//        return Maybe<[T]>.create { (observer) -> Disposable in
//            guard let directoryURL = self.directoryURL() else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            let fileURL = directoryURL
//                .appendingPathComponent(FileNames.objectsFileName)
//            guard let objects = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? [T.Encoder] else {
//                observer(.completed)
//                return Disposables.create()
//            }
//            observer(MaybeEvent.success(objects.map { $0.asDomain() }))
//            return Disposables.create()
//        }.subscribe(on: cacheScheduler)
//    }
//    
//    private func directoryURL() -> URL? {
//        return FileManager.default
//            .urls(for: .documentDirectory,
//                  in: .userDomainMask)
//            .first?
//            .appendingPathComponent(path)
//    }
//
//    private func createDirectoryIfNeeded(at url: URL) {
//        do {
//            try FileManager.default.createDirectory(at: url,
//                                                    withIntermediateDirectories: true,
//                                                    attributes: nil)
//        } catch {
//            print("Cache Error createDirectoryIfNeeded \(error)")
//        }
//    }
//
//}
