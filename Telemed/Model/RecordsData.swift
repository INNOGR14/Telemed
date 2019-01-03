import Foundation
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper

class RecordsData: Object, Mappable {
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        data <- map["data"]
        
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    @objc dynamic var name : String = ""
    @objc dynamic var data : String = ""
    
}
