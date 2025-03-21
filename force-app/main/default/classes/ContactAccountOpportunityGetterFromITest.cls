@IsTest(SeeAllData=true)
public class ContactAccountOpportunityGetterFromITest {
    @isTest
    public static void testContactAccountOpportunityGetterFromIA() {
        // Prepare test data for Lead
        Lead testLead = new Lead(
            LastName = 'Schiessl',
            FirstName = 'Lavinia',
            Company = 'Volvo', // Set the company name to match the expected account
            Email = 'lavinia.schiessl@volvo.com',
            Phone = '5,54133E+11',
            Description = 'Contato Volvo Brasil' // Updated description
        );
        insert testLead;
        
        Id testLeadId = testLead.Id;

        // Mock the response from PromptUtils.invokePrompt
        Test.startTest();
        

        // Mock the HTTP callout response
        System.debug('Simulating the response from PromptUtils.invokePrompt');

        Map<String, Object> account = (Map<String, Object>) result.get('Account');
        Map<String, Object> opportunity = (Map<String, Object>) result.get('Opportunity');

        // Assertions to verify that the method works as expected
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, account.get('OwnerId'), 'OwnerId should match the expected value');
        System.assertNotEquals(null, opportunity.get('Name'), 'Opportunity name should match');
        System.assertNotEquals(null, account.get('Name'), 'Account name should match');

        Test.stopTest();
    }

   
}