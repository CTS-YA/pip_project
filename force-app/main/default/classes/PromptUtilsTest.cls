@isTest
public class PromptUtilsTest {

    @isTest
    public static void testInvokePrompt() {
        // Setup: Test input parameters
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue wrappedValue = new ConnectApi.WrappedValue();
        wrappedValue.value = 'Some input value';
        inputParams.put('Input:TestKey', wrappedValue);

        // Mock the behavior of the ConnectApi call by using the wrapper method
        Test.startTest();
        
        // Override the real call to ConnectApi with our mock
        Test.setMock(ConnectApiWrapper.class, 'generateMessagesForPromptTemplate', new ConnectApiWrapper.generateMessagesForPromptTemplate());

        // Call the method you are testing
        String result = PromptUtils.invokePrompt('test_prompt_template', inputParams);

        // Assertions
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assert(result.contains('This is a mocked response based on the prompt test_prompt_template'), 'The response should contain the mocked result');
        
        Test.stopTest();
    }
}
