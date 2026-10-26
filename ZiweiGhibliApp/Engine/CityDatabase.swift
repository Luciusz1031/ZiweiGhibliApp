import Foundation

public struct CityLocation: Identifiable, Codable, Hashable {
    public var id: String { name }
    public let name: String
    public let region: String
    public let longitude: Double
    public let latitude: Double
    public let standardLongitude: Double // 時區基準經度 (如東八區為 120.0)
    public let timeZoneIdentifier: String
    
    public init(name: String, region: String, longitude: Double, latitude: Double, standardLongitude: Double = 120.0, timeZoneIdentifier: String = "Asia/Taipei") {
        self.name = name
        self.region = region
        self.longitude = longitude
        self.latitude = latitude
        self.standardLongitude = standardLongitude
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

public struct CityDatabase {
    public static let defaultCity = CityLocation(name: "台北市", region: "台灣", longitude: 121.5654, latitude: 25.0330)
    
        public static let presetCities: [CityLocation] = [
        // 台灣地區 22 縣市完整涵蓋
        CityLocation(name: "台北市", region: "台灣", longitude: 121.5654, latitude: 25.0330),
        CityLocation(name: "新北市", region: "台灣", longitude: 121.4627, latitude: 25.0117),
        CityLocation(name: "基隆市", region: "台灣", longitude: 121.7462, latitude: 25.1276),
        CityLocation(name: "桃園市", region: "台灣", longitude: 121.3009, latitude: 24.9936),
        CityLocation(name: "新竹市", region: "台灣", longitude: 120.9675, latitude: 24.8138),
        CityLocation(name: "新竹縣", region: "台灣", longitude: 121.0180, latitude: 24.8383),
        CityLocation(name: "苗栗縣", region: "台灣", longitude: 120.8208, latitude: 24.5601),
        CityLocation(name: "台中市", region: "台灣", longitude: 120.6736, latitude: 24.1477),
        CityLocation(name: "彰化縣", region: "台灣", longitude: 120.5422, latitude: 24.0815),
        CityLocation(name: "南投縣", region: "台灣", longitude: 120.6869, latitude: 23.9099),
        CityLocation(name: "雲林縣", region: "台灣", longitude: 120.5435, latitude: 23.7092),
        CityLocation(name: "嘉義市", region: "台灣", longitude: 120.4491, latitude: 23.4800),
        CityLocation(name: "嘉義縣", region: "台灣", longitude: 120.2930, latitude: 23.4518),
        CityLocation(name: "台南市", region: "台灣", longitude: 120.1979, latitude: 22.9997),
        CityLocation(name: "高雄市", region: "台灣", longitude: 120.3120, latitude: 22.6273),
        CityLocation(name: "屏東縣", region: "台灣", longitude: 120.4880, latitude: 22.6761),
        CityLocation(name: "宜蘭縣", region: "台灣", longitude: 121.7533, latitude: 24.7570),
        CityLocation(name: "花蓮縣", region: "台灣", longitude: 121.6068, latitude: 23.9871),
        CityLocation(name: "台東縣", region: "台灣", longitude: 121.1444, latitude: 22.7583),
        CityLocation(name: "澎湖縣", region: "台灣", longitude: 119.5794, latitude: 23.5658),
        CityLocation(name: "金門縣", region: "台灣", longitude: 118.3226, latitude: 24.4363),
        CityLocation(name: "連江馬祖", region: "台灣", longitude: 119.9288, latitude: 26.1558),
        
        // 港澳
        CityLocation(name: "香港", region: "港澳", longitude: 114.1694, latitude: 22.3193, standardLongitude: 120.0, timeZoneIdentifier: "Asia/Hong_Kong"),
        CityLocation(name: "澳門", region: "港澳", longitude: 113.5439, latitude: 22.1987, standardLongitude: 120.0, timeZoneIdentifier: "Asia/Macau"),
        
        // 中國大陸主要代表城市
        CityLocation(name: "北京", region: "大陸", longitude: 116.4074, latitude: 39.9042),
        CityLocation(name: "上海", region: "大陸", longitude: 121.4737, latitude: 31.2304),
        CityLocation(name: "廣州", region: "大陸", longitude: 113.2644, latitude: 23.1291),
        CityLocation(name: "深圳", region: "大陸", longitude: 114.0579, latitude: 22.5431),
        CityLocation(name: "成都", region: "大陸", longitude: 104.0668, latitude: 30.5728),
        CityLocation(name: "重慶", region: "大陸", longitude: 106.5516, latitude: 29.5630),
        CityLocation(name: "武漢", region: "大陸", longitude: 114.3055, latitude: 30.5928),
        CityLocation(name: "西安", region: "大陸", longitude: 108.9398, latitude: 34.3416),
        CityLocation(name: "杭州", region: "大陸", longitude: 120.1551, latitude: 30.2741),
        CityLocation(name: "廈門", region: "大陸", longitude: 118.0894, latitude: 24.4798),
        CityLocation(name: "南京", region: "大陸", longitude: 118.7969, latitude: 32.0603),
        CityLocation(name: "昆明", region: "大陸", longitude: 102.8329, latitude: 24.8801),
        CityLocation(name: "烏魯木齊", region: "大陸", longitude: 87.6168, latitude: 43.8256),
        CityLocation(name: "哈爾濱", region: "大陸", longitude: 126.5350, latitude: 45.8038),
        
        // 亞洲其他及國際主要城市
        CityLocation(name: "新加坡", region: "海外", longitude: 103.8198, latitude: 1.3521, standardLongitude: 120.0, timeZoneIdentifier: "Asia/Singapore"),
        CityLocation(name: "吉隆坡", region: "海外", longitude: 101.6869, latitude: 3.1390, standardLongitude: 120.0, timeZoneIdentifier: "Asia/Kuala_Lumpur"),
        CityLocation(name: "東京", region: "海外", longitude: 139.6917, latitude: 35.6895, standardLongitude: 135.0, timeZoneIdentifier: "Asia/Tokyo"),
        CityLocation(name: "首爾", region: "海外", longitude: 126.9780, latitude: 37.5665, standardLongitude: 135.0, timeZoneIdentifier: "Asia/Seoul"),
        CityLocation(name: "紐約", region: "海外", longitude: -74.0060, latitude: 40.7128, standardLongitude: -75.0, timeZoneIdentifier: "America/New_York"),
        CityLocation(name: "洛杉磯", region: "海外", longitude: -118.2437, latitude: 34.0522, standardLongitude: -120.0, timeZoneIdentifier: "America/Los_Angeles"),
        CityLocation(name: "倫敦", region: "海外", longitude: -0.1278, latitude: 51.5074, standardLongitude: 0.0, timeZoneIdentifier: "Europe/London"),
        CityLocation(name: "雪梨", region: "海外", longitude: 151.2093, latitude: -33.8688, standardLongitude: 150.0, timeZoneIdentifier: "Australia/Sydney")
    ]
}
