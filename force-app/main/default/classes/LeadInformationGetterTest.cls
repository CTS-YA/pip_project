@IsTest(SeeAllData=true)
public class LeadInformationGetterTest {
    
    @isTest
    static void testLeadInformationGetter() {
        // Prepare test data for a Lead
        Lead testLead = new Lead(
            LastName = 'abdedayem',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Phone = '1234567890',
            Description = 'Test description'
        );
        insert testLead;

        // Mocking the response from PromptUtils.invokePrompt
        Test.startTest();

        // Call the method under test
        Map<String, String> result = LeadInformationGetter.leadInformationGetter(testLead.Id);
        Test.stopTest();

        // Assertions to verify that the method works as expected
        System.assertNotEquals(null, result, 'Result should not be null');
           }

    // Mock class for HTTP responses
   
}