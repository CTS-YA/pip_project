public class TransformMailToLeadUsingIA {
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> TransformMailToLeadUsingIA( String caseId) {
                
         // Create a Map to represent the Lead's properties
         Map<String, Object> leadProperties = new Map<String, Object>();
         leadProperties.put('id', caseId);
 
         // Wrap the leadProperties in a WrappedValue
         ConnectApi.WrappedValue inputValueMapLead = new ConnectApi.WrappedValue();
         inputValueMapLead.value = leadProperties;

        // Add Prompt input variables to a Map
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();        
        inputParams.put('Input:case', inputValueMapLead);

        // Invoke the Prompt 
        String response = PromptUtils.invokePrompt('create_lead', inputParams);

        // Convert the JSON response to a Map<String, String>
        Map<String, String> resultMap = new Map<String, String>();
        if (response != null) {
            System.debug('secondResultResponse: ' + response );
            System.debug('resultResponse' + extractJsonResponse(response));
            //resultMap.put('result', response);')
            // Parse the JSON response
            try {
                // Attempt to deserialize the JSON response
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(extractJsonResponse(response));
                for (String key : jsonResponse.keySet()) {
                    Object value = jsonResponse.get(key);
                    if (value != null) {
                        resultMap.put(key, String.valueOf(value)); // Ensure all values are strings
                    }
                }
            } catch (Exception e) {
                // Handle the exception
                System.debug('response2'+ response + e.getMessage());
                // You can also throw a custom exception or handle it as needed
                
            }
            

        }
        System.debug('result' + resultMap);
        

        return resultMap;
    }

    public static String extractJsonResponse(String inputText) {
      // Regular expression to find the JSON response
    Pattern jsonPattern = Pattern.compile('\\{[^}]*\\}');
    Matcher jsonMatcher = jsonPattern.matcher(inputText);
    
    if (jsonMatcher.find()) {
        return jsonMatcher.group(0); // Return the first found JSON response
    }
    
    return null; // Return null if no JSON found
    }

    
}