public with sharing class CreateOpportunityUsingIA {

    public static void handleOpportunityCreation(List<Lead> newLeads) {
        Set<Id> setLeads = new Set<Id>();
        for (Lead lead : newLeads) {
            setLeads.add(lead.Id);
        }

        // Create lists for Accounts, Contacts, Opportunities, and OpportunityLineItems to insert in bulk
        List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItemsToInsert = new List<OpportunityLineItem>();

        // Fetch PricebookEntry Ids once for all ProductIds in the Leads
        Map<String, Id> productToPricebookEntryId = new Map<String, Id>();
        Set<String> productIds = new Set<String>();

        for (Lead lead : newLeads) {
            String productId = getFoundProductIdByIA.getFoundProductIdByIA(lead.Id);
            if (productId != null) {
                productIds.add(productId);
            }
        }

        // Bulk query PricebookEntry for all ProductIds
        if (!productIds.isEmpty()) {
            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds];
            for (PricebookEntry pbe : pricebookEntries) {
                productToPricebookEntryId.put(pbe.Product2Id, pbe.Id);
            }
        }

        // Prepare to keep track of created accounts
        Map<String, Account> existingAccounts = new Map<String, Account>();
        
        // Process each Lead
        for (Lead lead : newLeads) {
            Map<String, Object> jsonResponse = ContactAccountOpportunityGetterFromIA.ContactAccountOpportunityGetterFromIA(lead.Id);
            String productId = getFoundProductIdByIA.getFoundProductIdByIA(lead.Id);

            // Extract data
            Map<String, Object> contactData = (Map<String, Object>) jsonResponse.get('Contact');
            Map<String, Object> accountData = (Map<String, Object>) jsonResponse.get('Account');
            Map<String, Object> opportunityData = (Map<String, Object>) jsonResponse.get('Opportunity');

            // Create or retrieve Account
            if (accountData != null) {
                String accountName = (String) accountData.get('Name');
                Account accountToInsert;

                // Check if account already exists
                if (existingAccounts.containsKey(accountName)) {
                    accountToInsert = existingAccounts.get(accountName);
                } else {
                    accountToInsert = new Account();
                    accountToInsert.Name = accountName;
                    accountToInsert.OwnerId = (String) accountData.get('OwnerId');
                    accountToInsert.Description = (String) accountData.get('Description');
                    accountsToInsert.add(accountToInsert);
                    existingAccounts.put(accountName, accountToInsert);
                }
            }

            // Create Contact
            if (contactData != null) {
                System.debug('contactData: '+contactData);
                Contact newContact = new Contact(

                    LastName = (String) contactData.get('LastName'),
                    FirstName = (String) contactData.get('FirstName'),
                    Title = (String) contactData.get('Title'),
                    Phone = (String) contactData.get('Phone'),
                    Email = (String) contactData.get('Email')
                );
                System.debug('contactData: firstName '+newContact.FirstName);
                contactsToInsert.add(newContact);
            }

            // Create Opportunity
            Opportunity newOpportunity = new Opportunity(
                StageName = 'Specified',
                Name = (String) opportunityData.get('Name'),
                Description = (String) opportunityData.get('Description'),
                CloseDate = transformStringToDate((String) opportunityData.get('CloseDate'))
            );
            opportunitiesToInsert.add(newOpportunity);

            // Create OpportunityLineItem
            if (productId != null && productToPricebookEntryId.containsKey(productId)) {
                OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                    Product2Id = productId,
                    Quantity = 1,
                    UnitPrice = 100.00,
                    PricebookEntryId = productToPricebookEntryId.get(productId)
                );
                opportunityLineItemsToInsert.add(opportunityLineItem);
            }
        }

        // Insert Accounts
        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert;
        }

        // Assign AccountId to Contacts
        for (Integer i = 0; i < contactsToInsert.size(); i++) {
            Contact contact = contactsToInsert[i];
            contact.AccountId = accountsToInsert[i].Id; // Match Account with its corresponding Contact
        }

        // Insert Contacts
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }

        // Assign AccountId to Opportunities
        for (Integer i = 0; i < opportunitiesToInsert.size(); i++) {
            Opportunity opportunity = opportunitiesToInsert[i];
            opportunity.AccountId = accountsToInsert[i].Id; // Match Account with its corresponding Opportunity
        }

        // Insert Opportunities
        if (!opportunitiesToInsert.isEmpty()) {
            insert opportunitiesToInsert;
        }

        // Insert OpportunityLineItems with the correct OpportunityId
        for (Integer i = 0; i < opportunityLineItemsToInsert.size(); i++) {
            OpportunityLineItem oli = opportunityLineItemsToInsert[i];
            Opportunity opp = opportunitiesToInsert[i]; // Match Opportunity with its corresponding OpportunityLineItem
            oli.OpportunityId = opp.Id;
        }

        // Now insert OpportunityLineItems
        if (!opportunityLineItemsToInsert.isEmpty()) {
            insert opportunityLineItemsToInsert;
        }
    }

    // Helper method to convert date string to Date object
    public static Date transformStringToDate(String dateString) {
        if (String.isBlank(dateString)) {
            return null;
        }
        List<String> dateParts = dateString.split('-');
        return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
    }
}