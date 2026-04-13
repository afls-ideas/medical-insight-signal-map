// =============================================================================
// Combined Demo Data Load Script for org 260-pm
// Creates 53 MedicalInsight records across 10 HCPs and 15 topics
// All linked to Immunexis 10mg via MedicalInsightAccount & MedicalInsightProduct
// =============================================================================

// --- HCP Account IDs (260-pm org) ---
Map<String, Id> hcpMap = new Map<String, Id>{
    // Original 5 HCPs
    'David Chen'       => '001Hs00005uBkMoIAK',
    'Sarah Patel'     => '001Hs00005uBkMnIAK',
    'James Okoro'       => '001Hs00005uBkMpIAK',
    'Maria Santos'     => '001Hs00005uBkMqIAK',
    'Robert Kim'    => '001Hs00005uBkMuIAK',
    // New 5 HCPs
    'Linda Tanaka'     => '001Hs00005uBjwzIAC',
    'Karen Nwosu'      => '001Hs00005uBjw5IAC',
    'Michael Reyes'  => '001Hs00005uBjxmIAC',
    'Steven Gupta'  => '001Hs00005uBjuOIAS',
    'Daniel Fischer'  => '001Hs00005uBjwLIAS'
};
List<String> hcpList = new List<String>(hcpMap.keySet());

Id immunexisId = '01tHs00000DdyovIAB';

List<String> sentiments = new List<String>{'Positive','Neutral','Negative'};
List<String> sourceTypes = new List<String>{'Visit','Meeting','Account'};

List<MedicalInsight> allInsights = new List<MedicalInsight>();
List<String> allHcpNames = new List<String>();

// =============================================================================
// BATCH 1: 13 records — 5 original HCPs, 5 topics
// Topics: Efficacy, Safety, Real-World Evidence, Patient Outcomes, Mechanism of Action
// =============================================================================

// --- Efficacy (David Chen, Sarah Patel, Maria Santos) ---
allInsights.add(new MedicalInsight(Name='Favorable response in refractory RA patients on Immunexis', Content='David Chen observed that patients with long-standing RA who previously failed multiple DMARDs showed clinical improvement within 6-8 weeks on Immunexis. Improvements in DAS28 scores, morning stiffness, and fatigue were noted.', Sentiment__c='Positive', TopicNames='Efficacy', SourceType='Visit'));
allHcpNames.add('David Chen');

allInsights.add(new MedicalInsight(Name='Requests head-to-head efficacy data vs IL-17 inhibitors', Content='Sarah Patel inquired about Immunexis performance in PsA compared to IL-17 inhibitors. Hesitant to switch stable patients without comparative trial data.', Sentiment__c='Neutral', TopicNames='Efficacy', SourceType='Visit'));
allHcpNames.add('Sarah Patel');

allInsights.add(new MedicalInsight(Name='Strong efficacy signal in early-stage RA patients', Content='Maria Santos reported rapid onset of action in early RA patients started on Immunexis as first-line biologic. ACR50 responses observed within 12 weeks in majority of cases.', Sentiment__c='Positive', TopicNames='Efficacy', SourceType='Meeting'));
allHcpNames.add('Maria Santos');

// --- Safety (James Okoro, Sarah Patel, Robert Kim) ---
allInsights.add(new MedicalInsight(Name='Concerns about immunogenicity beyond one year', Content='James Okoro expressed concerns about anti-drug antibody formation with prolonged Immunexis use. Loss of efficacy in Year 2 could indicate delayed immunogenicity not captured in pivotal trials.', Sentiment__c='Negative', TopicNames='Safety', SourceType='Meeting'));
allHcpNames.add('James Okoro');

allInsights.add(new MedicalInsight(Name='Wants long-term safety registry data before broader adoption', Content='Sarah Patel emphasized the need for long-term observational safety studies. Skeptical about relying solely on controlled trial data and awaiting registry outcomes on adverse event profiles.', Sentiment__c='Neutral', TopicNames='Safety', SourceType='Visit'));
allHcpNames.add('Sarah Patel');

allInsights.add(new MedicalInsight(Name='Questions safety profile in patients with multiple autoimmune conditions', Content='Robert Kim asked about safety in patients with comorbid autoimmune conditions like UC or Hashimoto\'s. Concerned about immunosuppression overlap when combining with existing therapies.', Sentiment__c='Neutral', TopicNames='Safety', SourceType='Meeting'));
allHcpNames.add('Robert Kim');

