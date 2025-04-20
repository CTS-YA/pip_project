public  class getFoundProductIdByIA {
    public static String  getFoundProductIdByIA(String leadId, Map<String, String> leadInformation) {
        // Create a Map to represent the Lead's properties
        Map<String, Object> leadProperties = new Map<String, Object>();
        
        String jsonString = JSON.serialize(leadInformation);

        // Wrap the leadProperties in a WrappedValue
        ConnectApi.WrappedValue inputValueMapLead = new ConnectApi.WrappedValue();
        inputValueMapLead.value = jsonString;

        // Add Prompt input variables to a Map
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();        
        inputParams.put('Input:userInstructions', inputValueMapLead);

        // Invoke the Prompt 
        String response = PromptUtils.invokePrompt('return_product', inputParams);

        System.debug('returnProductALL: '+ response);

        // Convert the JSON response to a Map<String, String>
       

        return response;
    }
}