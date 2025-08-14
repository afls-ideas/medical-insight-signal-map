const fs = require('fs');

// Create a mapping from the seed data account IDs to valid Novartis account IDs
// Based on the names in the seed data and available accounts

// Create a mapping from the seed data account IDs to valid Novartis account IDs
// Based on the names in the seed data and available accounts
const idMapping = {
  "001YH000000MLmAYAW": "001fio000001lY1AAI", // Dr. Morita -> Pat,Morita
  "001YH000000MLm9YAG": "001fio000001lY0AAI", // Dr. Sinha -> Abhinav,Sinha
  "001YH000000MyiHYAS": "001fio000001lY2AAI", // Dr. Johnson -> Peter,Neale (closest match)
  "001YH000000MyiHYAT": "001fio000001lY3AAI", // Dr. Dorsch -> Thomas,Dorsch
  "001YH000000MyiHYAU": "001fio000001lY4AAI", // Dr. Bisla -> Virendra,Bisla
  "001YH000000MyiHYAV": "001fio000001lY5AAI", // Dr. Malloy -> Mary,Malloy
  "001YH000000MyiHYAW": "001fio000001lY6AAI", // Dr. Oswald -> Myra,Oswald
  "001YH000000MyiHYAX": "001fio000001lY7AAI", // Dr. Yeturu -> Mangala,Yeturu
  "001YH000000MyiHYAY": "001fio000001lY8AAI", // Dr. Kumar -> Ashok,Kumar
  "001YH000000MyiHYAZ": "001fio000001lY9AAI", // Dr. Flacco -> Valerie,Flacco
  "001YH000000MyiHYA0": "001fio000001lYAAAY", // Dr. Shah -> Surendra,Shah
  "001YH000000MyiHYA1": "001fio000001lYBAAY", // Dr. Midha -> Sunita,Midha
  "001YH000000MyiHYA2": "001fio000001lYCAAY", // Dr. Gill -> Pavinder,Gill
  "001YH000000MyiHYA3": "001fio000001lYDAAY", // Dr. Shell -> Rachel,Shell
  "001YH000000MyiHYA4": "001fio000001lYEAAY", // Dr. Shahida -> Shubi Shahida,Shahida
  "001YH000000MyiHYA5": "001fio000001lYFAAY"  // Dr. Desai -> Shreyas,Desai
};

// Read the original seed data
const seedData = JSON.parse(fs.readFileSync('force-app/main/default/data/medical_insights_seed_data.json', 'utf8'));

// Update the account IDs
const updatedData = seedData.map(record => {
  const oldAccountId = record.Account__c;
  const newAccountId = idMapping[oldAccountId];
  
  if (newAccountId) {
    return {
      ...record,
      Account__c: newAccountId
    };
  } else {
    // If no mapping found, use a default account ID (first one with a name)
    console.log(`Warning: No mapping found for account ID ${oldAccountId}, using default`);
    return {
      ...record,
      Account__c: "001fio000001lY0AAI" // Default to Abhinav Sinha
    };
  }
});

// Write the updated data to a new file
fs.writeFileSync('force-app/main/default/data/medical_insights_updated.json', JSON.stringify(updatedData, null, 2));

console.log(`Updated ${updatedData.length} medical insight records with valid Novartis account IDs`);
console.log('Updated data written to: force-app/main/default/data/medical_insights_updated.json');

// Also create a CSV version for easier loading
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

// Convert to CSV format
const csvHeaders = Object.keys(csvData[0]).join(',');
const csvRows = csvData.map(record => 
  Object.values(record).map(value => 
    typeof value === 'string' && value.includes(',') ? `"${value}"` : value
  ).join(',')
).join('\n');

const csvContent = csvHeaders + '\n' + csvRows;
fs.writeFileSync('force-app/main/default/data/medical_insights_updated.csv', csvContent);

console.log('CSV version written to: force-app/main/default/data/medical_insights_updated.csv');
