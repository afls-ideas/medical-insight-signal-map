const fs = require('fs');
const { execSync } = require('child_process');

const jsonData = JSON.parse(fs.readFileSync('new_medical_insights.json', 'utf8'));
const records = jsonData.result.records;

const org = 'pm3-june';
let successCount = 0;
let errorCount = 0;

for (const record of records) {
    // Prepare CLI values string (skip Name)
    const values = [
        `Summary__c='${record.Summary__c?.replace(/'/g, "''") || ''}'`,
        `Detail__c='${record.Detail__c?.replace(/'/g, "''") || ''}'`,
        `Topic__c='${record.Topic__c?.replace(/'/g, "''") || ''}'`,
        `Date__c=${record.Date__c || ''}`,
        `Account__c=${record.Account__c || ''}`,
        `Source_Type__c='${record.Source_Type__c ? record.Source_Type__c.replace(/'/g, "''") : '1:1 Visit'}'`,
        `Sentiment__c='${record.Sentiment__c?.replace(/'/g, "''") || ''}'`,
        `Follow_Up__c=${record.Follow_Up__c === true ? 'true' : 'false'}`
    ].join(' ');

    const cmd = `sf data record create --sobject Medical_Insight__c --values "${values}" --target-org ${org}`;
    try {
        const output = execSync(cmd, { stdio: 'pipe' }).toString();
        console.log(`SUCCESS: ${record.Summary__c}`);
        successCount++;
    } catch (err) {
        console.error(`ERROR: ${record.Summary__c}`);
        if (err.stdout) console.error(err.stdout.toString());
        if (err.stderr) console.error(err.stderr.toString());
        errorCount++;
    }
}

console.log(`\nInserted ${successCount} records, ${errorCount} errors.`); 