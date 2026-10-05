public with sharing class AccountContactCounterController {
  @AuraEnabled(cacheable=true)
  public static Integer getContactCount(Id accountId) {
    if (accountId == null) {
      return 0;
    }
    List<Contact> contacts = AccountService.getContactsByAccountId(
        new Set<Id>{ accountId }
      )
      .get(accountId);
    return contacts == null ? 0 : contacts.size();
  }
}
