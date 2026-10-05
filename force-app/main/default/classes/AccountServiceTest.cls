@IsTest
private class AccountServiceTest {
    private static final Integer BULK_SIZE = 200;

    // Account at position i gets 0, 1 or 2 contacts
    private static Integer expectedContactCount(Integer index) {
        return Math.mod(index, 3);
    }

    private static List<Account> createAccountsWithContacts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            accounts.add(new Account(Name = 'Bulk Account ' + i));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            for (Integer j = 0; j < expectedContactCount(i); j++) {
                contacts.add(
                    new Contact(
                        FirstName = 'Test' + j,
                        LastName = 'Contact ' + i,
                        AccountId = accounts[i].Id
                    )
                );
            }
        }
        insert contacts;

        return accounts;
    }

    @IsTest
    static void returnsContactsForBulkAccounts() {
        List<Account> accounts = createAccountsWithContacts();
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

        Test.startTest();
        Map<Id, List<Contact>> result = AccountService.getContactsByAccountId(
            accountIds
        );
        Integer queriesUsed = Limits.getQueries();
        Test.stopTest();

        Assert.areEqual(1, queriesUsed, 'Should use exactly one SOQL query');
        Assert.areEqual(
            BULK_SIZE,
            result.size(),
            'Every requested account should be in the map'
        );

        Integer totalContacts = 0;
        for (Integer i = 0; i < BULK_SIZE; i++) {
            List<Contact> accountContacts = result.get(accounts[i].Id);
            Assert.isNotNull(
                accountContacts,
                'Account ' + i + ' should have a list, even if empty'
            );
            Assert.areEqual(
                expectedContactCount(i),
                accountContacts.size(),
                'Wrong contact count for account ' + i
            );
            for (Contact contactRecord : accountContacts) {
                Assert.areEqual(
                    accounts[i].Id,
                    contactRecord.AccountId,
                    'Contact is grouped under the wrong account'
                );
            }
            totalContacts += accountContacts.size();
        }
        Assert.areEqual(
            [SELECT COUNT() FROM Contact],
            totalContacts,
            'Total contacts returned should match contacts created'
        );
    }

    @IsTest
    static void returnsEmptyMapForEmptySet() {
        Test.startTest();
        Map<Id, List<Contact>> result = AccountService.getContactsByAccountId(
            new Set<Id>()
        );
        Integer queriesUsed = Limits.getQueries();
        Test.stopTest();

        Assert.isNotNull(result, 'Should return a map, not null');
        Assert.areEqual(0, result.size(), 'Map should be empty');
        Assert.areEqual(0, queriesUsed, 'Should not run a query');
    }

    @IsTest
    static void returnsEmptyMapForNullSet() {
        Test.startTest();
        Map<Id, List<Contact>> result = AccountService.getContactsByAccountId(
            null
        );
        Test.stopTest();

        Assert.isNotNull(result, 'Should return a map, not null');
        Assert.areEqual(0, result.size(), 'Map should be empty');
    }
}
