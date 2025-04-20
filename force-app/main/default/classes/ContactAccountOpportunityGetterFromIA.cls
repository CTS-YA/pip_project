public  class ContactAccountOpportunityGetterFromIA {
public static Map<String, Object> ContactAccountOpportunityGetterFromIA(String leadId) {
        Lead leadRecord = [SELECT Id, FirstName, LastName, Email, Phone FROM Lead WHERE Id = :leadId LIMIT 1];
        System.debug('leadRecord:'+ leadRecord);
        // Create a Map to represent the Lead's properties
        Map<String, Object> leadProperties = new Map<String, Object>();
        leadProperties.put('id', leadId);

        // Wrap the leadProperties in a WrappedValue
        ConnectApi.WrappedValue inputValueMapLead = new ConnectApi.WrappedValue();
        inputValueMapLead.value = leadProperties;

        // Add Prompt input variables to a Map
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();        
        inputParams.put('Input:Lead', inputValueMapLead);

        // Invoke the Prompt 
        String response = PromptUtils.invokePrompt('fill_opportunity_by_lead_fields', inputParams);

        // Convert the JSON response to a Map<String, String>
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.debug('result' + jsonResponse);

        return jsonResponse;
    }
}


