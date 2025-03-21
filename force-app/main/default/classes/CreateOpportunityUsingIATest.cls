@IsTest(SeeAllData=true)
public class CreateOpportunityUsingIATest {
    @isTest
    static void testHandleOpportunityCreation() {

        List<Account> accountInitialCount = [SELECT Id, Name FROM Account  ];
        List<Contact> contactInitialCount = [SELECT Id, LastName, Email FROM Contact ];
        List<Opportunity> opportunityInitialCount = [SELECT Id, Name FROM Opportunity  ];
        List<OpportunityLineItem> opportunityLineItemInitialCount = [SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItem];

        // Setup test data for Product
        Product2 testProduct = new Product2(
            Name = 'Test Product Test Product',
            IsActive = true
        );
        insert testProduct;

        Id pricebookId = Test.getStandardPricebookId();
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
         update standardPricebook;
        // Create a standard Pricebook entry for the product
        
    
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert standardPricebookEntry;

        

        

        // Setup test data for Lead
        List<Lead> testLeads = new List<Lead>{
            new Lead(
                LastName = 'TestTEST',
                Company = 'TestTEST Company',
                Email = 'TestTEST@example.com',
                Phone = '1234567890',
                Description= 'Test Product Test Product'
            )
        };
        insert testLeads;

        // Mock external service calls
        Test.startTest();
        
        // Mock response for getFoundProductIdByIA
        // Assuming it returns the Product2 Id for the test product
        // For this example, you might use an approach to simulate this call

        
        // Simulate the external call
        // You might need to adjust this part based on how your external calls work

        

        // Assertions
        List<Account> accounts = [SELECT Id, Name FROM Account  ];
        List<Contact> contacts = [SELECT Id, LastName, Email FROM Contact ];
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity  ];
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItem];

        // Validate that Accounts, Contacts, Opportunities, and OpportunityLineItems were created
        System.assertEquals(accountInitialCount.size()+1, accounts.size(), 'One account should be created.');
        System.assertEquals(contactInitialCount.size()+1, contacts.size(), 'One contact should be created.');
        System.assertEquals(opportunityInitialCount.size()+1, opportunities.size(), 'One opportunity should be created.');
        System.assertEquals(opportunityLineItemInitialCount.size()+1, opportunityLineItems.size(), 'One OpportunityLineItem should be created.');

        // Check that the OpportunityLineItem is linked to the Opportunity and Product
        OpportunityLineItem lastOli = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice 
                                 FROM OpportunityLineItem 
                                 ORDER BY CreatedDate DESC 
                                 LIMIT 1];

        System.assertNotEquals(null, lastOli.OpportunityId, 'OpportunityId should be assigned.');
        System.assertEquals(testProduct.Id, lastOli.Product2Id, 'Product2Id should match the test product.');

        Test.stopTest();
    }
}