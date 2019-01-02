import Foundation
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper

class AllCategories: Object, Mappable {
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    @objc dynamic var name : String = ""
    @objc dynamic var needUpdate : Bool = true
    @objc dynamic var lastUpdateIndex : Int = 0
    let allItems = List<AllItems>()
    
}