// --- Real-World Evidence (David Chen, James Okoro) ---
allInsights.add(new MedicalInsight(Name='Seeing consistent real-world outcomes matching trial data', Content='David Chen noted that real-world outcomes in his practice are consistent with pivotal trial results. Patients maintaining remission at 6 months with good tolerability.', Sentiment__c='Positive', TopicNames='Real-World Evidence', SourceType='Visit'));
allHcpNames.add('David Chen');

allInsights.add(new MedicalInsight(Name='Skeptical that trial results will replicate in diverse populations', Content='James Okoro doubts that pivotal trial efficacy will hold in more diverse real-world populations. Wants to see outcomes data from community rheumatology settings, not just academic centers.', Sentiment__c='Negative', TopicNames='Real-World Evidence', SourceType='Meeting'));
allHcpNames.add('James Okoro');

// --- Patient Outcomes (Maria Santos, Robert Kim, David Chen) ---
allInsights.add(new MedicalInsight(Name='Significant improvement in patient-reported fatigue scores', Content='Maria Santos highlighted improvements in fatigue and functional ability among patients on Immunexis. PROMIS-Fatigue scores complement lab endpoints and should be integrated into monitoring.', Sentiment__c='Positive', TopicNames='Patient Outcomes', SourceType='Visit'));
allHcpNames.add('Maria Santos');

allInsights.add(new MedicalInsight(Name='Interest in multi-indication patient outcomes', Content='Robert Kim asked whether Immunexis shows patient outcome benefits across multiple autoimmune indications. Interested in quality of life data beyond just RA.', Sentiment__c='Neutral', TopicNames='Patient Outcomes', SourceType='Meeting'));
allHcpNames.add('Robert Kim');

allInsights.add(new MedicalInsight(Name='Patients reporting improved daily functioning on Immunexis', Content='David Chen shared that several patients report meaningful improvements in daily activities and work productivity since starting Immunexis. Considering incorporating PRO measures into routine visits.', Sentiment__c='Positive', TopicNames='Patient Outcomes', SourceType='Visit'));
allHcpNames.add('David Chen');

// --- Mechanism of Action (James Okoro, Maria Santos) ---
allInsights.add(new MedicalInsight(Name='Unconvinced by MOA claims for Immunexis', Content='James Okoro stated that while the MOA appears novel, lack of correlation between biomarker suppression and sustained remission is unconvincing. Wants mechanistic studies with translational endpoints.', Sentiment__c='Negative', TopicNames='Mechanism of Action', SourceType='Meeting'));
allHcpNames.add('James Okoro');

allInsights.add(new MedicalInsight(Name='Novel MOA offers differentiation from existing biologics', Content='Maria Santos believes the dual-pathway mechanism of Immunexis provides a genuine therapeutic advantage over single-target biologics. Sees potential for use in patients who have cycled through TNF and IL-6 inhibitors.', Sentiment__c='Positive', TopicNames='Mechanism of Action', SourceType='Meeting'));
allHcpNames.add('Maria Santos');

// =============================================================================
// BATCH 2: 20 records — 5 original HCPs, 10 new topics
// Topics: Dosing Optimization, Combination Therapy, Biomarker Strategy, Payer Access,
//         Patient Adherence, Pediatric Use, Treatment Sequencing, Switching Protocols,
//         Onset of Action, Long-Term Remission
// =============================================================================

Map<String, List<String>> insightNames = new Map<String, List<String>>{
    'Dosing Optimization' => new List<String>{
        'Exploring lower maintenance dose after initial response',
        'Dose escalation yielded better outcomes in partial responders',
        'Questions optimal dosing interval for elderly patients'
    },
    'Combination Therapy' => new List<String>{
        'Positive results combining Immunexis with methotrexate',
        'Concerns about infection risk with dual biologic use'
    },
    'Biomarker Strategy' => new List<String>{
        'CRP normalization correlates with sustained response',
        'Wants validated biomarker panel to predict responders',
        'Anti-CCP levels not predictive of Immunexis response'
    },
    'Payer Access' => new List<String>{
        'Step therapy requirements delaying patient access',
        'Prior auth turnaround improved with new hub support'
    },
    'Patient Adherence' => new List<String>{
        'Autoinjector form factor improving compliance rates',
        'Patients skipping doses due to injection site reactions',
        'Monthly dosing schedule preferred over biweekly'
    },
    'Pediatric Use' => new List<String>{
        'Off-label use showing promise in juvenile RA',
        'Need pediatric-specific pharmacokinetic data'
    },
    'Treatment Sequencing' => new List<String>{
        'Immunexis as second-line after TNF failure showing strong results',
        'Debate on positioning vs IL-6 inhibitors in sequence',
        'Early positioning may prevent need for later escalation'
    },
    'Switching Protocols' => new List<String>{
        'Washout period recommendations unclear for TNF switchers',
        'Direct switch from adalimumab well tolerated in practice',
        'Wants guidance on switching from rituximab to Immunexis'
    },
    'Onset of Action' => new List<String>{
        'Patients noticing symptom relief within 2 weeks',
        'Slower onset in patients with high disease burden'
    },
    'Long-Term Remission' => new List<String>{
        'Sustained remission at 18 months in majority of patients',
        'Concerned about relapse rates after dose reduction',
        'Registry data needed to confirm durability beyond 2 years'
    }
};

