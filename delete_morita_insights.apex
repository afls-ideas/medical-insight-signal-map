// Delete Pat Morita insights
List<Medical_Insight__c> insightsToDelete = [
    SELECT Id FROM Medical_Insight__c 
    WHERE Account__c = '001fio000001lY1AAI'
];

System.debug('Deleting ' + insightsToDelete.size() + ' insights');
delete insightsToDelete;
System.debug('Deletion completed');
