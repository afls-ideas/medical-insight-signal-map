# PRD: Medical Insights Relationship Graph — Migration to Standard MedicalInsight Object

**Version:** 1.0
**Date:** 2026-03-06
**Author:** Auto-generated
**Status:** Draft

---

## 1. Executive Summary

This project migrates the **Medical Insight Signal Map** demo from the custom `Medical_Insight__c` object to the **standard `MedicalInsight` object** available in Life Sciences Cloud (260+). The standard object is purpose-built for capturing medical insights with native support for HCP account associations (via `MedicalInsightAccount`), product tagging (via `MedicalInsightProduct`), topic categorization (`TopicNames`), visit linkage, upvoting, and hierarchical parent-child insights. This is a near-perfect fit for the demo, requiring minimal custom fields.

---

## 2. Current State

### 2.1 Custom Object: `Medical_Insight__c`

| Field | Type | Purpose |
|---|---|---|
| `Name` | Auto-Number (MI-{0000}) | Record identifier |
| `Account__c` | Lookup(Account) | HCP reference |
| `Topic__c` | Text(255) | Theme/category (e.g., "Safety Profile", "Early Intervention Potential") |
| `Sentiment__c` | Picklist | Positive, Neutral, Negative |
| `Summary__c` | TextArea | Brief insight summary |
| `Detail__c` | Rich Text(32768) | Full-text detailed insight |
| `Date__c` | Date | When the insight was gathered |
| `Follow_Up__c` | TextArea | Follow-up action required |
| `Relevance_Score__c` | Percent | AI/manual relevance score |
| `Therapeutic_Area__c` | Picklist | Rheumatology, Oncology, etc. (12 values) |
| `Source_Type__c` | Picklist | 1:1 Visit, Congress, Advisory Board, etc. (8 values) |
| `Captured_By__c` | Lookup(User) | User who logged the insight |

### 2.2 LWC Component: `lscMobileInline_medicalInsightGraph`

- D3.js v7 force-directed graph visualization
- Nodes = HCPs + Themes, Links = shared themes between HCPs
- Sentiment filtering (Positive/Neutral/Negative)
- Click-to-explore details, zoom/pan
- Deployed on Account record pages

### 2.3 Apex Controller: `LSC_Demo_MedicalInsightController`

- `getInsightNetwork(Id accountId)` — Builds graph data from all Medical_Insight__c records
- `getInsightsByTheme(String theme, Id accountId)` — Filter by theme
- `getInsightsByHCP(Id hcpId)` — Filter by HCP
- `updateInsightAccount(Id insightId, Id newAccountId)` — Reassign insight

### 2.4 Existing Demo Data

**Two CSV datasets:**
- `seeddata/medical_insights_demo.csv` — 13 records, 5 HCPs, 8 topics
- `force-app/main/default/data/medical_insights_final.csv` — 18 records, 6 HCPs, 9 topics

**Unique Topics (Themes) across both datasets:**
1. Efficacy in Refractory RA
2. Early Intervention Potential
3. Comparative Data
4. Real-World Evidence
5. Safety Profile
6. Cost Effectiveness
7. Patient Access
8. Quality of Life
9. Mechanism Doubts
10. Immunogenicity
11. Multi-Indication Interest

---

## 3. Target State: Standard MedicalInsight Object

### 3.1 Standard MedicalInsight Object Schema

The `MedicalInsight` object (API name: `MedicalInsight`, key prefix: `1LR`) is a **standard, non-custom** object in Life Sciences Cloud 260+.

| Field | Type | Required | Updateable | Notes |
|---|---|---|---|---|
| `Name` | String | **Yes** | Yes | User-editable name (not auto-number) |
| `Content` | TextArea | **Yes** | Yes | The insight content/body |
| `SourceType` | Picklist | **Yes** | Yes | Visit, Account, Meeting, HomePage, MedicalInsightsTab |
| `OwnerId` | Lookup(User) | **Yes** | Yes | Record owner |
| `TopicNames` | TextArea | No | Yes | Topic/theme names (text field) |
| `ParentMedicalInsightId` | Lookup(MedicalInsight) | No | Yes | Enables hierarchical insights |
| `VisitId` | Lookup(Visit) | No | Yes | Links to visit records |
| `DefaultRank` | Integer | No | Yes | Ordering/ranking |
| `UpvoteCount` | Double | No | Yes | Community upvoting |
| `LastUpvotedDate` | DateTime | No | Yes | Last upvote timestamp |
| `ChildMedicalInsightCount` | Double | No | Yes | Count of child insights |
| `GoalDefinitionCount` | Double | No | Yes | Linked goal definitions |

