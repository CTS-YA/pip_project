@IsTest(SeeAllData=true)
private class getFoundProductIdByIATest {
    
    public static void testGetFoundProductIdByIA() {
        // 1. Create Test Data
        // Create a Lead record
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open - New',
            Email = 'testlead@example.com',
            Description= 'Test Product'
        );
        insert testLead;

        // Create a Product record
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'P0012345',
            IsActive = true
        );
        insert testProduct;
        
        // 2. Mock LeadInformationGetter.leadInformationGetter (simulate the behavior)
        // In this case, we simulate the response that might be returned for the lead we inserted.
        // We'll assume that the LeadInformationGetter method would return the ProductId based on the Lead
        // as the product ID from the Product record we just inserted.
        
        // Prepare the mock data, which is what the LeadInformationGetter method would return
        Map<String, String> mockLeadInformation = new Map<String, String>();
        mockLeadInformation.put('ProductId', testProduct.Id);
        
        // 3. You can use a custom wrapper or utility to simulate this static method call
        // Simulating the static call to LeadInformationGetter
        Test.startTest();
        
        // Mock response (this would normally be a call to LeadInformationGetter in a real implementation)
        String mockResponse = '{"ProductId": "' + testProduct.Id + '"}'; // Simulate JSON response
        
        // Call the method you're testing
        String result = getFoundProductIdByIA.getFoundProductIdByIA(testLead.Id);
        
        // Assertions to validate the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assert(result.contains(testProduct.Id), 'The returned product ID should match the expected product ID');
        
        Test.stopTest();
    }
}
