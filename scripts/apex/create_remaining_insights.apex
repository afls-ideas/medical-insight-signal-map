List<Medical_Insight__c> insightsToCreate = new List<Medical_Insight__c>();

// Record 1 (Formerly MI-003)
Medical_Insight__c insight1 = new Medical_Insight__c(
    Summary__c = 'Requests more comparative data in PsA',
    Detail__c = 'HCP2 inquired about Immunexis\' performance in psoriatic arthritis compared to IL-17 inhibitors. The HCP is currently hesitant to switch stable patients due to limited real-world evidence. He would consider Immunexis if head-to-head trial data becomes available.',
    Sentiment__c = 'Neutral',
    Topic__c = 'Comparative Data',
    Therapeutic_Area__c = 'Rheumatology',
    Date__c = Date.newInstance(2025, 6, 12),
    Account__c = '001YH000000MLm9YAG',
    Captured_By__c = '005YH0000001GVmYAM',
    Source_Type__c = '1:1 Visit',
    Follow_Up__c = true
);
insightsToCreate.add(insight1);

// Record 2 (Formerly MI-008)
Medical_Insight__c insight2 = new Medical_Insight__c(
    Summary__c = 'Asks about use in patients with multiple autoimmune conditions',
    Detail__c = 'HCP5 asked whether Immunexis has shown benefit in patients with comorbid autoimmune conditions like UC or Hashimoto\'s. He speculated on its mechanism being adaptable beyond a single pathway, but remains cautious about off-label potential.',
    Sentiment__c = 'Neutral',
    Topic__c = 'Multi-Indication Interest',
    Therapeutic_Area__c = 'Immunology',
    Date__c = Date.newInstance(2025, 6, 10),
    Account__c = '001YH000000MLmGYAW',
    Captured_By__c = '005YH0000001GVpYAM',
    Source_Type__c = 'Advisory Board',
    Follow_Up__c = false
);
insightsToCreate.add(insight2);

try {
    insert insightsToCreate;
    System.debug(insightsToCreate.size() + ' records inserted successfully.');
} catch (Exception e) {
    System.debug('Error inserting records: ' + e.getMessage());
} 