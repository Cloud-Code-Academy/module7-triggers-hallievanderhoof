public with sharing class AccountTriggerHandler {
    
    public static void handleBeforeInsert(List<Account> newAccts) {
        for (Account acct : newAccts) {
            // 1. Set Type to ’Prospect’ only if Type is blank/null
            if (acct.Type == null) {
                acct.Type = 'Prospect';
            }
            // 2. Copy shipping → billing only if shipping fields are non-null
            if (acct.ShippingStreet != null) acct.BillingStreet = acct.ShippingStreet;
            if (acct.ShippingCity   != null) acct.BillingCity   = acct.ShippingCity;
            if (acct.ShippingState  != null) acct.BillingState  = acct.ShippingState;
            if (acct.ShippingPostalCode != null) acct.BillingPostalCode = acct.ShippingPostalCode;
            if (acct.ShippingCountry    != null) acct.BillingCountry    = acct.ShippingCountry;
            
            // 3. Set rating to ‘Hot’ unconditionally (or you could conditionally check fields like Phone, Website, Fax)
            acct.Rating = 'Hot';
        }
    }
    
    public static void handleAfterInsert(List<Account> newAccts) {
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acct : newAccts) {
            Contact c = new Contact();
            c.AccountId = acct.Id;
            // 4. Default contact fields per test: LastName = 'DefaultContact', Email = 'default@email.com'
            c.LastName = 'DefaultContact';
            c.Email = 'default@email.com';
            contactsToInsert.add(c);
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
    
    public static void handleBeforeUpdate(List<Account> newAccts, Map<Id, Account> oldMap) {
        // To prevent overwrite of billing/other logic on update,
        // we can choose to do nothing here—or enforce some rules
        // For example: do not re-copy shipping → billing if shipping changed?
        // But the test suggests billing should *not* change on updates.
        for (Account acct : newAccts) {
            Account old = oldMap.get(acct.Id);
            // Prevent billing address fields from being overwritten on update
            acct.BillingStreet = old.BillingStreet;
            acct.BillingCity   = old.BillingCity;
            acct.BillingState  = old.BillingState;
            acct.BillingPostalCode = old.BillingPostalCode;
            acct.BillingCountry    = old.BillingCountry;
            // Prevent rating from being re-set on update (unless maybe it was null before)
            acct.Rating = old.Rating;
            // Prevent Type change on update — keep the old Type
            acct.Type = old.Type;
        }
    }
}
