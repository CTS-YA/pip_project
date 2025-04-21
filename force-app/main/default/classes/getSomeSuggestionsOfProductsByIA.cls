public class getSomeSuggestionsOfProductsByIA {
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getSomeSuggestionsOfProductsByIA( String leadId) {
        String response;
        System.debug('leadId'+ leadId);
         // Create a Map to represent the Lead's properties
         Map<String, Object> leadProperties = new Map<String, Object>();
         leadProperties.put('id', leadId);
 
         // Wrap the leadProperties in a WrappedValue
         ConnectApi.WrappedValue inputValueMapLead = new ConnectApi.WrappedValue();
         inputValueMapLead.value = leadProperties;

        // Add Prompt input variables to a Map
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();        
        inputParams.put('Input:Lead', inputValueMapLead);
        System.debug('Input Parameters: ' + inputParams);

        // Invoke the Prompt 
       
             response = PromptUtils.invokePrompt('RETURN_lead_with_suggested_information', inputParams);

       
        // Convert the JSON response to a Map<String, String>
        Map<String, Object> resultMap = new Map<String, Object>();
        if (response != null) {
            System.debug('secondResultResponse: ' + response );
            System.debug('resultResponse' + extractJsonResponse(response));
            //resultMap.put('result', response);')
            // Parse the JSON response
            try {
                // Attempt to deserialize the JSON response
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
                for (String key : jsonResponse.keySet()) {
                    Object value = jsonResponse.get(key);
                    if (value != null) {
                        resultMap.put(key, value); // Ensure all values are strings
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