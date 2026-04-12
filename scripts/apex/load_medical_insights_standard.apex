// Load Medical Insights demo data into standard MedicalInsight object
// Maps HCP1-5 to real HCPs in Evan Casto's territory (260-test org)
// Creates MedicalInsightAccount junctions, MedicalInsightProduct links,
// and shared-theme insights that connect HCPs in the signal map

// ===== HCP Account IDs (Evan Casto's territory) =====
Id aaronId   = '001Ws00005GNtBuIAL'; // Aaron Smith
Id abhinavId = '001Ws00005GNtBtIAL'; // Abhinav Sinha
Id peterId   = '001Ws00005GNtBvIAL'; // Peter Neale
Id thomasId  = '001Ws00005GNtBwIAL'; // Thomas Dorsch
Id mangalaId = '001Ws00005GNtC0IAL'; // Mangala Yeturu

Map<String, Id> hcpMap = new Map<String, Id>{
    'HCP1' => aaronId,
    'HCP2' => abhinavId,
    'HCP3' => peterId,
    'HCP4' => thomasId,
    'HCP5' => mangalaId
};

// ===== Product: Immunexis 10mg =====
Id immunexisId = '01tWs00000CabBqIAJ';

// ============================================================
// PART 1: Core insights (8 records, one per HCP per topic)
// ============================================================
List<MedicalInsight> coreInsights = new List<MedicalInsight>();
List<String> coreHcpKeys = new List<String>();

// Record 1: HCP1 - Efficacy in Refractory RA
coreInsights.add(new MedicalInsight(
    Name = 'Favorable response in RA patients unresponsive to prior DMARDs',
    Content = 'HCP1 has observed that patients with long-standing RA who previously failed multiple DMARDs have shown clinical improvement within the first 6–8 weeks on Immunexis. Improvements were noted in DAS28 scores, morning stiffness duration, and patient fatigue. HCP1 is optimistic about its role in refractory cases.',
    Sentiment__c = 'Positive',
    TopicNames = 'Efficacy in Refractory RA',
    SourceType = 'Visit'
));
coreHcpKeys.add('HCP1');

// Record 2: HCP1 - Early Intervention Potential
coreInsights.add(new MedicalInsight(
    Name = 'Interest in early use of Immunexis in undifferentiated arthritis',
    Content = 'HCP1 has expressed interest in exploring Immunexis earlier in the treatment algorithm, especially for patients with undifferentiated arthritis showing aggressive onset. The HCP questions whether initiating Immunexis prior to conventional biologics may prevent long-term joint damage and disability.',
    Sentiment__c = 'Positive',
    TopicNames = 'Early Intervention Potential',
    SourceType = 'Meeting'
));
coreHcpKeys.add('HCP1');

// Record 3: HCP2 - Comparative Data
coreInsights.add(new MedicalInsight(
    Name = 'Requests more comparative data in PsA',
    Content = 'HCP2 inquired about Immunexis\' performance in psoriatic arthritis compared to IL-17 inhibitors. The HCP is currently hesitant to switch stable patients due to limited real-world evidence. He would consider Immunexis if head-to-head trial data becomes available.',
    Sentiment__c = 'Neutral',
    TopicNames = 'Comparative Data',
    SourceType = 'Visit'
));
coreHcpKeys.add('HCP2');

// Record 4: HCP2 - Real-World Evidence
coreInsights.add(new MedicalInsight(
    Name = 'Wants real-world outcomes before adoption in clinical practice',
    Content = 'HCP2 emphasized the need for long-term observational studies before incorporating Immunexis into standard treatment. He is skeptical about relying solely on controlled trial data and is awaiting registry outcomes on durability and adverse event profile.',
    Sentiment__c = 'Neutral',
    TopicNames = 'Real-World Evidence',
    SourceType = 'Visit'
));
coreHcpKeys.add('HCP2');