Map<String, List<String>> insightContent = new Map<String, List<String>>{
    'Dosing Optimization' => new List<String>{
        'After achieving clinical response at standard dose, the HCP has been trialing dose reduction to improve tolerability. Early results show maintenance of DAS28 remission at lower doses in select patients.',
        'The HCP escalated dosing in 3 partial responders and observed meaningful improvement in joint counts and inflammatory markers within 4 weeks. Believes flexible dosing could expand the eligible patient population.',
        'Raised concerns about dosing in patients over 75 with reduced renal function. Wants pharmacokinetic guidance for dose adjustment in the elderly population.'
    },
    'Combination Therapy' => new List<String>{
        'The HCP has been combining Immunexis with low-dose methotrexate in biologic-naive patients and seeing superior ACR70 response rates compared to monotherapy in prior experience.',
        'Expressed caution about combining Immunexis with other immunosuppressants given overlapping infection risk. Wants controlled data on serious infection rates in combination arms.'
    },
    'Biomarker Strategy' => new List<String>{
        'Observed that patients achieving CRP normalization within 4 weeks of Immunexis initiation tend to maintain long-term response. Suggests CRP as an early predictive biomarker.',
        'Frustrated by lack of validated companion diagnostics for Immunexis. Wants a multi-biomarker panel to identify likely responders before committing patients to therapy.',
        'Noted that anti-CCP antibody levels did not correlate with Immunexis response in a small case series. Questions whether current biomarker research is on the right track.'
    },
    'Payer Access' => new List<String>{
        'Multiple patients required to fail two TNF inhibitors before payer approval for Immunexis. The HCP sees this as clinically inappropriate and delays optimal treatment.',
        'Acknowledged improvement in prior authorization processing times since the specialty pharmacy hub was launched. Turnaround now averaging 5 business days vs previous 15.'
    },
    'Patient Adherence' => new List<String>{
        'Since switching patients to the autoinjector pen, adherence rates in the practice have improved. Patients report the device is easier to use than prefilled syringes.',
        'Several patients have reported skipping doses due to persistent injection site reactions including redness and swelling. The HCP is considering premedication strategies.',
        'Patients strongly prefer the monthly dosing option. The HCP believes reducing injection frequency is a key driver of long-term adherence and treatment satisfaction.'
    },
    'Pediatric Use' => new List<String>{
        'Has used Immunexis off-label in 2 adolescent patients with aggressive JIA who failed multiple DMARDs. Both showed meaningful improvement in joint scores at 3 months.',
        'Emphasized the need for dedicated pediatric trials with age-appropriate dosing. Current adult extrapolation is insufficient for confident prescribing in children under 16.'
    },
    'Treatment Sequencing' => new List<String>{
        'Positioned Immunexis as second-line after TNF failure in 12 patients over the past year. Response rates have been encouraging with 75% achieving ACR50 by week 16.',
        'Debating internally whether Immunexis should be sequenced before or after IL-6 inhibitors. Current evidence does not clearly favor one approach over the other.',
        'Believes starting Immunexis earlier in the treatment algorithm may prevent the accumulated joint damage seen in patients who cycle through multiple less effective agents.'
    },
    'Switching Protocols' => new List<String>{
        'Unclear on recommended washout period when switching patients from TNF inhibitors to Immunexis. Current guidance is vague and the HCP wants specific timelines.',
        'Has directly switched 5 patients from adalimumab to Immunexis without a washout period. No safety signals observed and efficacy maintained or improved in all cases.',
        'Patient previously on rituximab with delayed B-cell recovery. Wants specific guidance on safe timing to initiate Immunexis post-rituximab to avoid compounding immunosuppression.'
    },
    'Onset of Action' => new List<String>{
        'Multiple patients have reported noticeable symptom improvement within the first 2 weeks of starting Immunexis. The HCP finds this faster than typical biologic onset.',
        'In patients with high baseline DAS28 scores and extensive joint involvement, onset of meaningful clinical response has been slower, typically 8-12 weeks rather than 2-4.'
    },
    'Long-Term Remission' => new List<String>{
        'Of 20 patients started on Immunexis 18+ months ago, 14 remain in sustained DAS28 remission. The HCP considers this an impressive durability signal for a newer agent.',
        'Concerned that dose reduction attempts after achieving remission may lead to disease flare. Wants clearer guidance on when and how to taper without losing disease control.',
        'Stressed the need for 5-year registry data to confirm whether current remission rates hold up. Pivotal trial follow-up periods are insufficient for chronic disease management decisions.'
    }
};