### 3.2 Child Object: MedicalInsightAccount (Junction)

Links a MedicalInsight to one or more Accounts (HCPs).

| Field | Type | Required | Notes |
|---|---|---|---|
| `MedicalInsightId` | Lookup(MedicalInsight) | **Yes** | Parent insight |
| `AccountId` | Lookup(Account) | **Yes** | HCP account |
| `ReasonType` | Picklist | No | Reason for association |

**Key advantage:** This is a **many-to-many** junction — a single insight can be associated with multiple HCPs, unlike the custom object's single `Account__c` lookup.

### 3.3 Child Object: MedicalInsightProduct (Junction)

Links a MedicalInsight to one or more Products.

| Field | Type | Required | Notes |
|---|---|---|---|
| `MedicalInsightId` | Lookup(MedicalInsight) | **Yes** | Parent insight |
| `ProductId` | Lookup(Product2) | **Yes** | Product reference |
| `DisplayName` | String | No | Display label |

### 3.4 Child Object: MedicalInsightGoalDef

Links a MedicalInsight to Goal Definitions.

| Field | Type | Required | Notes |
|---|---|---|---|
| `MedicalInsightId` | Lookup(MedicalInsight) | **Yes** | Parent insight |
| `GoalDefinitionId` | Lookup(GoalDefinition) | No | Goal reference |

### 3.5 Supporting Objects

- **MedicalInsightEvent** — Platform event for real-time sync (Insert, Update, Delete operations, Web/Mobile source)
- **MedicalInsightFeed** — Chatter feed
- **MedicalInsightHistory** — Field history tracking
- **MedicalInsightShare** — Sharing rules
- **UserReaction** — Upvote/reaction tracking via `SourceReferenceRecordId`

---

## 4. Field Mapping & Gap Analysis

### 4.1 Direct Mappings (No Custom Fields Needed)

| Medical_Insight__c Field | MedicalInsight Field | Notes |
|---|---|---|
| `Summary__c` | `Name` | The `Name` field is user-editable text — perfect for the insight summary title |
| `Detail__c` | `Content` | Required textarea — maps directly to full insight detail |
| `Topic__c` | `TopicNames` | Standard field for topic/theme names |
| `Source_Type__c` | `SourceType` | Partial mapping with value translation (see 4.2) |
| `Captured_By__c` | `OwnerId` | Record owner = person who captured the insight |
| `Account__c` | **MedicalInsightAccount** junction | Upgraded from single lookup to many-to-many |

### 4.2 Mappable with Value Translation

**Source_Type__c → SourceType mapping:**

| Custom Source_Type__c | Standard SourceType | Notes |
|---|---|---|
| 1:1 Visit | **Visit** | Direct fit |
| Phone Call | **Account** | Account-context interaction |
| Email | **Account** | Account-context interaction |
| Congress | **Meeting** | Meeting/event context |
| Advisory Board | **Meeting** | Meeting/event context |
| Conference | **Meeting** | Meeting/event context |
| Literature Review | **MedicalInsightsTab** | Research/desk review |
| Other | **MedicalInsightsTab** | General entry |

### 4.3 Fields Requiring Custom Fields on MedicalInsight

| Medical_Insight__c Field | Proposed Custom Field | API Name | Type | Justification |
|---|---|---|---|---|
| **`Sentiment__c`** | **Sentiment** | `Sentiment__c` | Picklist (Positive, Neutral, Negative) | **CRITICAL** — Used for sentiment filtering and node coloring in the graph. No standard equivalent exists. |
| `Therapeutic_Area__c` | **Therapeutic Area** | `TherapeuticArea__c` | Picklist (12 values) | Used in HCP detail views; valuable for filtering. |
| `Relevance_Score__c` | **Relevance Score** | `RelevanceScore__c` | Percent(5,2) | Used for potential future sorting/weighting. |
| `Date__c` | **Insight Date** | `InsightDate__c` | Date | The `CreatedDate` may suffice, but explicit date allows backdating historical insights. |
| `Follow_Up__c` | **Follow Up** | `FollowUp__c` | TextArea | Follow-up action text. Could alternatively use Tasks/Activities. |

