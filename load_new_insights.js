const fs = require('fs');
const { execSync } = require('child_process');

// Read the JSON file
const jsonData = JSON.parse(fs.readFileSync('new_medical_insights.json', 'utf8'));

// Extract only the required fields (no Name field)
const records = jsonData.result.records.map(record => ({
    Summary__c: record.Summary__c,
    Detail__c: record.Detail__c,
    Topic__c: record.Topic__c,
    Date__c: record.Date__c,
    Account__c: record.Account__c,
    Source_Type__c: record.Source_Type__c || '1:1 Visit', // Default value if null
    Sentiment__c: record.Sentiment__c, // Keep sentiment for the graph functionality
    Follow_Up__c: record.Follow_Up__c // Keep follow-up for completeness
}));

// Create CSV format for Salesforce CLI (no Name column)
const csvHeader = 'Summary__c,Detail__c,Topic__c,Date__c,Account__c,Source_Type__c,Sentiment__c,Follow_Up__c\n';
const csvRows = records.map(record => {
    // Escape quotes and handle null values
    const escapeCsv = (value) => {
        if (value === null || value === undefined) return '';
        return `"${String(value).replace(/"/g, '""')}"`;
    };
    
    return [
        escapeCsv(record.Summary__c),
        escapeCsv(record.Detail__c),
        escapeCsv(record.Topic__c),
        escapeCsv(record.Date__c),
        escapeCsv(record.Account__c),
        escapeCsv(record.Source_Type__c),
        escapeCsv(record.Sentiment__c),
        escapeCsv(record.Follow_Up__c)
    ].join(',');
}).join('\n');

const csvContent = csvHeader + csvRows;

// Write to CSV file
fs.writeFileSync('new_medical_insights.csv', csvContent);

console.log(`Processed ${records.length} records`);
console.log('CSV file created: new_medical_insights.csv');

// Display summary
const sentimentCounts = records.reduce((acc, record) => {
    const sentiment = record.Sentiment__c || 'Unknown';
    acc[sentiment] = (acc[sentiment] || 0) + 1;
    return acc;
}, {});

console.log('\nSentiment Distribution:');
Object.entries(sentimentCounts).forEach(([sentiment, count]) => {
    console.log(`  ${sentiment}: ${count}`);
});

// Display unique HCPs
const uniqueHCPs = [...new Set(records.map(r => r.Account__c))];
console.log(`\nUnique HCPs: ${uniqueHCPs.length}`);

// Display unique topics
const uniqueTopics = [...new Set(records.map(r => r.Topic__c))];
console.log(`\nUnique Topics: ${uniqueTopics.length}`);
console.log('Topics:', uniqueTopics.join(', '));

console.log('\nReady to load data. Run the following command to load:');
console.log('sf data import tree --sobjecttreefiles new_medical_insights.csv --target-org pm3-june'); 