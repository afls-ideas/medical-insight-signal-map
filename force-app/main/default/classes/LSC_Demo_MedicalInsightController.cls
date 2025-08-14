public with sharing class LSC_Demo_MedicalInsightController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInsightNetwork(Id accountId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            List<Object> finalNodes = new List<Object>();
            List<Object> links = new List<Object>();
            
            // Query ALL medical insights
            List<Medical_Insight__c> insights = [
                SELECT Id, Name, Summary__c, Detail__c, Sentiment__c, Topic__c, 
                       Date__c, Follow_Up__c, Relevance_Score__c,
                       Account__c, Account__r.Name,
                       Captured_By__c, Captured_By__r.Name,
                       Therapeutic_Area__c, Source_Type__c
                FROM Medical_Insight__c 
                ORDER BY Date__c DESC
                LIMIT 1000
            ];
            
            // Use separate maps for HCP nodes and theme counts
            Map<String, Map<String, Object>> hcpNodeMap = new Map<String, Map<String, Object>>();
            Map<String, Integer> themeCounts = new Map<String, Integer>();
            
            // Process insights to populate HCP nodes and aggregate theme counts
            for (Medical_Insight__c insight : insights) {
                // 1. Aggregate theme counts from all insights
                if (String.isNotBlank(insight.Topic__c)) {
                    String topic = insight.Topic__c;
                    themeCounts.put(topic, themeCounts.containsKey(topic) ? themeCounts.get(topic) + 1 : 1);
                }

                // 2. Process HCP data, with a null check to prevent errors
                if (insight.Account__c != null && insight.Account__r != null) {
                    String hcpId = 'hcp_' + insight.Account__c;
                    if (!hcpNodeMap.containsKey(hcpId)) {
                        String hcpName = insight.Account__r.Name;
                        String initials = getInitials(hcpName);
                        
                        Map<String, Object> hcpNode = new Map<String, Object>{
                            'id' => hcpId,
                            'label' => hcpName,
                            'initials' => initials,
                            'type' => 'hcp',
                            'recordId' => insight.Account__c,
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
                    String sentiment = insight.Sentiment__c != null ? insight.Sentiment__c : 'Neutral';
                    sentimentCounts.put(sentiment, sentimentCounts.get(sentiment) == null ? 1 : sentimentCounts.get(sentiment) + 1);
                    
                    if (String.isNotBlank(insight.Summary__c)) {
                        ((List<String>)hcpNodeToUpdate.get('summaries')).add(insight.Summary__c);
                    }
                    
                    if (String.isNotBlank(insight.Topic__c)) {
                        List<String> themes = (List<String>)hcpNodeToUpdate.get('themes');
                        if (!themes.contains(insight.Topic__c)) {
                            themes.add(insight.Topic__c);
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
            result.put('totalInsights', insights.size());
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
                    break; // Limit to 2 initials
                }
            }
        }
        
        return initials;
    }
    
    private static Integer getHCPCount(List<Medical_Insight__c> insights) {
        Set<Id> hcpIds = new Set<Id>();
        for (Medical_Insight__c insight : insights) {
            if (insight.Account__c != null) {
                hcpIds.add(insight.Account__c);
            }
        }
        return hcpIds.size();
    }
    
    private static Integer getThemeCount(List<Medical_Insight__c> insights) {
        Set<String> themes = new Set<String>();
        for (Medical_Insight__c insight : insights) {
            if (String.isNotBlank(insight.Topic__c)) {
                themes.add(insight.Topic__c);
            }
        }
        return themes.size();
    }
    
    private static Integer getProductCount(List<Medical_Insight__c> insights) {
        return 0;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Medical_Insight__c> getInsightsByTheme(String theme, Id accountId) {
        if (accountId != null) {
            return [
                SELECT Id, Name, Summary__c, Detail__c, Sentiment__c, Topic__c, 
                       Date__c, Account__r.Name
                FROM Medical_Insight__c 
                WHERE Topic__c = :theme AND Account__c = :accountId
                ORDER BY Date__c DESC
            ];
        } else {
            return [
                SELECT Id, Name, Summary__c, Detail__c, Sentiment__c, Topic__c, 
                       Date__c, Account__r.Name
                FROM Medical_Insight__c 
                WHERE Topic__c = :theme
                ORDER BY Date__c DESC
            ];
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Medical_Insight__c> getInsightsByHCP(Id hcpId) {
        return [
            SELECT Id, Name, Summary__c, Detail__c, Sentiment__c, Topic__c, 
                   Date__c, Therapeutic_Area__c
            FROM Medical_Insight__c 
            WHERE Account__c = :hcpId
            ORDER BY Date__c DESC
        ];
    }
    
    @AuraEnabled
    public static String updateInsightAccount(Id insightId, Id newAccountId) {
        try {
            Medical_Insight__c insight = [SELECT Id, Account__c FROM Medical_Insight__c WHERE Id = :insightId LIMIT 1];
            insight.Account__c = newAccountId;
            update insight;
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
} 