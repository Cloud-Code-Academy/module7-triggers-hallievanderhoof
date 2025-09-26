public class OpportunityTriggerHandler {

    public static void validateAndSetPrimary(List<Opportunity> opps) {
        // First: validate amount > 5000
        for (Opportunity opp : opps) {
            // If null or less than or equal to 5000
            if (opp.Amount == null || opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }

        // Second: set primary contact to the CEO contact (if present)
        // Collect account IDs
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity opp : opps) {
            if (opp.AccountId != null) {
                acctIds.add(opp.AccountId);
            }
        }

        if (!acctIds.isEmpty()) {
            // Query CEO contacts for those accounts
            Map<Id, Contact> acctToCeo = new Map<Id, Contact>();
            for (Contact c : [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :acctIds
                  AND Title = 'CEO'
            ]) {
                // take the first CEO per account
                if (!acctToCeo.containsKey(c.AccountId)) {
                    acctToCeo.put(c.AccountId, c);
                }
            }

            // Assign to opp
            for (Opportunity opp : opps) {
                if (opp.AccountId != null && acctToCeo.containsKey(opp.AccountId)) {
                    opp.Primary_Contact__c = acctToCeo.get(opp.AccountId).Id;
                }
            }
        }
    }

    public static void preventClosedWonDelete(List<Opportunity> oppsOld) {
        // Collect account IDs for Closed Won opps
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity oldOpp : oppsOld) {
            if (oldOpp.StageName == 'Closed Won' && oldOpp.AccountId != null) {
                acctIds.add(oldOpp.AccountId);
            }
        }
        if (acctIds.isEmpty()) {
            return;
        }

        // Query those accounts whose Industry = 'Banking'
        Map<Id, Account> bankingAccts = new Map<Id, Account>();
        for (Account a : [
            SELECT Id, Industry
            FROM Account
            WHERE Id IN :acctIds
              AND Industry = 'Banking'
        ]) {
            bankingAccts.put(a.Id, a);
        }

        for (Opportunity oldOpp : oppsOld) {
            if (oldOpp.StageName == 'Closed Won'
                && oldOpp.AccountId != null
                && bankingAccts.containsKey(oldOpp.AccountId)) {
                oldOpp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}
