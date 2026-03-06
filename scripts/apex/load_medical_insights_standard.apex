// Load Medical Insights demo data into standard MedicalInsight object
// Maps HCP1-5 to real HCPs in Evan Casto's territory (260-test org)
// Also creates MedicalInsightAccount junctions and MedicalInsightProduct links

// ===== HCP Mapping (Evan Casto's territory accounts) =====
Map<String, Id> hcpMap = new Map<String, Id>{
    'HCP1' => '001Ws00005GNtBuIAL', // Aaron Morita
    'HCP2' => '001Ws00005GNtBtIAL', // Abhinav Sinha
    'HCP3' => '001Ws00005GNtBvIAL', // Peter Neale
    'HCP4' => '001Ws00005GNtBwIAL', // Thomas Dorsch
    'HCP5' => '001Ws00005GNtC0IAL'  // Mangala Yeturu
};

// ===== Product: Immunexis 10mg =====
Id immunexisId = '01tWs00000CabBqIAJ';

// ===== Source Type Mapping =====
Map<String, String> sourceTypeMap = new Map<String, String>{
    '1:1 Visit'       => 'Visit',
    'Congress'         => 'Meeting',
    'Advisory Board'   => 'Meeting',
    'Conference'       => 'Meeting',
    'Phone Call'       => 'Account',
    'Email'            => 'Account',
    'Literature Review' => 'MedicalInsightsTab',
    'Other'            => 'MedicalInsightsTab'
};

// ===== Build MedicalInsight records =====
List<MedicalInsight> insights = new List<MedicalInsight>();
List<String> hcpKeys = new List<String>();

// Record 1: HCP1 - Efficacy in Refractory RA
MedicalInsight mi1 = new MedicalInsight();
mi1.Name = 'Favorable response in RA patients unresponsive to prior DMARDs';
mi1.Content = 'HCP1 has observed that patients with long-standing RA who previously failed multiple DMARDs have shown clinical improvement within the first 6–8 weeks on Immunexis. Improvements were noted in DAS28 scores, morning stiffness duration, and patient fatigue. HCP1 is optimistic about its role in refractory cases.';
mi1.Sentiment__c = 'Positive';
mi1.TopicNames = 'Efficacy in Refractory RA';
mi1.SourceType = 'Visit';
insights.add(mi1);
hcpKeys.add('HCP1');

// Record 2: HCP1 - Early Intervention Potential
MedicalInsight mi2 = new MedicalInsight();
mi2.Name = 'Interest in early use of Immunexis in undifferentiated arthritis';
mi2.Content = 'HCP1 has expressed interest in exploring Immunexis earlier in the treatment algorithm, especially for patients with undifferentiated arthritis showing aggressive onset. The HCP questions whether initiating Immunexis prior to conventional biologics may prevent long-term joint damage and disability.';
mi2.Sentiment__c = 'Positive';
mi2.TopicNames = 'Early Intervention Potential';
mi2.SourceType = 'Meeting';
insights.add(mi2);
hcpKeys.add('HCP1');

// Record 3: HCP2 - Comparative Data
MedicalInsight mi3 = new MedicalInsight();
mi3.Name = 'Requests more comparative data in PsA';
mi3.Content = 'HCP2 inquired about Immunexis\' performance in psoriatic arthritis compared to IL-17 inhibitors. The HCP is currently hesitant to switch stable patients due to limited real-world evidence. He would consider Immunexis if head-to-head trial data becomes available.';
mi3.Sentiment__c = 'Neutral';
mi3.TopicNames = 'Comparative Data';
mi3.SourceType = 'Visit';
insights.add(mi3);
hcpKeys.add('HCP2');

// Record 4: HCP2 - Real-World Evidence
MedicalInsight mi4 = new MedicalInsight();
mi4.Name = 'Wants real-world outcomes before adoption in clinical practice';
mi4.Content = 'HCP2 emphasized the need for long-term observational studies before incorporating Immunexis into standard treatment. He is skeptical about relying solely on controlled trial data and is awaiting registry outcomes on durability and adverse event profile.';
mi4.Sentiment__c = 'Neutral';
mi4.TopicNames = 'Real-World Evidence';
mi4.SourceType = 'Visit';
insights.add(mi4);
hcpKeys.add('HCP2');