// Record 5: HCP3 - Mechanism Doubts
coreInsights.add(new MedicalInsight(
    Name = 'Unconvinced by MOA claims for Immunexis',
    Content = 'HCP3 stated that while the MOA for Immunexis appears novel, the lack of correlation between biomarker suppression and sustained remission leaves him unconvinced. He would like to see mechanistic studies with translational endpoints that support its clinical value.',
    Sentiment__c = 'Negative',
    TopicNames = 'Mechanism Doubts',
    SourceType = 'Meeting'
));
coreHcpKeys.add('HCP3');

// Record 6: HCP3 - Immunogenicity
coreInsights.add(new MedicalInsight(
    Name = 'Concerns about immunogenicity beyond one year',
    Content = 'HCP3 expressed concerns regarding potential anti-drug antibody formation with prolonged Immunexis use. The HCP noted that loss of efficacy in Year 2 could point to delayed immunogenicity not captured in pivotal trials. She is looking for registry safety updates.',
    Sentiment__c = 'Negative',
    TopicNames = 'Immunogenicity',
    SourceType = 'Meeting'
));
coreHcpKeys.add('HCP3');

// Record 7: HCP4 - Quality of Life
coreInsights.add(new MedicalInsight(
    Name = 'Sees promise in patient-reported outcomes',
    Content = 'HCP4 highlighted significant improvements in fatigue and functional ability among her patients treated with Immunexis. She believes PROMIS-Fatigue scores offer a useful complement to lab endpoints and should be integrated into ongoing monitoring.',
    Sentiment__c = 'Positive',
    TopicNames = 'Quality of Life',
    SourceType = 'Visit'
));
coreHcpKeys.add('HCP4');

// Record 8: HCP5 - Multi-Indication Interest
coreInsights.add(new MedicalInsight(
    Name = 'Asks about use in patients with multiple autoimmune conditions',
    Content = 'HCP5 asked whether Immunexis has shown benefit in patients with comorbid autoimmune conditions like UC or Hashimoto\'s. He speculated on its mechanism being adaptable beyond a single pathway, but remains cautious about off-label potential.',
    Sentiment__c = 'Neutral',
    TopicNames = 'Multi-Indication Interest',
    SourceType = 'Meeting'
));
coreHcpKeys.add('HCP5');

insert coreInsights;
System.debug('Inserted ' + coreInsights.size() + ' core MedicalInsight records');

// ===== Core: MedicalInsightAccount junctions =====
List<MedicalInsightAccount> coreJunctions = new List<MedicalInsightAccount>();
for (Integer i = 0; i < coreInsights.size(); i++) {
    coreJunctions.add(new MedicalInsightAccount(
        MedicalInsightId = coreInsights[i].Id,
        AccountId = hcpMap.get(coreHcpKeys[i])
    ));
}
insert coreJunctions;
System.debug('Inserted ' + coreJunctions.size() + ' core MedicalInsightAccount junctions');

// ===== Core: MedicalInsightProduct links =====
List<MedicalInsightProduct> coreProducts = new List<MedicalInsightProduct>();
for (MedicalInsight mi : coreInsights) {
    coreProducts.add(new MedicalInsightProduct(
        MedicalInsightId = mi.Id,
        ProductId = immunexisId
    ));
}
insert coreProducts;
System.debug('Inserted ' + coreProducts.size() + ' core MedicalInsightProduct links');

// ============================================================
// PART 2: Shared-theme insights (14 records connecting HCPs)
// ============================================================
List<MedicalInsight> sharedInsights = new List<MedicalInsight>();

// === EFFICACY IN REFRACTORY RA — shared by Abhinav, Thomas ===
sharedInsights.add(new MedicalInsight(
    Name = 'Abhinav notes sustained DAS28 improvement with Immunexis in refractory RA',
    Content = 'HCP reports that two refractory RA patients showed sustained DAS28 remission beyond 24 weeks on Immunexis, even after failing both JAK inhibitors and TNF agents. Describes this as the first durable response seen in these patients.',
    TopicNames = 'Efficacy in Refractory RA',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Thomas observes functional gains in refractory RA cohort',
    Content = 'HCP noted that refractory RA patients on Immunexis have demonstrated clinically meaningful improvements in grip strength and HAQ-DI scores. Believes the drug addresses a previously unmet need in this population.',
    TopicNames = 'Efficacy in Refractory RA',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));