### 4.4 Fields That Can Be Dropped or Mapped to Standard Features

| Medical_Insight__c Field | Decision | Rationale |
|---|---|---|
| `Account__c` (single lookup) | **Replaced by `MedicalInsightAccount`** | Upgraded to many-to-many junction — an insight can now link to multiple HCPs |
| `Captured_By__c` | **Map to `OwnerId`** | Standard owner field serves the same purpose |
| `Follow_Up__c` | **Consider using Tasks** | Standard Salesforce Tasks via `ActivityHistories` child relationship may be more appropriate |
| `Name` (auto-number MI-####) | **Map to `Name`** (user text) | Standard `Name` is editable text, not auto-number. Use the summary as the name. |

### 4.5 New Capabilities Gained from Standard MedicalInsight

| Capability | Benefit |
|---|---|
| **Many-to-many HCP associations** (`MedicalInsightAccount`) | A single insight can reference multiple HCPs — richer graph connections |
| **Product associations** (`MedicalInsightProduct`) | Link insights to products (e.g., Immunexis) — enables product-filtered views |
| **Hierarchical insights** (`ParentMedicalInsightId`) | Group related insights under a parent — supports insight threads |
| **Visit linkage** (`VisitId`) | Connect insights directly to visit records |
| **Upvoting** (`UpvoteCount`, `UserReaction`) | MSLs can upvote insights — surfaces most valuable ones |
| **Goal alignment** (`MedicalInsightGoalDef`) | Link insights to goal definitions for activity tracking |
| **Platform events** (`MedicalInsightEvent`) | Real-time sync for Web/Mobile changes |
| **Sharing model** (`MedicalInsightShare`) | Granular sharing rules |
| **Field history** (`MedicalInsightHistory`) | Track changes over time |
| **Topic names** (`TopicNames`) | Standard field for categorization — no custom field needed for topics |

---

## 5. Custom Fields to Create

### 5.1 Required Custom Field (Must Have)

```
MedicalInsight.Sentiment__c  — Picklist  — "Sentiment"
  Values: Positive, Neutral, Negative
```

This is the **only non-negotiable custom field**. The graph visualization's sentiment filter and node coloring depend on it. Everything else maps to standard fields.

### 5.2 Recommended Custom Fields (Should Have)

```
MedicalInsight.TherapeuticArea__c  — Picklist  — "Therapeutic Area"
  Values: Rheumatology, Oncology, Cardiology, Neurology, Dermatology,
          Endocrinology, Gastroenterology, Hematology, Infectious Disease,
          Pulmonology, Immunology, Other

MedicalInsight.InsightDate__c      — Date      — "Insight Date"
  (Only if CreatedDate is insufficient for backdating historical data)
```

### 5.3 Optional Custom Fields (Nice to Have)

```
MedicalInsight.RelevanceScore__c   — Percent(5,2)  — "Relevance Score"
MedicalInsight.FollowUp__c        — TextArea       — "Follow Up"
```

**Total: 1 required + 2 recommended + 2 optional = 5 custom fields max (only 1 truly required)**

This is a dramatic improvement over the Inquiry approach which needed 4+ mandatory custom fields.

---

## 6. Code Changes Required

### 6.1 Apex Controller Changes

**File:** `LSC_Demo_MedicalInsightController.cls`

The controller can keep a similar name since the target object is still "Medical Insight." The main changes are SOQL queries and field references.

#### 6.1.1 `getInsightNetwork()` — Main Graph Builder

```sql
-- Before (custom object, single Account lookup):
SELECT Id, Name, Summary__c, Detail__c, Sentiment__c, Topic__c,
       Date__c, Account__c, Account__r.Name, Therapeutic_Area__c
FROM Medical_Insight__c
ORDER BY Date__c DESC LIMIT 1000

-- After (standard object, junction to Accounts):
SELECT Id, Name, Content, Sentiment__c, TopicNames,
       CreatedDate, TherapeuticArea__c,
       (SELECT AccountId, Account.Name FROM MedicalInsightAccounts)
FROM MedicalInsight
ORDER BY CreatedDate DESC LIMIT 1000
```

**Logic changes:**
- Each `MedicalInsight` record can have **multiple** HCP associations via the `MedicalInsightAccounts` subquery
- The graph builder must iterate over each `MedicalInsightAccount` to create HCP nodes
- Theme extraction now reads from `TopicNames` (may contain multiple comma-separated topics)
- HCP-to-HCP links are now richer — two HCPs sharing an insight are directly linked (not just sharing themes)

#### 6.1.2 `getInsightsByTheme()` — Theme Filter

```sql
-- After:
SELECT Id, Name, Content, Sentiment__c, TopicNames, CreatedDate,
       (SELECT AccountId, Account.Name FROM MedicalInsightAccounts)
FROM MedicalInsight
WHERE TopicNames LIKE :themePattern
ORDER BY CreatedDate DESC
```

#### 6.1.3 `getInsightsByHCP()` — HCP Filter

```sql
-- After (query via junction):
SELECT Id, MedicalInsightId, MedicalInsight.Name, MedicalInsight.Content,
       MedicalInsight.Sentiment__c, MedicalInsight.TopicNames,
       MedicalInsight.CreatedDate, MedicalInsight.TherapeuticArea__c
FROM MedicalInsightAccount
WHERE AccountId = :hcpId
ORDER BY MedicalInsight.CreatedDate DESC
```

#### 6.1.4 New Method: `updateInsightAccount()` — Reassign

```apex
// Before: Simple field update on Medical_Insight__c.Account__c
// After: Insert/delete MedicalInsightAccount junction records
```

### 6.2 LWC Changes

**File:** `lscMobileInline_medicalInsightGraph.js`

| Current Reference | New Reference | Notes |
|---|---|---|
| `item.Account__c` | `item.MedicalInsightAccounts[0].AccountId` | Now an array — may have multiple |
| `item.Account__r.Name` | `item.MedicalInsightAccounts[0].Account.Name` | Iterate for multi-HCP |
| `item.Topic__c` | `item.TopicNames` | Standard field, may be multi-value |
| `item.Sentiment__c` | `item.Sentiment__c` | Unchanged (custom field) |
| `item.Summary__c` | `item.Name` | Name field holds the summary |
| `item.Detail__c` | `item.Content` | Standard content field |
| `item.Date__c` | `item.CreatedDate` (or `InsightDate__c`) | Standard or custom date |
| `item.Therapeutic_Area__c` | `item.TherapeuticArea__c` | Custom field |

**Graph enhancement opportunity:** Since `MedicalInsightAccount` is many-to-many, a single insight can now create links between multiple HCPs directly (not just via shared themes). This could make the graph richer.

### 6.3 Metadata Changes

- Remove `Medical_Insight__c` custom object definition and all its field definitions
- Add custom field metadata:
  - `MedicalInsight.Sentiment__c` (Picklist)
  - `MedicalInsight.TherapeuticArea__c` (Picklist)
  - `MedicalInsight.InsightDate__c` (Date) — if needed
  - `MedicalInsight.RelevanceScore__c` (Percent) — optional
  - `MedicalInsight.FollowUp__c` (TextArea) — optional
- LWC meta XML: No changes needed (still targets Account record page)

---

## 7. Data Migration Plan

### 7.1 Data Model Change: One-to-Many → Many-to-Many

The biggest structural change is how HCPs are associated with insights:

```
BEFORE:  Medical_Insight__c.Account__c  →  Account  (1:1 lookup)
AFTER:   MedicalInsight  ←  MedicalInsightAccount  →  Account  (M:N junction)
```

This means data loading is a **two-step process**: create the MedicalInsight records first, then create MedicalInsightAccount junction records.

### 7.2 Step 1: Create MedicalInsight Records

**CSV columns for MedicalInsight:**

| Source CSV Column | Target CSV Column | Transformation |
|---|---|---|
| `Summary__c` | `Name` | Direct copy (insight title) |
| `Detail__c` | `Content` | Direct copy (required field) |
| `Sentiment__c` | `Sentiment__c` | Direct copy (custom field) |
| `Topic__c` | `TopicNames` | Direct copy |
| `Therapeutic_Area__c` | `TherapeuticArea__c` | Direct copy (custom field) |
| `Source_Type__c` | `SourceType` | Map per table in 4.2 |
| `Date__c` | `InsightDate__c` | Direct copy (custom field, if created) |
| — | `SourceType` | Required — set based on Source_Type mapping |

**Sample transformed record:**
```
Name: "Favorable response in RA patients unresponsive to prior DMARDs"
Content: "Aaron Morita has observed that patients with long-standing RA..."
Sentiment__c: Positive
TopicNames: "Efficacy in Refractory RA"
TherapeuticArea__c: Rheumatology
SourceType: Visit
InsightDate__c: 2025-06-10
```

### 7.3 Step 2: Create MedicalInsightAccount Junction Records

After loading MedicalInsight records, create junction records:

```
MedicalInsightId: <newly created MedicalInsight Id>
AccountId: 001YH000000MLmAYAW  (original Account__c value)
```

**Loading approach:**
1. Load MedicalInsight records via CSV, capture the new IDs
2. Create a second CSV mapping each MedicalInsight ID to its Account ID
3. Load MedicalInsightAccount records

Alternatively, use an Apex script that does both in a single transaction.

### 7.4 Step 3 (Optional): Create MedicalInsightProduct Records

If Immunexis exists as a Product2 record, link all insights to it:

```
MedicalInsightId: <MedicalInsight Id>
ProductId: <Immunexis Product2 Id>
```

### 7.5 Data Volume

| Dataset | Insight Records | Junction Records | Total DML |
|---|---|---|---|
| seeddata (recommended) | 13 | 13 (1 HCP each) | 26 |
| data/final | 18 | 18 (1 HCP each) | 36 |

### 7.6 Apex Data Loading Script (Recommended Approach)

```apex
// Pseudocode — creates insights and junctions in one script
List<MedicalInsight> insights = new List<MedicalInsight>();
Map<Integer, Id> accountMap = new Map<Integer, Id>();

// Build insight records
MedicalInsight mi1 = new MedicalInsight();
mi1.Name = 'Favorable response in RA patients unresponsive to prior DMARDs';
mi1.Content = 'Aaron Morita has observed...';
mi1.Sentiment__c = 'Positive';
mi1.TopicNames = 'Efficacy in Refractory RA';
mi1.SourceType = 'Visit';
insights.add(mi1);
accountMap.put(0, '001YH000000MLmAYAW');
// ... repeat for all records

insert insights;

// Build junction records
List<MedicalInsightAccount> junctions = new List<MedicalInsightAccount>();
for (Integer i = 0; i < insights.size(); i++) {
    MedicalInsightAccount mia = new MedicalInsightAccount();
    mia.MedicalInsightId = insights[i].Id;
    mia.AccountId = accountMap.get(i);
    junctions.add(mia);
}
insert junctions;
```

---

## 8. Risks and Considerations

### 8.1 No Required Case/Parent Dependency

Unlike the Inquiry object, `MedicalInsight` has **no required parent record** (no CaseId equivalent). The only required fields are `Name`, `Content`, and `SourceType`. This is a major simplification.

### 8.2 TopicNames is a Text Field, Not a Picklist

`TopicNames` is a textarea, not a controlled picklist. This means:
- **Pro:** Flexible — any topic string can be stored without picklist management
- **Con:** No built-in validation — typos could create duplicate themes
- **Mitigation:** The LWC already normalizes theme names (lowercase comparison). Consider adding validation in the Apex controller.

### 8.3 Rich Text → Plain Text

`Detail__c` is Rich Text (HTML). `Content` on MedicalInsight is plain TextArea. The existing demo data doesn't use HTML formatting, so this is a non-issue for migration. For future use, consider a custom Rich Text field.

### 8.4 Account Association Change (Lookup → Junction)

The graph builder logic needs to handle the many-to-many junction pattern:
- **Before:** `insight.Account__c` gives one HCP per insight
- **After:** `insight.MedicalInsightAccounts` gives a list of HCPs per insight

This is actually an **enhancement** — the graph becomes richer because an insight can connect multiple HCPs directly.

### 8.5 SourceType Values Differ

The standard `SourceType` picklist has 5 values (Visit, Account, Meeting, HomePage, MedicalInsightsTab) vs. the custom 8 values (1:1 Visit, Congress, Advisory Board, etc.). The mapping in section 4.2 handles this, but some specificity is lost.

---

## 9. Comparison: Custom Object vs Standard MedicalInsight

| Aspect | Custom `Medical_Insight__c` | Standard `MedicalInsight` |
|---|---|---|
| **Custom fields needed** | N/A (all custom) | **1 required** (Sentiment), 2-4 optional |
| **HCP association** | Single lookup | **Many-to-many** junction |
| **Product association** | None | **Built-in** (MedicalInsightProduct) |
| **Topic/Theme field** | Custom `Topic__c` | **Standard `TopicNames`** |
| **Content field** | Custom `Detail__c` | **Standard `Content`** |
| **Visit linkage** | None | **Built-in** (VisitId) |
| **Upvoting** | None | **Built-in** |
| **Hierarchical** | No | **Yes** (ParentMedicalInsightId) |
| **Platform events** | None | **Built-in** (MedicalInsightEvent) |
| **Required parent** | None | **None** |
| **Sharing model** | ControlledByParent | **Private** (granular sharing) |
| **Goal alignment** | None | **Built-in** (MedicalInsightGoalDef) |

---

## 10. Implementation Phases

### Phase 1: Foundation
- [ ] Create custom field: `MedicalInsight.Sentiment__c` (Picklist: Positive, Neutral, Negative)
- [ ] Create custom field: `MedicalInsight.TherapeuticArea__c` (Picklist: 12 therapeutic areas)
- [ ] Create custom field: `MedicalInsight.InsightDate__c` (Date) — if backdating is needed
- [ ] Load demo data into MedicalInsight + MedicalInsightAccount via Apex script
- [ ] Optionally load MedicalInsightProduct records (link to Immunexis)
- [ ] Verify data with SOQL queries

### Phase 2: Code Migration
- [ ] Update Apex controller SOQL queries to target `MedicalInsight` with `MedicalInsightAccounts` subquery
- [ ] Refactor graph builder logic for many-to-many HCP associations
- [ ] Update LWC JavaScript field references (`Content`, `TopicNames`, `Name`, etc.)
- [ ] Update LWC to handle multi-HCP insights (new link types in graph)
- [ ] Test graph rendering with standard object data

### Phase 3: Cleanup & Enhancement
- [ ] Remove `Medical_Insight__c` custom object metadata
- [ ] Remove old Apex controller (or rename)
- [ ] Update seed data scripts for MedicalInsight format
- [ ] Update README and documentation
- [ ] (Enhancement) Add product-filtered graph view using MedicalInsightProduct
- [ ] (Enhancement) Add upvote integration to surface high-value insights
- [ ] (Enhancement) Leverage hierarchical insights for insight threading

---

## 11. Summary

### Custom Fields Needed

| # | Field | API Name | Type | Required for Graph |
|---|---|---|---|---|
| 1 | **Sentiment** | `Sentiment__c` | Picklist (Positive, Neutral, Negative) | **Yes** — sentiment filter & node colors |
| 2 | Therapeutic Area | `TherapeuticArea__c` | Picklist (12 values) | No — detail view only |
| 3 | Insight Date | `InsightDate__c` | Date | No — only if backdating needed |
| 4 | Relevance Score | `RelevanceScore__c` | Percent(5,2) | No — future use |
| 5 | Follow Up | `FollowUp__c` | TextArea | No — consider using Tasks instead |

**Answer: Yes, we need custom fields, but only 1 is truly required (`Sentiment__c`).** The standard MedicalInsight object already has `TopicNames` for themes, `Content` for detail text, and `Name` for summaries. The `MedicalInsightAccount` junction replaces `Account__c` with a superior many-to-many model. This is a near-perfect fit requiring minimal customization.

### Key Benefits of Migration

1. **Only 1 mandatory custom field** vs. the entire custom object (11 custom fields)
2. **Many-to-many HCP associations** — richer graph connections
3. **Built-in product linking** — tag insights to Immunexis
4. **Upvoting, hierarchy, visit linkage, goal alignment** — all out of the box
5. **Platform events** — real-time sync for mobile
6. **No required parent record** — simpler than Inquiry (which requires a Case)
7. **Standard object = upgradeable** — benefits from future LSC releases automatically
