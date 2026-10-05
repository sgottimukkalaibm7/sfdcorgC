public with sharing class AccountService {
    public static Map<Id, List<Contact>> getContactsByAccountId(
        Set<Id> accountIds
    ) {
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        if (accountIds == null || accountIds.isEmpty()) {
            return contactsByAccountId;
        }

        for (Id accountId : accountIds) {
            contactsByAccountId.put(accountId, new List<Contact>());
        }

        for (Contact contactRecord : [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY AccountId, LastName, FirstName
        ]) {
            contactsByAccountId.get(contactRecord.AccountId).add(contactRecord);
        }

        return contactsByAccountId;
    }
}
