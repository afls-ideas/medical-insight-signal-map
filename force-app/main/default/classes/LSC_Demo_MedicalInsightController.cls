public with sharing class LSC_Demo_MedicalInsightController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInsightNetwork(Id accountId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            List<Object> finalNodes = new List<Object>();
            List<Object> links = new List<Object>();

            // Query all MedicalInsightAccount junction records to get insights linked to accounts
            List<MedicalInsightAccount> junctionRecords = [
                SELECT Id, AccountId, Account.Name,
                       MedicalInsightId, MedicalInsight.Name, MedicalInsight.Content,
                       MedicalInsight.Sentiment__c, MedicalInsight.TopicNames,
                       MedicalInsight.SourceType
                FROM MedicalInsightAccount
                ORDER BY MedicalInsight.CreatedDate DESC
                LIMIT 1000
            ];

            // Use separate maps for HCP nodes and theme counts
            Map<String, Map<String, Object>> hcpNodeMap = new Map<String, Map<String, Object>>();
            Map<String, Integer> themeCounts = new Map<String, Integer>();

            for (MedicalInsightAccount mia : junctionRecords) {
                // 1. Aggregate theme counts
                if (String.isNotBlank(mia.MedicalInsight.TopicNames)) {
                    String topic = mia.MedicalInsight.TopicNames;
                    themeCounts.put(topic, themeCounts.containsKey(topic) ? themeCounts.get(topic) + 1 : 1);
                }

                // 2. Process HCP data
                if (mia.AccountId != null && mia.Account != null) {
                    String hcpId = 'hcp_' + mia.AccountId;
                    if (!hcpNodeMap.containsKey(hcpId)) {
                        String hcpName = mia.Account.Name;
                        String initials = getInitials(hcpName);

                        Map<String, Object> hcpNode = new Map<String, Object>{
                            'id' => hcpId,
                            'label' => hcpName,
                            'initials' => initials,
                            'type' => 'hcp',
                            'recordId' => mia.AccountId,
                            'insightCount' => 0,
                            'summaries' => new List<String>(),
                            'themes' => new List<String>(),
                            'sentimentCounts' => new Map<String, Integer>()
                        };
                        hcpNodeMap.put(hcpId, hcpNode);
                    }

                    Map<String, Object> hcpNodeToUpdate = hcpNodeMap.get(hcpId);
                    hcpNodeToUpdate.put('insightCount', (Integer)hcpNodeToUpdate.get('insightCount') + 1);

                    Map<String, Integer> sentimentCounts = (Map<String, Integer>)hcpNodeToUpdate.get('sentimentCounts');
                    String sentiment = mia.MedicalInsight.Sentiment__c != null ? mia.MedicalInsight.Sentiment__c : 'Neutral';
                    sentimentCounts.put(sentiment, sentimentCounts.get(sentiment) == null ? 1 : sentimentCounts.get(sentiment) + 1);

                    if (String.isNotBlank(mia.MedicalInsight.Content)) {
                        List<String> summaries = (List<String>)hcpNodeToUpdate.get('summaries');
                        if (summaries.size() < 10) {
                            summaries.add(mia.MedicalInsight.Name);
                        }
                    }

                    if (String.isNotBlank(mia.MedicalInsight.TopicNames)) {
                        List<String> themes = (List<String>)hcpNodeToUpdate.get('themes');
                        if (!themes.contains(mia.MedicalInsight.TopicNames)) {
                            themes.add(mia.MedicalInsight.TopicNames);
                        }
                    }
                }
            }

            // Calculate dominant sentiment for each HCP
            for (Map<String, Object> hcpNode : hcpNodeMap.values()) {
                Map<String, Integer> sentimentCounts = (Map<String, Integer>)hcpNode.get('sentimentCounts');
                String dominantSentiment = 'Neutral';
                Integer maxCount = 0;

                if (sentimentCounts != null) {
                    for (String sentiment : sentimentCounts.keySet()) {
                        Integer count = sentimentCounts.get(sentiment);
                        if (count > maxCount) {
                            maxCount = count;
                            dominantSentiment = sentiment;
                        }
                    }
                }
                hcpNode.put('sentiment', dominantSentiment);
                hcpNode.remove('sentimentCounts');
            }

            // Create links between HCPs that share themes
            List<String> hcpIds = new List<String>(hcpNodeMap.keySet());
            for (Integer i = 0; i < hcpIds.size(); i++) {
                for (Integer j = i + 1; j < hcpIds.size(); j++) {
                    String hcp1Id = hcpIds[i];
                    String hcp2Id = hcpIds[j];

                    Map<String, Object> hcp1 = hcpNodeMap.get(hcp1Id);
                    Map<String, Object> hcp2 = hcpNodeMap.get(hcp2Id);

                    List<String> themes1 = (List<String>)hcp1.get('themes');
                    List<String> themes2 = (List<String>)hcp2.get('themes');

                    Set<String> commonThemes = new Set<String>(themes1);
                    commonThemes.retainAll(new Set<String>(themes2));

                    if (!commonThemes.isEmpty()) {
                        links.add(new Map<String, Object>{
                            'source' => hcp1Id,
                            'target' => hcp2Id,
                            'value' => commonThemes.size(),
                            'commonThemes' => new List<String>(commonThemes),
                            'type' => 'shared_themes'
                        });
                    }
                }
            }

            // Add all HCP nodes to the final list
            finalNodes.addAll(hcpNodeMap.values());

            // Create and add theme nodes to the final list
            for (String themeName : themeCounts.keySet()) {
                finalNodes.add(new Map<String, Object>{
                    'id' => 'theme_' + themeName.replaceAll('[^a-zA-Z0-9]', ''),
                    'label' => themeName,
                    'type' => 'theme',
                    'insightCount' => themeCounts.get(themeName)
                });
            }

            result.put('nodes', finalNodes);
            result.put('links', links);
            result.put('totalInsights', junctionRecords.size());
            result.put('totalHCPs', hcpNodeMap.size());

            return result;

        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Error in getInsightNetwork: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            throw new AuraHandledException('Error retrieving insight network: ' + e.getMessage());
        }
    }

    private static String getInitials(String fullName) {
        if (String.isBlank(fullName)) {
            return '?';
        }

        List<String> nameParts = fullName.split(' ');
        String initials = '';

        for (String part : nameParts) {
            if (String.isNotBlank(part)) {
                initials += part.substring(0, 1).toUpperCase();
                if (initials.length() >= 2) {
                    break;
                }
            }
        }

        return initials;
    }

    @AuraEnabled(cacheable=true)
    public static List<MedicalInsight> getInsightsByTheme(String theme, Id accountId) {
        // Get MedicalInsight Ids linked to this account via the junction
        Set<Id> insightIds = new Set<Id>();
        if (accountId != null) {
            for (MedicalInsightAccount mia : [
                SELECT MedicalInsightId FROM MedicalInsightAccount WHERE AccountId = :accountId
            ]) {
                insightIds.add(mia.MedicalInsightId);
            }
        }

        // Query insights and filter by theme in Apex since TopicNames is a textarea
        List<MedicalInsight> allInsights;
        if (accountId != null) {
            allInsights = [
                SELECT Id, Name, Content, Sentiment__c, TopicNames, CreatedDate
                FROM MedicalInsight
                WHERE Id IN :insightIds
                ORDER BY CreatedDate DESC
            ];
        } else {
            allInsights = [
                SELECT Id, Name, Content, Sentiment__c, TopicNames, CreatedDate
                FROM MedicalInsight
                ORDER BY CreatedDate DESC
                LIMIT 1000
            ];
        }

        List<MedicalInsight> filtered = new List<MedicalInsight>();
        for (MedicalInsight mi : allInsights) {
            if (mi.TopicNames != null && mi.TopicNames.containsIgnoreCase(theme)) {
                filtered.add(mi);
            }
        }
        return filtered;
    }

    @AuraEnabled
    public static String askAgentforce(String contextJson) {
        try {
            Map<String, Object> context = (Map<String, Object>) JSON.deserializeUntyped(contextJson);
            String prompt;

            Boolean isComparison = context.containsKey('name2');
            if (isComparison) {
                String name1 = (String) context.get('name1');
                String name2 = (String) context.get('name2');
                String topics = (String) context.get('topics');
                String s1 = (String) context.get('sentiment1');
                String s2 = (String) context.get('sentiment2');
                String summaries1 = (String) context.get('summaries1');
                String summaries2 = (String) context.get('summaries2');
                prompt = 'Compare medical insights for ' + name1 + ' and ' + name2 + '. '
                    + 'Shared topics: ' + topics + '. '
                    + name1 + ' sentiment: ' + s1 + '. ' + name1 + ' insights: ' + summaries1 + '. '
                    + name2 + ' sentiment: ' + s2 + '. ' + name2 + ' insights: ' + summaries2 + '. '
                    + 'Summarize similarities and differences. Provide a recommended next step.';
            } else {
                String name = (String) context.get('name');
                String topics = (String) context.get('topics');
                String sentiment = (String) context.get('sentiment');
                String summaries = (String) context.get('summaries');
                prompt = 'Summarize medical insights for ' + name + '. '
                    + 'Topics: ' + topics + '. '
                    + 'Sentiment: ' + sentiment + '. '
                    + 'Insights: ' + summaries + '. '
                    + 'Provide recommended next steps.';
            }

            // Build the LLM generation request
            ConnectApi.EinsteinLlmGenerationsInput generationsInput = new ConnectApi.EinsteinLlmGenerationsInput();
            generationsInput.promptTextorId = prompt;
            generationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            generationsInput.additionalConfig.applicationName = 'PromptBuilderPreview';

            ConnectApi.EinsteinLLMGenerationsOutput generationsOutput = ConnectApi.EinsteinLLM.generateMessages(generationsInput);

            if (generationsOutput != null && generationsOutput.generations != null && !generationsOutput.generations.isEmpty()) {
                ConnectApi.EinsteinLLMGenerationItemOutput generation = generationsOutput.generations[0];
                return generation.text;
            }

            return 'No response generated. Please try again.';

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in askAgentforce: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            throw new AuraHandledException('Error calling Agentforce: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<MedicalInsight> getInsightsByHCP(Id hcpId) {
        Set<Id> insightIds = new Set<Id>();
        for (MedicalInsightAccount mia : [
            SELECT MedicalInsightId FROM MedicalInsightAccount WHERE AccountId = :hcpId
        ]) {
            insightIds.add(mia.MedicalInsightId);
        }
        return [
            SELECT Id, Name, Content, Sentiment__c, TopicNames
            FROM MedicalInsight
            WHERE Id IN :insightIds
            ORDER BY CreatedDate DESC
        ];
    }
}