// HCP assignments per topic (indices into hcpList for original 5 HCPs)
// David Chen=0, Sarah Patel=1, James Okoro=2, Maria Santos=3, Robert Kim=4
// (Note: Map key ordering may vary — these indices reference the hcpList derived from hcpMap)
Map<String, List<String>> topicHcpNames = new Map<String, List<String>>{
    'Dosing Optimization'  => new List<String>{'David Chen', 'James Okoro', 'Robert Kim'},
    'Combination Therapy'  => new List<String>{'Sarah Patel', 'Maria Santos'},
    'Biomarker Strategy'   => new List<String>{'David Chen', 'Sarah Patel', 'Maria Santos'},
    'Payer Access'         => new List<String>{'James Okoro', 'Robert Kim'},
    'Patient Adherence'    => new List<String>{'David Chen', 'Maria Santos', 'Robert Kim'},
    'Pediatric Use'        => new List<String>{'Sarah Patel', 'James Okoro'},
    'Treatment Sequencing' => new List<String>{'David Chen', 'Sarah Patel', 'James Okoro'},
    'Switching Protocols'  => new List<String>{'Maria Santos', 'Robert Kim', 'Sarah Patel'},
    'Onset of Action'      => new List<String>{'David Chen', 'James Okoro'},
    'Long-Term Remission'  => new List<String>{'Maria Santos', 'Robert Kim', 'James Okoro'}
};

Integer count = 0;
for (String topic : topicHcpNames.keySet()) {
    List<String> hcpNamesForTopic = topicHcpNames.get(topic);
    List<String> names = insightNames.get(topic);
    List<String> contents = insightContent.get(topic);

    for (Integer i = 0; i < hcpNamesForTopic.size() && count < 20; i++) {
        allInsights.add(new MedicalInsight(
            Name = names[i],
            Content = contents[i],
            Sentiment__c = sentiments[Math.mod(count, 3)],
            TopicNames = topic,
            SourceType = sourceTypes[Math.mod(count, 3)]
        ));
        allHcpNames.add(hcpNamesForTopic[i]);
        count++;
    }
}

// =============================================================================
// BATCH 3: 20 records — 5 new HCPs, reusing topics for cross-connections
// New HCPs: Linda Tanaka, Karen Nwosu, Michael Reyes, Steven Gupta, Daniel Fischer
// =============================================================================

// --- Efficacy: Linda Tanaka, Michael Reyes ---
allInsights.add(new MedicalInsight(Name='Impressive ACR70 rates in biologic-naive patients', Content='Linda Tanaka reported that biologic-naive patients started on Immunexis are achieving ACR70 response rates exceeding published trial data. She attributes this to earlier intervention and better patient selection in her practice.', Sentiment__c='Positive', TopicNames='Efficacy', SourceType='Visit'));
allHcpNames.add('Linda Tanaka');

allInsights.add(new MedicalInsight(Name='Efficacy waning after 12 months in some patients', Content='Michael Reyes noted a subset of patients experiencing declining efficacy after the first year. Suspects secondary loss of response and is considering dose adjustment or combination approaches.', Sentiment__c='Negative', TopicNames='Efficacy', SourceType='Meeting'));
allHcpNames.add('Michael Reyes');

// --- Safety: Steven Gupta, Karen Nwosu ---
allInsights.add(new MedicalInsight(Name='Hepatic enzyme elevations observed in two patients', Content='Steven Gupta flagged ALT elevations in two patients on Immunexis at month 4. Both resolved after temporary hold. He recommends routine liver function monitoring in the first 6 months.', Sentiment__c='Negative', TopicNames='Safety', SourceType='Visit'));
allHcpNames.add('Steven Gupta');

