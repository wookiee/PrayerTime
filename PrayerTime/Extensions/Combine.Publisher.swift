
import Foundation
import Combine

extension Publisher {
    
    func tryAsyncMap<OutputValue>(_ transform: @escaping (Output) async throws -> OutputValue)
    -> Publishers.FlatMap<Future<OutputValue, Error>, Self> where OutputValue: Sendable {
        flatMap { upstreamValue -> Future<OutputValue, Error> in
            Future { promise in
                Task {
                    do {
                        let result = try await transform(upstreamValue)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    func tryReplace<T>(_ generate: @escaping () throws -> T)
    -> Publishers.TryMap<Self, T> {
        tryMap { _ in
            return try generate()
        }
    }
}

extension Publisher where Output == Optional<Any> {
    func compactUnwrap<T>() -> Publishers.CompactMap<Self,T> {
        compactMap { $0 as! T? }
    }
}

extension Publisher where Failure == Never {
    func asyncMap<T>(_ transform: @escaping (Output) async -> T)
    -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { output in
            Future<T, Never> { promise in
                Task {
                    let result = await transform(output)
                    promise(.success(result))
                }
            }
        }
    }
    
    func replace<T>(_ generate: @escaping () -> T)
    -> Publishers.Map<Self, T> {
        map { _ in
            return generate()
        }
    }
    
}
