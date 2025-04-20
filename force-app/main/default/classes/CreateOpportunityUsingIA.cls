public with sharing class CreateOpportunityUsingIA {
    @InvocableMethod(label='CreateOpportunityUsingIA' description='CreateOpportunityUsingIA')
    public static void handleOpportunityCreation(List<Lead> newLeads) {
        List<Case> caseTreatedToUpdate = new List<Case>();
        Case caseTreated= new Case();

        try {
            // Retrieve the first case in 'processing' status
            List<Case>casesTreated = [SELECT Id, Subject, Status, It_is_trated_with_IA__c 
                           FROM Case 
                           WHERE Id = '500Kc00000AML25IAH'
                           LIMIT 1];
             caseTreated = casesTreated[0];
            System.debug('caseTreated: ' + caseTreated);

            Set<Id> setLeads = new Set<Id>();
            for (Lead lead : newLeads) {
                setLeads.add(lead.Id);
            }

            // Create lists for Accounts, Contacts, Opportunities, and OpportunityLineItems to insert in bulk
            List<Lead> leadToUpdate = new List<Lead>();
            List<Account> accountsToInsert = new List<Account>();
            List<Contact> contactsToInsert = new List<Contact>();
            List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
            List<OpportunityLineItem> opportunityLineItemsToInsert = new List<OpportunityLineItem>();
            List<SBQQ__Quote__c> quotesToInsert = new List<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>(); // List for Quote Lines
            Map<OpportunityLineItem, Integer> counterOpportunityLineItem = new Map<OpportunityLineItem, Integer>();
            Map<SBQQ__QuoteLine__c, Integer> counterQuoteLine = new Map<SBQQ__QuoteLine__c, Integer>();
            

            // Get the Standard Pricebook Id
            Id standardPricebookId = Test.isRunningTest() ? 
                Test.getStandardPricebookId() : 
                [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

            // Fetch PricebookEntry Ids once for all ProductIds in the Leads
            Map<String, Id> productToPricebookEntryId = new Map<String, Id>();
            Set<String> productIds = new Set<String>(); // Use Set to avoid duplicates

            for (Lead lead : newLeads) {
                Map<String, String> leadInformation = LeadInformationGetter.leadInformationGetter(lead.Id);
                System.debug('leadLeadHello: ' + leadInformation);

                String productId = getFoundProductIdByIA.getFoundProductIdByIA(lead.Id, leadInformation);
                System.debug('productIdTest: ' + productId);

                List<String> ids = extractProductIds(productId);
                System.debug('productId: ' + productId);
                if (ids != null) {
                    productIds.addAll(ids); // Use Set to avoid duplicates
                    System.debug('ProductIds: ' + productIds);
                }
            }

            // Bulk query PricebookEntry for all ProductIds from the Standard Pricebook
            if (!productIds.isEmpty()) {
                List<PricebookEntry> pricebookEntries = [
                    SELECT Id, Product2Id 
                    FROM PricebookEntry 
                    WHERE Product2Id IN :productIds 
                    AND Pricebook2Id = :standardPricebookId
                ];
                for (PricebookEntry pbe : pricebookEntries) {
                    System.debug('PricebookEntry - Product2Id: ' + pbe.Product2Id + ', Id: ' + pbe.Id);
                    productToPricebookEntryId.put(pbe.Product2Id, pbe.Id);
                }
            }

            // Process each Lead
            for (Lead lead : newLeads) {
                System.debug('leadLead: ' + lead);
                Map<String, Object> jsonResponse = getContactAccountOpportunityFromIA(lead.Id);
                System.debug('helloResponse: ' + jsonResponse);
                Map<String, String> leadInformation = LeadInformationGetter.leadInformationGetter(lead.Id);
                System.debug('leadLeadHello: ' + leadInformation);
                List<String> productsIds = extractProductIds(getFoundProductIdByIA.getFoundProductIdByIA(lead.Id, leadInformation));
                System.debug('productsIds: ' + productsIds);

                // Extract data
                Map<String, Object> contactData = (Map<String, Object>) jsonResponse.get('Contact');
                Map<String, Object> accountData = (Map<String, Object>) jsonResponse.get('Account');
                Map<String, Object> opportunityData = (Map<String, Object>) jsonResponse.get('Opportunity');
            
                // Create or retrieve Account
                if (accountData != null) {
                    String accountName = (String) accountData.get('Name');
                    Account accountToInsert = new Account(
                        Name = accountName,
                        OwnerId = (String) accountData.get('OwnerId'),
                        Description = (String) accountData.get('Description')
                    );
                    accountsToInsert.add(accountToInsert);
                }
            
                // Create Contact
                if (contactData != null) {
                    System.debug('contactData: ' + contactData);
                    Contact newContact = new Contact(
                        FirstName = lead.FirstName,
                        LastName = lead.LastName,
                        Title = (String) contactData.get('Title'),
                        Phone = (String) contactData.get('Phone'),
                        Email = (String) contactData.get('Email')
                    );
                    
                    contactsToInsert.add(newContact);
                    leadToUpdate.add(lead);
                }
            
                // Create Opportunity with Pricebook2Id
                Opportunity newOpportunity = new Opportunity(
                    StageName = 'Specified',
                    Name = (String) opportunityData.get('Name'),
                    Description = (String) opportunityData.get('Description'),
                    CloseDate = transformStringToDate((String) opportunityData.get('CloseDate')),
                    OwnerId = lead.OwnerId,
                    Pricebook2Id = standardPricebookId // Assign the Pricebook
                );
                opportunitiesToInsert.add(newOpportunity);
            
                // Create OpportunityLineItems for each productId
                for (String productId : productsIds) {
                    if (productId != null && productToPricebookEntryId.containsKey(productId)) {
                        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                            Product2Id = productId,
                            Quantity = 1,
                            UnitPrice = 100.00,
                            PricebookEntryId = productToPricebookEntryId.get(productId)
                        );
                        counterOpportunityLineItem.put(opportunityLineItem, 0);
                        opportunityLineItemsToInsert.add(opportunityLineItem);
                    }

                    if (productId != null) {
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
                            SBQQ__Product__c = productId, // Assuming productId corresponds to SBQQ__Product__c
                            SBQQ__Quantity__c = 1         // Set the quantity as needed
                        );
                        quoteLinesToInsert.add(quoteLine);
                        counterQuoteLine.put(quoteLine, 0);
                    }
                }

                // Create Quote without PrimaryContact__c
                SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
                    Customer_EOP__c = transformStringToDate((String) opportunityData.get('CloseDate')),
                    Customer_SOP__c = transformStringToDate((String) opportunityData.get('CloseDate')),
                    Quote_Language__c = 'English',
                    KAM__c = lead.OwnerId,
                    OwnerId = lead.OwnerId
                );
                quotesToInsert.add(newQuote);
            }

            // Insert Accounts
            if (!accountsToInsert.isEmpty()) {
                insert accountsToInsert;
            }

            // Assign AccountId to Contacts
            for (Integer i = 0; i < contactsToInsert.size(); i++) {
                Contact contact = contactsToInsert[i];
                contact.AccountId = accountsToInsert[i].Id;
            }

            // Insert Contacts
            if (!contactsToInsert.isEmpty()) {
                insert contactsToInsert;
            }

            // Assign AccountId to Opportunities
            for (Integer i = 0; i < opportunitiesToInsert.size(); i++) {
                Opportunity opportunity = opportunitiesToInsert[i];
                opportunity.AccountId = accountsToInsert[i].Id;
            }

            // Insert Opportunities
            if (!opportunitiesToInsert.isEmpty()) {
                System.debug('opportunityToInsert: ' + opportunitiesToInsert);
                insert opportunitiesToInsert;
            }

            // Assign OpportunityId to OpportunityLineItems
            for (OpportunityLineItem oli : opportunityLineItemsToInsert) {
                Integer index = counterOpportunityLineItem.get(oli);
                oli.OpportunityId = opportunitiesToInsert[index].Id; // Use index directly
            }

            // Insert OpportunityLineItems
            if (!opportunityLineItemsToInsert.isEmpty()) {
                insert opportunityLineItemsToInsert;
            }

            // Manage Quotes and Quote Lines
            for (Integer i = 0; i < quotesToInsert.size(); i++) {
                SBQQ__Quote__c quote = quotesToInsert[i];
                quote.SBQQ__Opportunity2__c = opportunitiesToInsert[i].Id;
                quote.SBQQ__PrimaryContact__c = contactsToInsert[i].Id;
            }
            if (!quotesToInsert.isEmpty()) {
                insert quotesToInsert;
            }

            for (SBQQ__QuoteLine__c quoteLine : quoteLinesToInsert) {
                Integer index = counterQuoteLine.get(quoteLine);
                System.debug('teeeeest: ' + quotesToInsert[index].Id);
                quoteLine.SBQQ__Quote__c = quotesToInsert[index].Id;
            }

          

            System.debug('quoteLinesToInsert: ' + quoteLinesToInsert);
            if (!quoteLinesToInsert.isEmpty()) {
                insert quoteLinesToInsert;
            }
            caseTreated.It_is_trated_with_IA__c = 'treated';
            caseTreatedToUpdate.add(caseTreated);
            update caseTreatedToUpdate;

            
        } catch (Exception exception1) {
            System.debug('Exception: ' + exception1.getMessage());
            caseTreated.It_is_trated_with_IA__c = 'failed';
            System.debug('givenException'+exception1.getMessage().contains('Duplicate id in list'));
            if (exception1.getMessage().contains('Duplicate id in list')) {
            caseTreated.It_is_trated_with_IA__c = 'treated';

            }
            caseTreatedToUpdate.add(caseTreated);
            update caseTreatedToUpdate;

        }
    }

    // Helper method to convert date string to Date object
    public static Date transformStringToDate(String dateString) {
        if (String.isBlank(dateString) || dateString == '2021-12-01') {
            return null;
        }
        List<String> dateParts = dateString.split('-');
        return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
    }

    public static List<String> extractProductIds(String inputText) {
        if (String.isBlank(inputText)) {
            return new List<String>();
        }

        // Check if the input text length is 15 or 18 (Salesforce ID length)
        if (inputText.length() == 15 || inputText.length() == 18) {
            return new List<String>{inputText};
        }

        System.debug('inputText: ' + inputText);
        List<String> productIds = new List<String>();
        
        Pattern idPattern = Pattern.compile('\\b[a-zA-Z0-9]{15}(?:[a-zA-Z0-9]{3})?\\b');
        Matcher matcher = idPattern.matcher(inputText);
        
        System.debug('Pattern: ' + idPattern.pattern());
        
        while (matcher.find()) {
            System.debug('Found match: ' + matcher.group(0));
            productIds.add(matcher.group(0));
        }
        
        return productIds;
    }

    public static Map<String, Object> getContactAccountOpportunityFromIA(String leadId) {
        Map<String, Object> jsonResponse = null;
        Boolean success = false;
        Integer attempts = 0;

        while (!success && attempts < 2) {
            attempts++;
            try {
                // Attempt to call the method
                jsonResponse = ContactAccountOpportunityGetterFromIA.ContactAccountOpportunityGetterFromIA(leadId);
                // If the call is successful, set success to true
                success = true;
            } catch (Exception e) {
                System.debug('Attempt ' + attempts + ' failed: ' + e.getMessage());
            }
        }

        if (!success) {
            System.debug('Both attempts failed.');
            // Optionally, you can return an error state or null
            return null; // or handle the error state as needed
        }

        return jsonResponse; // Return the successful response
    }
}