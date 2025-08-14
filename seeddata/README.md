# Medical Insight Demo Data

This folder contains demo data for the Medical Insight Signal Map visualization.

## Files

- `medical_insights_demo.json` - JSON format demo data
- `medical_insights_demo.csv` - CSV format demo data (recommended for loading)
- `load_demo_data.js` - Node.js script to display data summary
- `README.md` - This file

## Demo Data Overview

The demo data includes 8 medical insights across 5 HCPs (HCP1-HCP5) with varying sentiments and topics:

### HCPs
- **HCP1**: Positive sentiment, focused on efficacy and early intervention
- **HCP2**: Neutral sentiment, interested in comparative data and real-world evidence
- **HCP3**: Negative sentiment, concerned about mechanism and immunogenicity
- **HCP4**: Positive sentiment, focused on quality of life outcomes
- **HCP5**: Neutral sentiment, interested in multi-indication potential

### Topics Covered
- Efficacy in Refractory RA
- Early Intervention Potential
- Comparative Data
- Real-World Evidence
- Mechanism Doubts
- Immunogenicity
- Quality of Life
- Multi-Indication Interest

### Therapeutic Areas
- Rheumatology
- Dermatology
- Immunology

## Loading Instructions

### Prerequisites
1. Ensure Account records exist with names: HCP1, HCP2, HCP3, HCP4, HCP5
2. Ensure Product2 record exists with name: Immunexis
3. Ensure User records exist with IDs: 005MSL001, 005MSL002, 005MSL003, 005MSL004
4. Make sure you're connected to the correct Salesforce org

### Method 1: Salesforce CLI (Recommended)
```bash
# Load data using upsert with Name as external ID
sf data upsert --sobjecttype Medical_Insight__c --file seeddata/medical_insights_demo.csv --external-id-field Name
```

### Method 2: Data Import Wizard
1. Go to Setup > Data Import Wizard
2. Select "Medical_Insight__c" as the object
3. Upload the CSV file
4. Map fields appropriately
5. Review and import

### Method 3: Workbench
1. Go to Workbench
2. Select "Data" > "Insert"
3. Choose "Medical_Insight__c"
4. Upload the CSV file
5. Execute the insert

### Method 4: Apex Data Loader
1. Open Data Loader
2. Select "Insert" operation
3. Choose "Medical_Insight__c" object
4. Select the CSV file
5. Map fields and execute

## Data Structure

Each record includes:
- **Name**: Auto-numbered identifier (MI-001 to MI-008)
- **Summary__c**: Brief insight summary
- **Detail__c**: Detailed insight description
- **Sentiment__c**: Positive, Neutral, or Negative
- **Topic__c**: Insight topic/category
- **Product__c**: Product name (Immunexis)
- **Therapeutic_Area__c**: Medical specialty
- **Date__c**: Date of insight capture
- **Account__c**: HCP name
- **Captured_By__c**: User ID who captured the insight
- **Source_Type__c**: How the insight was captured (1:1 Visit, Congress, Advisory Board)
- **Follow_Up__c**: Boolean flag for follow-up required

## Expected Graph Visualization

Once loaded, the Medical Insight Signal Map will display:
- **5 HCP nodes** with different sentiment colors
- **8 topic nodes** representing insight themes
- **1 product node** (Immunexis)
- **Connections** showing relationships between HCPs, topics, and products
- **Interactive features** including filtering, tooltips, and navigation

## Troubleshooting

### Common Issues
1. **Account not found**: Ensure Account records exist with exact names (HCP1, HCP2, etc.)
2. **Product not found**: Ensure Product2 record exists with name "Immunexis"
3. **User not found**: Ensure User records exist with the specified IDs
4. **Field validation errors**: Check that all required fields are populated

### Validation Commands
```bash
# Check if org is connected
sf org display

# List Account records
sf data query --query "SELECT Id, Name FROM Account WHERE Name IN ('HCP1', 'HCP2', 'HCP3', 'HCP4', 'HCP5')"

# List Product2 records
sf data query --query "SELECT Id, Name FROM Product2 WHERE Name = 'Immunexis'"
``` 