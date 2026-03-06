// Create MedicalInsight records with shared themes across HCPs
// This creates connections between HCPs in the signal map

// Account IDs
String aaronId   = '001Ws00005GNtBuIAL'; // Aaron Morita
String abhinavId = '001Ws00005GNtBtIAL'; // Abhinav Sinha
String peterId   = '001Ws00005GNtBvIAL'; // Peter Neale
String thomasId  = '001Ws00005GNtBwIAL'; // Thomas Dorsch
String mangalaId = '001Ws00005GNtC0IAL'; // Mangala Yeturu

List<MedicalInsight> insights = new List<MedicalInsight>();

// === EFFICACY IN REFRACTORY RA — shared by Aaron, Abhinav, Thomas ===
insights.add(new MedicalInsight(
    Name = 'Abhinav notes sustained DAS28 improvement with Immunexis in refractory RA',
    Content = 'HCP reports that two refractory RA patients showed sustained DAS28 remission beyond 24 weeks on Immunexis, even after failing both JAK inhibitors and TNF agents. Describes this as the first durable response seen in these patients.',
    TopicNames = 'Efficacy in Refractory RA',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
insights.add(new MedicalInsight(
    Name = 'Thomas observes functional gains in refractory RA cohort',
    Content = 'HCP noted that refractory RA patients on Immunexis have demonstrated clinically meaningful improvements in grip strength and HAQ-DI scores. Believes the drug addresses a previously unmet need in this population.',
    TopicNames = 'Efficacy in Refractory RA',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));

// === REAL-WORLD EVIDENCE — shared by Abhinav, Peter, Mangala ===
insights.add(new MedicalInsight(
    Name = 'Peter demands registry data before recommending Immunexis broadly',
    Content = 'HCP is unwilling to prescribe Immunexis beyond trial-eligible patients until real-world registry data on 2-year outcomes are published. Expressed frustration at the gap between pivotal trial populations and his patient mix.',
    TopicNames = 'Real-World Evidence',
    Sentiment__c = 'Negative',
    SourceType = 'Visit'
));
insights.add(new MedicalInsight(
    Name = 'Mangala calls for post-market surveillance studies',
    Content = 'HCP emphasized that her institution requires post-market surveillance data before formulary inclusion. She would champion Immunexis internally if real-world safety data from diverse populations were available.',
    TopicNames = 'Real-World Evidence',
    Sentiment__c = 'Neutral',
    SourceType = 'Meeting'
));

// === EARLY INTERVENTION POTENTIAL — shared by Aaron, Thomas, Mangala ===
insights.add(new MedicalInsight(
    Name = 'Thomas advocates for early biologic use including Immunexis',
    Content = 'HCP believes the treat-to-target paradigm supports earlier use of targeted therapies like Immunexis. Cited recent EULAR updates and his own clinical experience showing that early aggressive treatment prevents erosive disease.',
    TopicNames = 'Early Intervention Potential',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
insights.add(new MedicalInsight(
    Name = 'Mangala questions early intervention without long-term safety data',
    Content = 'HCP is interested in Immunexis for early RA but cautious about using a newer agent before conventional DMARDs have been adequately trialed. Wants to see 5-year safety data before moving Immunexis up in her treatment algorithm.',
    TopicNames = 'Early Intervention Potential',
    Sentiment__c = 'Neutral',
    SourceType = 'Meeting'
));

// === COMPARATIVE DATA — shared by Abhinav, Aaron, Peter ===
insights.add(new MedicalInsight(
    Name = 'Aaron wants head-to-head data vs IL-6 inhibitors',
    Content = 'HCP asked specifically about comparisons between Immunexis and tocilizumab in seropositive RA. Noted that many of his patients have done well on IL-6 pathway and he needs a compelling reason to switch.',
    TopicNames = 'Comparative Data',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));
insights.add(new MedicalInsight(
    Name = 'Peter skeptical without PsA comparative trial results',
    Content = 'HCP reiterated that without randomized head-to-head data against secukinumab in PsA, he cannot justify switching stable patients. Stated that anecdotal reports are insufficient for his evidence-based practice.',
    TopicNames = 'Comparative Data',
    Sentiment__c = 'Negative',
    SourceType = 'Meeting'
));

// === QUALITY OF LIFE — shared by Thomas, Aaron, Mangala ===
insights.add(new MedicalInsight(
    Name = 'Aaron reports patients highlight fatigue improvement',
    Content = 'HCP shared that multiple patients have spontaneously reported reduced fatigue and improved sleep quality since starting Immunexis. Considers patient-reported outcomes critical for treatment adherence.',
    TopicNames = 'Quality of Life',
    Sentiment__c = 'Positive',
    SourceType = 'Visit'
));
insights.add(new MedicalInsight(
    Name = 'Mangala sees improvement in work productivity among Immunexis patients',
    Content = 'HCP noted that several patients on Immunexis have returned to full-time work or resumed daily activities they had abandoned. She views work productivity as an underutilized outcome measure.',
    TopicNames = 'Quality of Life',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));

// === IMMUNOGENICITY — shared by Peter, Abhinav ===
insights.add(new MedicalInsight(
    Name = 'Abhinav monitors for ADA formation in Immunexis patients',
    Content = 'HCP has started routinely checking anti-drug antibody levels in patients on Immunexis after 6 months. Reports that while no clear loss of efficacy has been observed, he remains vigilant given historical precedent with other biologics.',
    TopicNames = 'Immunogenicity',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));

// === MECHANISM DOUBTS — shared by Peter, Mangala ===
insights.add(new MedicalInsight(
    Name = 'Mangala questions biomarker-clinical outcome disconnect',
    Content = 'HCP expressed concern that the biomarker data for Immunexis do not clearly translate to clinical endpoints. She wants mechanistic studies showing how pathway modulation leads to structural protection.',
    TopicNames = 'Mechanism Doubts',
    Sentiment__c = 'Negative',
    SourceType = 'Visit'
));

// === MULTI-INDICATION INTEREST — shared by Mangala, Thomas, Aaron ===
insights.add(new MedicalInsight(
    Name = 'Thomas interested in Immunexis for overlap syndromes',
    Content = 'HCP manages several patients with RA-lupus overlap and asked whether Immunexis mechanism could address shared inflammatory pathways. He sees potential but wants pilot data before attempting off-label use.',
    TopicNames = 'Multi-Indication Interest',
    Sentiment__c = 'Positive',
    SourceType = 'Meeting'
));
insights.add(new MedicalInsight(
    Name = 'Aaron asks about Crohn\'s disease data for Immunexis',
    Content = 'HCP co-manages patients with GI colleagues and inquired about any emerging data for Immunexis in Crohn\'s disease. He believes the mechanism could be relevant and would refer patients to trials if available.',
    TopicNames = 'Multi-Indication Interest',
    Sentiment__c = 'Neutral',
    SourceType = 'Visit'
));

insert insights;
System.debug('Created ' + insights.size() + ' MedicalInsight records');

// Now create MedicalInsightAccount junction records
List<MedicalInsightAccount> junctions = new List<MedicalInsightAccount>();

// Map: insight index -> list of account IDs
// Efficacy in Refractory RA: Abhinav (idx 0), Thomas (idx 1)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[0].Id, AccountId = abhinavId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[1].Id, AccountId = thomasId));

// Real-World Evidence: Peter (idx 2), Mangala (idx 3)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[2].Id, AccountId = peterId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[3].Id, AccountId = mangalaId));

// Early Intervention Potential: Thomas (idx 4), Mangala (idx 5)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[4].Id, AccountId = thomasId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[5].Id, AccountId = mangalaId));

// Comparative Data: Aaron (idx 6), Peter (idx 7)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[6].Id, AccountId = aaronId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[7].Id, AccountId = peterId));

// Quality of Life: Aaron (idx 8), Mangala (idx 9)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[8].Id, AccountId = aaronId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[9].Id, AccountId = mangalaId));

// Immunogenicity: Abhinav (idx 10)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[10].Id, AccountId = abhinavId));

// Mechanism Doubts: Mangala (idx 11)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[11].Id, AccountId = mangalaId));

// Multi-Indication Interest: Thomas (idx 12), Aaron (idx 13)
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[12].Id, AccountId = thomasId));
junctions.add(new MedicalInsightAccount(MedicalInsightId = insights[13].Id, AccountId = aaronId));

insert junctions;
System.debug('Created ' + junctions.size() + ' MedicalInsightAccount junction records');
System.debug('Done! Themes are now shared across multiple HCPs.');
