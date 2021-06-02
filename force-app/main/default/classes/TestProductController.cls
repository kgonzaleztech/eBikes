@isTest
public class TestProductController {
    @testSetup
    static void createProducts() {
        List<Product__c> products = new List<Product__c>();

        products.add(
            new Product__c(
                Name = 'Sample Bike 1',
                MSRP__c = 1000,
                Category__c = 'Mountain',
                Level__c = 'Beginner',
                Material__c = 'Carbon'
            )
        );

        products.add(
            new Product__c(
                Name = 'Sample Bike 2',
                MSRP__c = 1200,
                Category__c = 'Mountain',
                Level__c = 'Beginner',
                Material__c = 'Carbon'
            )
        );

        insert products;
    }

    @isTest
    static void testGetProducts() {
        ProductController.Filters filters = new ProductController.Filters();
        filters.searchKey = 'Sample';
        filters.maxPrice = 2000;
        filters.categories = new List<String>{ 'Mountain' };
        filters.levels = new List<String>{ 'Beginner' };
        filters.materials = new List<String>{ 'Carbon' };
        PagedResult result = ProductController.getProducts(filters, 1, 9);
        System.assertEquals(result.records.size(), 2);
    }

    @isTest
    static void testGetSimilarProducts() {
        ProductController.Filters filters = new ProductController.Filters();
        filters.searchKey = 'Sample';
        filters.maxPrice = 2000;
        filters.categories = new List<String>{ 'Mountain' };
        filters.levels = new List<String>{ 'Beginner' };
        filters.materials = new List<String>{ 'Carbon' };
        PagedResult result = ProductController.getProducts(filters, 1, 9);
        Product__c productToCompare = (Product__c) result.records[0];
        Product__c[] products = ProductController.getSimilarProducts(
            productToCompare.Id,
            null
        );
        System.assertEquals(products.size(), 1);
    }

    // @isTest static void testProductCallout() {
    //     // Set mock callout class 
    //     Test.setMock(HttpCalloutMock.class, new ProductHttpCalloutMock()); 
    //     // This causes a fake response to be sent
    //     // from the class that implements HttpCalloutMock. 
    //     String actualValue = ProductController.getProductAvailability('DYNAMO X1');
    //     // Verify that the response received contains fake values
    //     System.debug('+++--- actualValue: ' + actualValue);
    //     String expectedValue = '5';
    //     System.assertEquals(actualValue, expectedValue);
    // }

    @isTest 
    static void testProductStockCalloutWithStaticResources() {
        // Use StaticResourceCalloutMock built-in class to
        // specify fake response and include response body 
        // in a static resource.
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('calloutProductAvailabilityTest');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method that performs the callout
        HttpResponse response = ProductController.calloutProductAvailability('DYNAMO X1');
        
        // Verify response received contains values returned by
        // the mock response.
        // This is the content of the static resource.
        Integer expectedValue = 5;
        //List<String> responseMap = (List<String>)System.JSON.deserialize(res.getBody());
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        Integer actualValue = (Integer)responseMap.get('currentInventory');
        System.assertEquals(expectedValue, actualValue);
        Test.stopTest();
    }
}