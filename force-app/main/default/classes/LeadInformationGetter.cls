public class LeadInformationGetter {
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> leadInformationGetter( String leadId) {
                
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
        String response = PromptUtils.invokePrompt('extract_important_informations_from_lead', inputParams);

        // Convert the JSON response to a Map<String, String>
        Map<String, String> resultMap = new Map<String, String>();
        if (response != null) {
            // Parse the JSON response
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
            for (String key : jsonResponse.keySet()) {
                Object value = jsonResponse.get(key);
                if (value != null) {
                    resultMap.put(key, String.valueOf(value)); // Ensure all values are strings
                }
            }

        }
        System.debug('result' + resultMap);
        

        return resultMap;
    }
}