// Share all MedicalInsight records with a specified user
// Update the userId below to target a different user

// Evan Casto
Id userId = '005Ws000009jh6zIAA';

// 1. Share MedicalInsight records
List<MedicalInsight> insights = [SELECT Id FROM MedicalInsight];
List<SObject> insightShares = new List<SObject>();
for (MedicalInsight mi : insights) {
    SObject share = Schema.getGlobalDescribe().get('MedicalInsightShare').newSObject();
    share.put('ParentId', mi.Id);
    share.put('UserOrGroupId', userId);
    share.put('AccessLevel', 'Read');
    insightShares.add(share);
}
if (!insightShares.isEmpty()) {
    Database.insert(insightShares, false);
    System.debug('Shared ' + insightShares.size() + ' MedicalInsight records');
}

// 2. Share Account records (HCPs) linked via MedicalInsightAccount
Set<Id> accountIds = new Set<Id>();
for (MedicalInsightAccount mia : [SELECT AccountId FROM MedicalInsightAccount WHERE AccountId != null]) {
    accountIds.add(mia.AccountId);
}
List<AccountShare> accountShares = new List<AccountShare>();
for (Id acctId : accountIds) {
    accountShares.add(new AccountShare(
        AccountId = acctId,
        UserOrGroupId = userId,
        AccountAccessLevel = 'Read',
        OpportunityAccessLevel = 'None'
    ));
}
if (!accountShares.isEmpty()) {
    Database.insert(accountShares, false);
    System.debug('Shared ' + accountShares.size() + ' Account records');
}

System.debug('Done. All MedicalInsight and related Account records shared with user: ' + userId);