allInsights.add(new MedicalInsight(Name='Favorable safety profile in elderly patients', Content='Karen Nwosu has prescribed Immunexis to 8 patients over age 70 with no serious adverse events. Believes the safety profile is reassuring for the geriatric population compared to JAK inhibitors.', Sentiment__c='Positive', TopicNames='Safety', SourceType='Visit'));
allHcpNames.add('Karen Nwosu');

// --- Patient Outcomes: Linda Tanaka, Daniel Fischer ---
allInsights.add(new MedicalInsight(Name='Work productivity improvements reported by patients', Content='Linda Tanaka shared that multiple patients have returned to full-time work after starting Immunexis. She considers work productivity a meaningful real-world outcome beyond clinical scores.', Sentiment__c='Positive', TopicNames='Patient Outcomes', SourceType='Meeting'));
allHcpNames.add('Linda Tanaka');

allInsights.add(new MedicalInsight(Name='Sleep quality improvements noted alongside pain reduction', Content='Daniel Fischer observed that patients on Immunexis report better sleep quality as inflammation decreases. He is interested in formally tracking Pittsburgh Sleep Quality Index alongside standard disease measures.', Sentiment__c='Positive', TopicNames='Patient Outcomes', SourceType='Visit'));
allHcpNames.add('Daniel Fischer');

// --- Mechanism of Action: Karen Nwosu, Steven Gupta ---
allInsights.add(new MedicalInsight(Name='Dual-pathway MOA may explain broad efficacy across phenotypes', Content='Karen Nwosu believes the dual-pathway mechanism explains why Immunexis works across seropositive and seronegative RA phenotypes. She sees this as a clinical advantage over single-target agents.', Sentiment__c='Positive', TopicNames='Mechanism of Action', SourceType='Meeting'));
allHcpNames.add('Karen Nwosu');

allInsights.add(new MedicalInsight(Name='MOA not sufficiently differentiated from existing IL-6 agents', Content='Steven Gupta questions whether the mechanism of Immunexis is truly novel or simply an incremental modification of existing IL-6 pathway biology. Wants head-to-head mechanistic comparisons.', Sentiment__c='Negative', TopicNames='Mechanism of Action', SourceType='Meeting'));
allHcpNames.add('Steven Gupta');

// --- Dosing Optimization: Michael Reyes, Daniel Fischer ---
allInsights.add(new MedicalInsight(Name='Weight-based dosing may improve outcomes in obese patients', Content='Michael Reyes has noticed lower response rates in patients with BMI over 35. He suspects standard flat dosing is subtherapeutic in this population and wants PK data to support weight-based adjustments.', Sentiment__c='Neutral', TopicNames='Dosing Optimization', SourceType='Visit'));
allHcpNames.add('Michael Reyes');

allInsights.add(new MedicalInsight(Name='Extended dosing interval successful in stable patients', Content='Daniel Fischer has successfully extended the dosing interval to every 6 weeks in 4 patients who achieved sustained remission. No loss of efficacy observed over 6 months of extended intervals.', Sentiment__c='Positive', TopicNames='Dosing Optimization', SourceType='Visit'));
allHcpNames.add('Daniel Fischer');

// --- Treatment Sequencing: Karen Nwosu, Michael Reyes ---
allInsights.add(new MedicalInsight(Name='First-line biologic use yielding better long-term outcomes', Content='Karen Nwosu argues that using Immunexis as a first-line biologic rather than waiting for TNF failure produces better long-term joint preservation. Her early adopter patients have the best radiographic outcomes.', Sentiment__c='Positive', TopicNames='Treatment Sequencing', SourceType='Meeting'));
allHcpNames.add('Karen Nwosu');

allInsights.add(new MedicalInsight(Name='Third-line positioning still effective after multiple biologic failures', Content='Michael Reyes has used Immunexis in patients who failed 2+ prior biologics. While response rates are lower than first-line use, meaningful improvement is still achievable in this refractory population.', Sentiment__c='Neutral', TopicNames='Treatment Sequencing', SourceType='Visit'));
allHcpNames.add('Michael Reyes');

// --- Switching Protocols: Linda Tanaka, Steven Gupta ---
allInsights.add(new MedicalInsight(Name='Smooth transition from secukinumab to Immunexis', Content='Linda Tanaka switched 3 PsA patients from secukinumab to Immunexis with no washout. All tolerated the switch well and showed improved skin and joint outcomes within 8 weeks.', Sentiment__c='Positive', TopicNames='Switching Protocols', SourceType='Visit'));
allHcpNames.add('Linda Tanaka');

