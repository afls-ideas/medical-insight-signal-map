const fs = require('fs');

// Read the updated data
const updatedData = JSON.parse(fs.readFileSync('force-app/main/default/data/medical_insights_updated.json', 'utf8'));

// Create a clean CSV version
const csvData = updatedData.map(record => ({
  Name: record.Name,
  Summary__c: record.Summary__c,
  Detail__c: record.Detail__c,
  Sentiment__c: record.Sentiment__c,
  Topic__c: record.Topic__c,
  Date__c: record.Date__c,
  Follow_Up__c: record.Follow_Up__c,
  Relevance_Score__c: record.Relevance_Score__c,
  Therapeutic_Area__c: record.Therapeutic_Area__c,
  Source_Type__c: record.Source_Type__c,
  Account__c: record.Account__c
}));

// Convert to CSV format with proper escaping
const csvHeaders = Object.keys(csvData[0]).join(',');
const csvRows = csvData.map(record => 
  Object.values(record).map(value => {
    // Clean the value: remove line breaks and escape quotes
    const cleanValue = String(value)
      .replace(/\n/g, ' ')  // Replace newlines with spaces
      .replace(/\r/g, ' ')  // Replace carriage returns with spaces
      .replace(/"/g, '""'); // Escape quotes by doubling them
    
    // Wrap in quotes if it contains comma, quote, or newline
    if (cleanValue.includes(',') || cleanValue.includes('"') || cleanValue.includes('\n') || cleanValue.includes('\r')) {
      return `"${cleanValue}"`;
    }
    return cleanValue;
  }).join(',')
).join('\n');

const csvContent = csvHeaders + '\n' + csvRows;
fs.writeFileSync('force-app/main/default/data/medical_insights_clean.csv', csvContent);

console.log('Clean CSV version written to: force-app/main/default/data/medical_insights_clean.csv');
