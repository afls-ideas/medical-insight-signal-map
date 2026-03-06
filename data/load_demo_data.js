#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read the demo data
const demoDataPath = path.join(__dirname, 'medical_insights_demo.json');
const demoData = JSON.parse(fs.readFileSync(demoDataPath, 'utf8'));

console.log('🎯 Medical Insight Demo Data Loader');
console.log('=====================================\n');

console.log('📊 Demo Data Summary:');
console.log(`- Total Insights: ${demoData.length}`);
console.log('- HCPs: HCP1, HCP2, HCP3, HCP4, HCP5');
console.log('- Product: Immunexis');
console.log('- Therapeutic Areas: Rheumatology, Dermatology, Immunology');
console.log('- Sentiments: Positive, Neutral, Negative');
console.log('- Topics: Efficacy in Refractory RA, Early Intervention Potential, Comparative Data, Real-World Evidence, Mechanism Doubts, Immunogenicity, Quality of Life, Multi-Indication Interest\n');

console.log('📋 Prerequisites:');
console.log('1. Ensure you have Account records with names: HCP1, HCP2, HCP3, HCP4, HCP5');
console.log('2. Ensure you have a Product2 record with name: Immunexis');
console.log('3. Ensure you have User records with IDs: 005MSL001, 005MSL002, 005MSL003, 005MSL004');
console.log('4. Make sure you are connected to the correct Salesforce org\n');

console.log('🚀 To load this data, you can:');
console.log('1. Use Salesforce Data Import Wizard');
console.log('2. Use Salesforce CLI data commands');
console.log('3. Use Apex Data Loader');
console.log('4. Use Workbench\n');

console.log('📝 Sample Salesforce CLI command:');
console.log('sf data upsert --sobjecttype Medical_Insight__c --file seeddata/medical_insights_demo.csv --external-id-field Name\n');

console.log('📄 Data Structure:');
demoData.forEach((insight, index) => {
    console.log(`\n${index + 1}. ${insight.Summary__c}`);
    console.log(`   HCP: ${insight.Account__c}`);
    console.log(`   Sentiment: ${insight.Sentiment__c}`);
    console.log(`   Topic: ${insight.Topic__c}`);
    console.log(`   Therapeutic Area: ${insight.Therapeutic_Area__c}`);
    console.log(`   Date: ${insight.Date__c}`);
});

console.log('\n✨ This demo data will create a rich network graph showing:');
console.log('- 5 HCPs with varying sentiment profiles');
console.log('- 8 different insight themes');
console.log('- Cross-therapeutic area insights');
console.log('- Multiple source types (1:1 Visit, Congress, Advisory Board)');
console.log('- Follow-up flags for action items'); 