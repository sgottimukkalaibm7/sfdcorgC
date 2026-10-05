@IsTest
private class AccountContactCounterControllerTest {
  private static Account createAccount(String name, Integer contactCount) {
    Account acc = new Account(Name = name);
    insert acc;
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < contactCount; i++) {
      contacts.add(
        new Contact(LastName = name + ' Contact ' + i, AccountId = acc.Id)
      );
    }
    insert contacts;
    return acc;
  }

  @IsTest
  static void returnsContactCount() {
    Account acc = createAccount('With Contacts', 2);
    createAccount('Other Account', 3);

    Test.startTest();
    Integer count = AccountContactCounterController.getContactCount(acc.Id);
    Test.stopTest();

    Assert.areEqual(2, count, 'Should count only this account\'s contacts');
  }

  @IsTest
  static void returnsZeroWhenNoContacts() {
    Account acc = createAccount('No Contacts', 0);

    Test.startTest();
    Integer count = AccountContactCounterController.getContactCount(acc.Id);
    Test.stopTest();

    Assert.areEqual(0, count, 'Account without contacts should return 0');
  }

  @IsTest
  static void returnsZeroForNullIdWithoutQuery() {
    Test.startTest();
    Integer count = AccountContactCounterController.getContactCount(null);
    Integer queriesUsed = Limits.getQueries();
    Test.stopTest();

    Assert.areEqual(0, count, 'Null id should return 0');
    Assert.areEqual(0, queriesUsed, 'Should not run a query');
  }
}
