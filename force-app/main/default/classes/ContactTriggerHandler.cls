public with sharing class ContactTriggerHandler {

    public static void updateAccountContactCount(List<Contact> newContacts, List<Contact> oldContacts) {
        Set<Id> accountIds = new Set<Id>();

        // Collect Account IDs from new records (insert, update, undelete)
        if (newContacts != null) {
            for (Contact c : newContacts) {
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                }
            }
        }

        // Collect Account IDs from old records (update, delete)
        if (oldContacts != null) {
            for (Contact c : oldContacts) {
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                }
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Count contacts per Account
        Map<Id, Integer> contactCountByAccount = new Map<Id, Integer>();
        for (Id accId : accountIds) {
            contactCountByAccount.put(accId, 0);
        }

        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) total
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            contactCountByAccount.put(
                (Id) ar.get('AccountId'),
                (Integer) ar.get('total')
            );
        }

        // Update Accounts
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : contactCountByAccount.keySet()) {
            accountsToUpdate.add(new Account(
                Id = accId,
                Number_of_Contacts__c = contactCountByAccount.get(accId)
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
