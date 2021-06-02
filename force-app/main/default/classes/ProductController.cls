public with sharing class ProductController {
    // remove ? static Integer PAGE_SIZE = 9;

    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        @AuraEnabled
        public String[] categories { get; set; }
        @AuraEnabled
        public String[] materials { get; set; }
        @AuraEnabled
        public String[] frameColors { get; set; }
        @AuraEnabled
        public String[] levels { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getProducts(Filters filters, Integer pageNumber, Integer pageSize) {
        String key, whereClause = '';
        Decimal maxPrice;
        String[] categories, materials, frameColors, levels, criteria = new List<String>{};
        if (filters != null) {
            maxPrice = filters.maxPrice;
            materials = filters.materials;
            frameColors = filters.frameColors;
            levels = filters.levels;
            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
                criteria.add('Name LIKE :key');
            }
            if (filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.levels != null) {
                levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (filters.materials != null) {
                materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
            if (filters.frameColors != null) {
                frameColors = filters.frameColors;
                criteria.add('Frame_Color__c IN :frameColors');
            }
            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }
        //Integer pageSize = ProductController.pageSize;    // Changed from 
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM Product__c ' + whereClause
        );
        result.records = Database.query(
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c, Frame_Color__c FROM Product__c ' +
            whereClause +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static Product__c[] getSimilarProducts(Id productId, Id familyId) {
        return [
            SELECT
                Id,
                Name,
                MSRP__c,
                Description__c,
                Category__c,
                Level__c,
                Picture_URL__c,
                Material__c,
                Frame_Color__c
            FROM Product__c
            WHERE Product_Family__c = :familyId AND Id != :productId
            WITH SECURITY_ENFORCED
        ];
    }

    public static HttpResponse calloutProductAvailability(String pName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String pageName = pName.replaceAll('\\s+','+');
        request.setMethod('GET');
        request.setEndpoint('https://vpsdevds2-viasat.cs32.force.com/paymentservice/services/apexrest/ebikestockcheck/?pname=' +pageName);
        request.setHeader('x-api-key', 'abc123');
        request.setHeader('Cookie', 'BrowserId=Jlnf3nImEeumZZ88qOXBuw');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new Http().send(request);

        return response;
    }

    @AuraEnabled
    public static String getProductAvailability(String pName) {

        HttpResponse response = calloutProductAvailability(pName);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        }

        return null;
    }
}