// Record 5: HCP3 - Mechanism Doubts
MedicalInsight mi5 = new MedicalInsight();
mi5.Name = 'Unconvinced by MOA claims for Immunexis';
mi5.Content = 'HCP3 stated that while the MOA for Immunexis appears novel, the lack of correlation between biomarker suppression and sustained remission leaves him unconvinced. He would like to see mechanistic studies with translational endpoints that support its clinical value.';
mi5.Sentiment__c = 'Negative';
mi5.TopicNames = 'Mechanism Doubts';
mi5.SourceType = 'Meeting';
insights.add(mi5);
hcpKeys.add('HCP3');

// Record 6: HCP3 - Immunogenicity
MedicalInsight mi6 = new MedicalInsight();
mi6.Name = 'Concerns about immunogenicity beyond one year';
mi6.Content = 'HCP3 expressed concerns regarding potential anti-drug antibody formation with prolonged Immunexis use. The HCP noted that loss of efficacy in Year 2 could point to delayed immunogenicity not captured in pivotal trials. She is looking for registry safety updates.';
mi6.Sentiment__c = 'Negative';
mi6.TopicNames = 'Immunogenicity';
mi6.SourceType = 'Meeting';
insights.add(mi6);
hcpKeys.add('HCP3');

// Record 7: HCP4 - Quality of Life
MedicalInsight mi7 = new MedicalInsight();
mi7.Name = 'Sees promise in patient-reported outcomes';
mi7.Content = 'HCP4 highlighted significant improvements in fatigue and functional ability among her patients treated with Immunexis. She believes PROMIS-Fatigue scores offer a useful complement to lab endpoints and should be integrated into ongoing monitoring.';
mi7.Sentiment__c = 'Positive';
mi7.TopicNames = 'Quality of Life';
mi7.SourceType = 'Visit';
insights.add(mi7);
hcpKeys.add('HCP4');

// Record 8: HCP5 - Multi-Indication Interest
MedicalInsight mi8 = new MedicalInsight();
mi8.Name = 'Asks about use in patients with multiple autoimmune conditions';
mi8.Content = 'HCP5 asked whether Immunexis has shown benefit in patients with comorbid autoimmune conditions like UC or Hashimoto\'s. He speculated on its mechanism being adaptable beyond a single pathway, but remains cautious about off-label potential.';
mi8.Sentiment__c = 'Neutral';
mi8.TopicNames = 'Multi-Indication Interest';
mi8.SourceType = 'Meeting';
insights.add(mi8);
hcpKeys.add('HCP5');

// ===== Insert MedicalInsight records =====
insert insights;
System.debug('Inserted ' + insights.size() + ' MedicalInsight records');

// ===== Create MedicalInsightAccount junction records =====
List<MedicalInsightAccount> junctions = new List<MedicalInsightAccount>();
for (Integer i = 0; i < insights.size(); i++) {
    MedicalInsightAccount mia = new MedicalInsightAccount();
    mia.MedicalInsightId = insights[i].Id;
    mia.AccountId = hcpMap.get(hcpKeys[i]);
    junctions.add(mia);
}
insert junctions;
System.debug('Inserted ' + junctions.size() + ' MedicalInsightAccount junction records');

// ===== Create MedicalInsightProduct records =====
List<MedicalInsightProduct> products = new List<MedicalInsightProduct>();
for (MedicalInsight mi : insights) {
    MedicalInsightProduct mip = new MedicalInsightProduct();
    mip.MedicalInsightId = mi.Id;
    mip.ProductId = immunexisId;
    products.add(mip);
}
insert products;
System.debug('Inserted ' + products.size() + ' MedicalInsightProduct records');

System.debug('=== DATA LOAD COMPLETE ===');
System.debug('MedicalInsight records: ' + insights.size());
System.debug('MedicalInsightAccount junctions: ' + junctions.size());
System.debug('MedicalInsightProduct links: ' + products.size());
