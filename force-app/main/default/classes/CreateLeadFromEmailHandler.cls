global class CreateLeadFromEmailHandler implements Schedulable {

    public CreateLeadFromEmailHandler() {
        // Constructor
    }

    public void execute(SchedulableContext context) {
        List<Case> casesToUpdate = new List<Case>();
        List<Case> casesToTreat = [
            SELECT Id, Subject, Status, It_is_trated_with_IA__c 
            FROM Case 
            WHERE It_is_trated_with_IA__c = 'not treated'
            LIMIT 1
        ];
        Map<String, String> leadData;

        try {
            System.debug('hello');
            List<Lead> leads = new List<Lead>();
            List<Case> cases = new List<Case>();
            System.debug('cases' + casesToTreat);

            if (!casesToTreat.isEmpty()) {
                Case usedCase = casesToTreat[0];
                System.debug(usedCase);
                usedCase.It_is_trated_with_IA__c = 'processing';
                Update usedCase;

                // Extract lead data
                try {
                    leadData = TransformMailToLeadUsingIA.TransformMailToLeadUsingIA(usedCase.Id);
                } catch (Exception e) {
                    usedCase.It_is_trated_with_IA__c = 'failed';
                    Update usedCase;


                }
                
                System.debug('leadData' + leadData);

                Lead newLead = new Lead();
                List<String> lastNameList = leadData.get('FirstName').split(' ');
                List<String> firstNameList = leadData.get('LastName').split(' ');

                System.debug('lastNameList: ' + lastNameList);
                System.debug('firstNameList: ' + firstNameList);
                System.debug('leadData: ' + leadData);
                System.debug('FirstName: ' + leadData.get('FirstName'));

                // Define fields to set
                List<String> fields = new List<String>{
                    'FirstName', 'LastName', 'Company', 'Email', 
                    'Phone', 'Status', 'LeadSource', 'Industry', 
                    'Description', 'Street', 'City', 'State', 
                    'PostalCode', 'Country', 'Title'
                };

                // Verify and set values if they exist
                for (String field : fields) {
                    if (leadData.containsKey(field) && leadData.get(field) != null && leadData.get(field) != 'Unknown') {
                        newLead.put(field, leadData.get(field));
                    }
                }

                // Custom logic for setting names
                if (leadData.get('FirstName') == leadData.get('Title') && lastNameList.size() == 2) {
                    newLead.FirstName = lastNameList[0];
                    newLead.LastName = lastNameList[1];
                }

                if (lastNameList.size() == 4) {
                    newLead.FirstName = lastNameList[0];
                    newLead.LastName = lastNameList[1];
                    System.debug('leadData (4): ' + newLead);
                }

                if (firstNameList.size() == 2 && lastNameList.size() == 2) {
                    newLead.FirstName = lastNameList[0];
                    newLead.LastName = lastNameList[1];
                    System.debug('leadData (2, 2): ' + newLead);
                }

                if (firstNameList.size() == 2 && lastNameList.size() == 1) {
                    newLead.FirstName = firstNameList[0];
                    newLead.LastName = firstNameList[1];
                    System.debug('leadData (2, 1): ' + newLead);
                }

                if (firstNameList.size() == 1 && lastNameList.size() == 2) {
                    newLead.FirstName = lastNameList[0];
                    newLead.LastName = lastNameList[1];
                    System.debug('leadData (1, 2): ' + newLead);
                }

                if ((newLead.FirstName == 'Unknown' || newLead.FirstName == '') && lastNameList.size() == 2) {
                    System.debug('lastNameList: please ' + lastNameList);
                    newLead.FirstName = lastNameList[0];
                    newLead.LastName = lastNameList[1];
                    System.debug('leadData (Unknown): ' + newLead);
                }

                if (firstNameList.size() == 2 && lastNameList.isEmpty()) {
                    newLead.FirstName = firstNameList[0];
                    newLead.LastName = firstNameList[1];
                    System.debug('leadData (2, 0): ' + newLead);
                }

                System.debug('Final leadData: ' + newLead);
                leads.add(newLead);
                if (!casesToTreat.isEmpty()) {
                    casesToUpdate.add(usedCase);
                    update casesToUpdate;
                }

                // Insert the new leads
                if (!leads.isEmpty()) {
                    insert leads;
                    
                }
                usedCase.It_is_trated_with_IA__c = 'treated';
                Update usedCase;
               
                System.debug('casesList: ' + casesToTreat);

                // Prepare the next batch of cases
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            if (!casesToTreat.isEmpty()) {
                Case usedCase = casesToTreat[0];
                usedCase.It_is_trated_with_IA__c = 'failed';
                if (e.getMessage().contains('Duplicate id in list')) {
                    usedCase.It_is_trated_with_IA__c = 'treated';
        
                update usedCase; // Update the case to reflect failure
                }}
        }
    }
}