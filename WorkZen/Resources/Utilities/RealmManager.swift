import RealmSwift

final class RealmManager {
    
    // MARK: - Singleton Instance
    static let shared = RealmManager()
    
    private var realm: Realm
    private var notificationToken: NotificationToken?
    
    private init() {
        do {
            realm  = try Realm()
        } catch {
            fatalError("Could not access database: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CURD Operations
    
    // Create / Save
    func create<T: Object>(_ object: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try realm.write {
                realm.add(object)
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Update
    func update(_ updateBlock: () -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try realm.write {
                updateBlock()
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Delete
    func delete<T: Object>(_ obj: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try realm.write {
                realm.delete(obj)
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Read
    
    func getObject<T: Object, KeyType>(ofType type: T.Type, forPrimaryKey key: KeyType) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    func getAll<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    // MARK: - Observe Realm Changes
    func observeChanges<T: Object>(for type: T.Type, onChange: @escaping () -> Void) {
        let results = getAll(type)
        notificationToken = results.observe { changes in
            switch changes {
            case .initial:
                onChange()
            case .update:
                onChange()
            case .error(let error):
                print("Realm observe error: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