allInsights.add(new MedicalInsight(Name='Post-tofacitinib switch requires careful monitoring', Content='Steven Gupta noted that patients switching from tofacitinib to Immunexis need close monitoring in the first month. One patient developed herpes zoster reactivation during the overlap period.', Sentiment__c='Negative', TopicNames='Switching Protocols', SourceType='Meeting'));
allHcpNames.add('Steven Gupta');

// --- Long-Term Remission: Linda Tanaka, Daniel Fischer ---
allInsights.add(new MedicalInsight(Name='Drug-free remission attempted in 2 patients after sustained response', Content='Linda Tanaka attempted drug-free remission in 2 patients after 24 months of sustained DAS28 remission. One maintained remission at 6 months off therapy; the other flared at month 3 and restarted.', Sentiment__c='Neutral', TopicNames='Long-Term Remission', SourceType='Meeting'));
allHcpNames.add('Linda Tanaka');

allInsights.add(new MedicalInsight(Name='Radiographic progression halted in long-term responders', Content='Daniel Fischer presented imaging data showing no radiographic progression in patients maintaining remission on Immunexis for 18+ months. Considers this strong evidence of disease modification.', Sentiment__c='Positive', TopicNames='Long-Term Remission', SourceType='Visit'));
allHcpNames.add('Daniel Fischer');

// --- Biomarker Strategy: Karen Nwosu, Daniel Fischer ---
allInsights.add(new MedicalInsight(Name='IL-6 levels may predict Immunexis response better than CRP alone', Content='Karen Nwosu observed that baseline IL-6 levels above a certain threshold correlate with stronger response to Immunexis. She is collaborating with a lab to develop a predictive assay.', Sentiment__c='Positive', TopicNames='Biomarker Strategy', SourceType='Meeting'));
allHcpNames.add('Karen Nwosu');

allInsights.add(new MedicalInsight(Name='Calprotectin as a monitoring biomarker during treatment', Content='Daniel Fischer is using fecal calprotectin as a supplementary monitoring biomarker in patients with RA and subclinical gut inflammation. Early data suggests it tracks with systemic disease activity.', Sentiment__c='Neutral', TopicNames='Biomarker Strategy', SourceType='Visit'));
allHcpNames.add('Daniel Fischer');

// --- Real-World Evidence: Steven Gupta, Michael Reyes ---
allInsights.add(new MedicalInsight(Name='Community practice outcomes lagging behind academic center data', Content='Steven Gupta reported that response rates in his community practice are lower than published academic center data. He attributes this to differences in patient selection and monitoring intensity.', Sentiment__c='Negative', TopicNames='Real-World Evidence', SourceType='Visit'));
allHcpNames.add('Steven Gupta');

allInsights.add(new MedicalInsight(Name='Real-world persistence rates encouraging at 12 months', Content='Michael Reyes shared that 80% of patients in his practice remain on Immunexis at 12 months, which exceeds persistence rates he has seen with other biologics. Attributes this to efficacy and tolerability.', Sentiment__c='Positive', TopicNames='Real-World Evidence', SourceType='Meeting'));
allHcpNames.add('Michael Reyes');

// =============================================================================
// INSERT ALL RECORDS
// =============================================================================

insert allInsights;
System.debug('Inserted ' + allInsights.size() + ' MedicalInsight records');

// Create MedicalInsightAccount junctions
List<MedicalInsightAccount> junctions = new List<MedicalInsightAccount>();
for (Integer i = 0; i < allInsights.size(); i++) {
    MedicalInsightAccount mia = new MedicalInsightAccount();
    mia.MedicalInsightId = allInsights[i].Id;
    mia.AccountId = hcpMap.get(allHcpNames[i]);
    junctions.add(mia);
}
insert junctions;
System.debug('Inserted ' + junctions.size() + ' MedicalInsightAccount junctions');

// Create MedicalInsightProduct links (all linked to Immunexis 10mg)
List<MedicalInsightProduct> prods = new List<MedicalInsightProduct>();
for (MedicalInsight mi : allInsights) {
    MedicalInsightProduct mip = new MedicalInsightProduct();
    mip.MedicalInsightId = mi.Id;
    mip.ProductId = immunexisId;
    prods.add(mip);
}
insert prods;
System.debug('Inserted ' + prods.size() + ' MedicalInsightProduct links');

System.debug('=== COMPLETE: ' + allInsights.size() + ' insights, ' + junctions.size() + ' junctions, ' + prods.size() + ' product links ===');