// === REAL-WORLD EVIDENCE — shared by Peter, Mangala ===
sharedInsights.add(new MedicalInsight(
    Name = 'Peter demands registry data before recommending Immunexis broadly',
    Content = 'HCP is unwilling to prescribe Immunexis beyond trial-eligible patients until real-world registry data on 2-year outcomes are published. Expressed frustration at the gap between pivotal trial populations and his patient mix.',
    TopicNames = 'Real-World Evidence',
    Sentiment__c = 'Negative',
    SourceType = 'Visit'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Mangala calls for post-market surveillance studies',
    Content = 'HCP emphasized that her institution requires post-market surveillance data before formulary inclusion. She would champion Immunexis internally if real-world safety data from diverse populations were available.',
    TopicNames = 'Real-World Evidence',
    Sentiment__c = 'Neutral',
    SourceType = 'Meeting'
));

// === EARLY INTERVENTION POTENTIAL — shared by Thomas, Mangala ===
sharedInsights.add(new MedicalInsight(
    Name = 'Thomas advocates for early biologic use including Immunexis',
    Content = 'HCP believes the treat-to-target paradigm supports earlier use of targeted therapies like Immunexis. Cited recent EULAR updates and his own clinical experience showing that early aggressive treatment prevents erosive disease.',
    TopicNames = 'Early Intervention Potential',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Mangala questions early intervention without long-term safety data',
    Content = 'HCP is interested in Immunexis for early RA but cautious about using a newer agent before conventional DMARDs have been adequately trialed. Wants to see 5-year safety data before moving Immunexis up in her treatment algorithm.',
    TopicNames = 'Early Intervention Potential',
    Sentiment__c = 'Neutral',
    SourceType = 'Meeting'
));

// === COMPARATIVE DATA — shared by Aaron, Peter ===
sharedInsights.add(new MedicalInsight(
    Name = 'Aaron wants head-to-head data vs IL-6 inhibitors',
    Content = 'HCP asked specifically about comparisons between Immunexis and tocilizumab in seropositive RA. Noted that many of his patients have done well on IL-6 pathway and he needs a compelling reason to switch.',
    TopicNames = 'Comparative Data',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Peter skeptical without PsA comparative trial results',
    Content = 'HCP reiterated that without randomized head-to-head data against secukinumab in PsA, he cannot justify switching stable patients. Stated that anecdotal reports are insufficient for his evidence-based practice.',
    TopicNames = 'Comparative Data',
    Sentiment__c = 'Negative',
    SourceType = 'Meeting'
));

// === QUALITY OF LIFE — shared by Aaron, Mangala ===
sharedInsights.add(new MedicalInsight(
    Name = 'Aaron reports patients highlight fatigue improvement',
    Content = 'HCP shared that multiple patients have spontaneously reported reduced fatigue and improved sleep quality since starting Immunexis. Considers patient-reported outcomes critical for treatment adherence.',
    TopicNames = 'Quality of Life',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Mangala sees improvement in work productivity among Immunexis patients',
    Content = 'HCP noted that several patients on Immunexis have returned to full-time work or resumed daily activities they had abandoned. She views work productivity as an underutilized outcome measure.',
    TopicNames = 'Quality of Life',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));

// === IMMUNOGENICITY — shared by Abhinav ===
sharedInsights.add(new MedicalInsight(
    Name = 'Abhinav monitors for ADA formation in Immunexis patients',
    Content = 'HCP has started routinely checking anti-drug antibody levels in patients on Immunexis after 6 months. Reports that while no clear loss of efficacy has been observed, he remains vigilant given historical precedent with other biologics.',
    TopicNames = 'Immunogenicity',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));

