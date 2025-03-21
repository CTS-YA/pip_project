@IsTest(SeeAllData=true)
public class CreateOpportunityTriggerTest {
    @isTest
    static void testOpportunityCreation() {
        // Initial count of records
        List<Account> accountInitialCount = [SELECT Id, Name FROM Account  ];
        List<Contact> contactInitialCount = [SELECT Id, LastName, Email FROM Contact ];
        List<Opportunity> opportunityInitialCount = [SELECT Id, Name FROM Opportunity  ];

        // Prepare test data for Leads
        List<Lead> testLeads = new List<Lead>{
            new Lead(
                LastName = 'TestLead1',
                Company = 'Test Company 1',
                Email = 'testlead1@example.com',
                Phone = '1234567890',
                Description = 'Test Description 1'
            ),
            new Lead(
                LastName = 'TestLead2',
                Company = 'Test Company 2',
                Email = 'testlead2@example.com',
                Phone = '0987654321',
                Description = 'Test Description 2'
            )
        };

        // Insert the test leads
        Test.startTest();
        insert testLeads;
        Test.stopTest();

        // Verify that opportunities were created
        List<Opportunity> createdOpportunities = [SELECT Id, Name, StageName, CloseDate FROM Opportunity ORDER BY CreatedDate DESC 
        LIMIT 2 ];

        List<Account> accounts = [SELECT Id, Name FROM Account  ];
        List<Contact> contacts = [SELECT Id, LastName, Email FROM Contact ];
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity  ];
  

        // Assert that opportunities were created for each lead
        System.assertEquals(2, createdOpportunities.size(), 'Two opportunities should be created.');

        System.assertEquals(accountInitialCount.size()+2, accounts.size(), 'One account should be created.');
        System.assertEquals(contactInitialCount.size()+2, contacts.size(), 'One contact should be created.');
        System.assertEquals(opportunityInitialCount.size()+2, opportunities.size(), 'One opportunity should be created.');

        


        // Additional assertions can be made based on expected values
        for (Opportunity opp : createdOpportunities) {
            System.assertNotEquals(null, opp.Name, 'Opportunity name should not be null.');
            System.assertEquals('Specified', opp.StageName, 'Opportunity stage should be Prospecting.'); // Modify this based on your logic
            // Add more assertions as needed based on your trigger logic
        }
    }
}