// === MECHANISM DOUBTS — shared by Mangala ===
sharedInsights.add(new MedicalInsight(
    Name = 'Mangala questions biomarker-clinical outcome disconnect',
    Content = 'HCP expressed concern that the biomarker data for Immunexis do not clearly translate to clinical endpoints. She wants mechanistic studies showing how pathway modulation leads to structural protection.',
    TopicNames = 'Mechanism Doubts',
    Sentiment__c = 'Negative',
    SourceType = 'Visit'
));

// === MULTI-INDICATION INTEREST — shared by Thomas, Aaron ===
sharedInsights.add(new MedicalInsight(
    Name = 'Thomas interested in Immunexis for overlap syndromes',
    Content = 'HCP manages several patients with RA-lupus overlap and asked whether Immunexis mechanism could address shared inflammatory pathways. He sees potential but wants pilot data before attempting off-label use.',
    TopicNames = 'Multi-Indication Interest',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));
sharedInsights.add(new MedicalInsight(
    Name = 'Aaron asks about Crohn\'s disease data for Immunexis',
    Content = 'HCP co-manages patients with GI colleagues and inquired about any emerging data for Immunexis in Crohn\'s disease. He believes the mechanism could be relevant and would refer patients to trials if available.',
    TopicNames = 'Multi-Indication Interest',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));

insert sharedInsights;
System.debug('Inserted ' + sharedInsights.size() + ' shared-theme MedicalInsight records');

// ===== Shared: MedicalInsightAccount junctions =====
List<MedicalInsightAccount> sharedJunctions = new List<MedicalInsightAccount>();

// Efficacy in Refractory RA: Abhinav (idx 0), Thomas (idx 1)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[0].Id, AccountId = abhinavId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[1].Id, AccountId = thomasId));
// Real-World Evidence: Peter (idx 2), Mangala (idx 3)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[2].Id, AccountId = peterId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[3].Id, AccountId = mangalaId));
// Early Intervention Potential: Thomas (idx 4), Mangala (idx 5)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[4].Id, AccountId = thomasId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[5].Id, AccountId = mangalaId));
// Comparative Data: Aaron (idx 6), Peter (idx 7)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[6].Id, AccountId = aaronId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[7].Id, AccountId = peterId));
// Quality of Life: Aaron (idx 8), Mangala (idx 9)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[8].Id, AccountId = aaronId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[9].Id, AccountId = mangalaId));
// Immunogenicity: Abhinav (idx 10)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[10].Id, AccountId = abhinavId));
// Mechanism Doubts: Mangala (idx 11)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[11].Id, AccountId = mangalaId));
// Multi-Indication Interest: Thomas (idx 12), Aaron (idx 13)
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[12].Id, AccountId = thomasId));
sharedJunctions.add(new MedicalInsightAccount(MedicalInsightId = sharedInsights[13].Id, AccountId = aaronId));

insert sharedJunctions;
System.debug('Inserted ' + sharedJunctions.size() + ' shared MedicalInsightAccount junctions');

// ===== Shared: MedicalInsightProduct links =====
List<MedicalInsightProduct> sharedProducts = new List<MedicalInsightProduct>();
for (MedicalInsight mi : sharedInsights) {
    sharedProducts.add(new MedicalInsightProduct(
        MedicalInsightId = mi.Id,
        ProductId = immunexisId
    ));
}
insert sharedProducts;
System.debug('Inserted ' + sharedProducts.size() + ' shared MedicalInsightProduct links');

// ============================================================
// SUMMARY
// ============================================================
System.debug('=== DATA LOAD COMPLETE ===');
System.debug('Core MedicalInsight records: ' + coreInsights.size());
System.debug('Shared-theme MedicalInsight records: ' + sharedInsights.size());
System.debug('Total MedicalInsight records: ' + (coreInsights.size() + sharedInsights.size()));
System.debug('Total MedicalInsightAccount junctions: ' + (coreJunctions.size() + sharedJunctions.size()));
System.debug('Total MedicalInsightProduct links: ' + (coreProducts.size() + sharedProducts.size()));
