import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInsightNetwork from '@salesforce/apex/LSC_Demo_MedicalInsightController.getInsightNetwork';
import getInsightsByTheme from '@salesforce/apex/LSC_Demo_MedicalInsightController.getInsightsByTheme';
import askAgentforce from '@salesforce/apex/LSC_Demo_MedicalInsightController.askAgentforce';
import d3 from './d3Lib';

export default class MedicalInsightGraph extends NavigationMixin(LightningElement) {
    @api recordId; // Account Id for filtering
    @api mobileHeight = 500; // Height of the component on mobile devices
    @track isLoading = true;
    @track error;
    @track graphData = { nodes: [], links: [] };
    @track filteredData = { nodes: [], links: [] };
    @track currentFilter = 'all';
    
    // Interactive state
    @track selectedNode = null;
    @track selectedTheme = null;
    @track selectedLink = null;
    @track themes = [];
    @track relatedHCPs = [];
    @track sharedThemes = [];
    @track selectedThemeFromList = null;

    // Agentforce modal state
    @track showAgentforceModal = false;
    @track agentforceResponse = '';
    @track agentforceLoading = false;

    // Button variants for filtering
    @track allInsightsVariant = 'brand';
    @track positiveVariant = 'neutral';
    @track neutralVariant = 'neutral';
    @track negativeVariant = 'neutral';
    
    // D3.js variables
    svg;
    simulation;
    tooltip;
    zoom;
    graphContainer;
    _d3Initialized = false;
    
    // Graph dimensions
    width = 800;
    height = 600;
    
    // Color scales
    nodeColors = {
        hcp: '#4A90E2',
        theme: '#F5A623',
        product: '#7ED321',
        positive: '#9C27B0',
        neutral: '#FFC107',
        negative: '#F44336'
    };
    
    // Debug getter to see selectedNode structure
    get debugSelectedNode() {
        console.log('selectedNode in template:', this.selectedNode);
        console.log('selectedNode.sentimentClass:', this.selectedNode?.sentimentClass);
        console.log('selectedNode.sentiment:', this.selectedNode?.sentiment);
        return this.selectedNode;
    }
    
    // Computed property for sentiment pill class
    get sentimentPillClass() {
        if (!this.selectedNode) return 'sentiment-pill neutral';
        const sentimentClass = this.selectedNode.sentimentClass || this.getSentimentClass(this.selectedNode.sentiment);
        return `sentiment-pill ${sentimentClass}`;
    }
    
    // Computed property for theme sentiment pill class
    get themeSentimentPillClass() {
        if (!this.selectedTheme) return 'theme-sentiment-pill neutral';
        const sentimentClass = this.selectedTheme.sentimentClass || this.getSentimentClass(this.selectedTheme.sentiment);
        return `theme-sentiment-pill ${sentimentClass}`;
    }
    
    // Computed property for HCP sentiment pill class
    get hcpSentimentPillClass() {
        if (!this.relatedHCPs || this.relatedHCPs.length === 0) return 'hcp-sentiment-pill neutral';
        // This will be handled in the template for each HCP individually
        return 'hcp-sentiment-pill';
    }
    
    // Helper method to get sentiment class for a specific HCP
    getHcpSentimentClass(hcp) {
        if (!hcp) return 'neutral';
        return hcp.sentimentClass || this.getSentimentClass(hcp.sentiment);
    }
    
    // Getter for available themes from the graph data
    get availableThemes() {
        if (!this.graphData || !this.graphData.nodes) {
            return [];
        }

        // Use the 'theme' nodes directly from the graph data, which have the correct insight counts
        return this.graphData.nodes
            .filter(node => node.type === 'theme' && node.insightCount > 0)
            .map(theme => ({
                ...theme,
                displayLabel: `${theme.label} (${theme.insightCount})`,
                cssClass: this.getThemePillClass(theme)
            }))
            .sort((a, b) => b.insightCount - a.insightCount);
    }
    
    // Helper method to get theme pill CSS class
    getThemePillClass(theme) {
        const baseClass = 'theme-pill';
        const isSelected = this.selectedThemeFromList && this.selectedThemeFromList.id === theme.id;
        return isSelected ? `${baseClass} selected` : baseClass;
    }
    
    renderedCallback() {
        if (this._d3Initialized) {
            return;
        }
        this._d3Initialized = true;
        this.isLoading = true;

        this.initializeGraph();
        this.loadInsightData();
    }
    
    initializeGraph() {
        const svgElement = this.template.querySelector('svg');
        this.svg = d3.select(svgElement)
            .attr('width', this.width)
            .attr('height', this.height);

        // Create tooltip
        this.tooltip = d3.select('body').append('div')
            .attr('class', 'tooltip')
            .style('position', 'absolute')
            .style('background', 'rgba(0, 0, 0, 0.8)')
            .style('color', 'white')
            .style('padding', '8px')
            .style('border-radius', '4px')
            .style('font-size', '12px')
            .style('pointer-events', 'none')
            .style('opacity', 0)
            .style('transition', 'opacity 0.2s')
            .style('z-index', '1000');
    }
    
    async loadInsightData() {
        try {
            this.error = null;
            const data = await getInsightNetwork({ accountId: this.recordId });
            
            // --- Start Debugging ---
            console.log('Raw data from Apex:', JSON.stringify(data, null, 2));
            // --- End Debugging ---

            this.graphData = data;
            this.filteredData = data;
            
            // Populate themes list
            this.themes = this.graphData.nodes
                .filter(node => node.type === 'theme')
                .map(theme => ({
                    ...theme,
                    sentimentClass: this.getSentimentClass(theme.sentiment)
                }))
                .sort((a, b) => (b.insightCount || 0) - (a.insightCount || 0));
                
        } catch (error) {
            // --- Start Debugging ---
            console.error('Error loading insight data:', JSON.stringify(error, null, 2));
            // --- End Debugging ---
            this.error = error.body?.message || 'Error loading insight data';
            this.showToast('Error', this.error, 'error');
        } finally {
            this.isLoading = false;
            // Wait for DOM to update before rendering
            await Promise.resolve();
            this.renderGraph();
            
            // Auto-select Aaron Morita's node after graph is rendered
            this.autoSelectDefaultNode();
        }
    }
    
    renderGraph() {
        try {
            console.log('Starting renderGraph with data:', this.graphData);
            
            if (!this.graphData || !this.graphData.nodes || !this.graphData.links) {
                console.error('Invalid graph data structure:', this.graphData);
                return;
            }

            console.log('D3 object available:', typeof d3 !== 'undefined');
            console.log('Container element:', this.template.querySelector('.graph-wrapper'));

            const container = this.template.querySelector('.graph-wrapper');
            if (!container) {
                console.error('Graph wrapper not found');
                return;
            }

            // Clear previous graph
            container.innerHTML = '';
            console.log('Container cleared');

            const width = container.clientWidth || 800;
            const height = container.clientHeight || 600;
            console.log('Dimensions:', width, 'x', height);

            // Create deep copies of data to prevent "object is not extensible" error
            const nodes = JSON.parse(JSON.stringify(this.graphData.nodes));
            const links = JSON.parse(JSON.stringify(this.graphData.links));
            console.log('Data copied successfully');

            // Create SVG
            const svg = d3.select(container)
                .append('svg')
                .attr('width', '100%')
                .attr('height', '100%')
                .attr('viewBox', `0 0 ${width} ${height}`)
                .style('display', 'block')
                .style('background', 'white');
            console.log('SVG created');
            
            // Add a container <g> element for zooming and panning
            this.graphContainer = svg.append('g');

            // Setup zoom behavior
            this.zoom = d3.zoom()
                .scaleExtent([0.1, 4]) // Min/max zoom levels
                .on('zoom', (event) => {
                    if (this.graphContainer) {
                        this.graphContainer.attr('transform', event.transform);
                    }
                });

            // Apply zoom to the SVG element
            svg.call(this.zoom);
            
            // Store SVG reference for other methods to use
            this.svg = svg;

            // Create links
            const linkElements = this.graphContainer.append('g')
                .selectAll('line')
                .data(links)
                .enter().append('line')
                .attr('stroke', '#999')
                .attr('stroke-opacity', 0.6)
                .attr('stroke-width', d => Math.max(6, Math.sqrt(d.value) * 4)) // Make links thicker for easier clicking
                .style('cursor', 'pointer')
                .on('click', function(event, d) {
                    console.log('Link click event triggered');
                    this.handleLinkClick(d);
                }.bind(this))
                .on('mouseover', function(event, d) {
                    d3.select(this)
                        .attr('stroke-opacity', 1)
                        .attr('stroke-width', Math.max(10, Math.sqrt(d.value) * 6));
                })
                .on('mouseout', function(event, d) {
                    d3.select(this)
                        .attr('stroke-opacity', 0.6)
                        .attr('stroke-width', Math.max(6, Math.sqrt(d.value) * 4));
                });
            console.log('Links created');

            // Create transparent click areas for easier link interaction
            const linkClickAreas = this.graphContainer.append('g')
                .selectAll('line')
                .data(links)
                .enter().append('line')
                .attr('stroke', 'transparent')
                .attr('stroke-width', 40) // Wide transparent area for easy clicking
                .style('cursor', 'pointer')
                .on('click', function(event, d) {
                    console.log('Link click area event triggered');
                    this.handleLinkClick(d);
                }.bind(this));
            console.log('Link click areas created');

            // Create nodes with initials
            const nodeGroup = this.graphContainer.append('g')
                .selectAll('g')
                .data(nodes)
                .enter().append('g')
                .attr('class', 'node')
                .style('cursor', 'pointer')
                .on('click', (event, d) => this.handleNodeClick(d))
                .call(d3.drag()
                    .on('start', this.dragstarted.bind(this))
                    .on('drag', this.dragged.bind(this))
                    .on('end', this.dragended.bind(this)));
            
            // Scale circle radius by insight count (min 20, max 45)
            const insightCounts = nodes.map(d => d.insightCount || 0);
            const maxInsights = Math.max(...insightCounts, 1);
            const radiusScale = d3.scaleLinear()
                .domain([0, maxInsights])
                .range([20, 45]);

            // Add circles
            nodeGroup.append('circle')
                .attr('r', d => radiusScale(d.insightCount || 0))
                .attr('fill', '#69b3a2')
                .attr('stroke', '#fff')
                .attr('stroke-width', 3);
            
            // Add initials text
            nodeGroup.append('text')
                .text(d => d.initials || '?')
                .attr('text-anchor', 'middle')
                .attr('dy', '0.35em')
                .attr('font-size', '14px')
                .attr('font-weight', 'bold')
                .attr('fill', '#fff');
            
            console.log('Nodes with initials created');

            // Add tooltips
            nodeGroup.append('title')
                .text(d => `${d.label}\nInsights: ${d.insightCount || 0}\nSentiment: ${d.sentiment || 'N/A'}`);
            console.log('Tooltips added');
            
            // Create force simulation
            this.simulation = d3.forceSimulation(nodes)
                .force('link', d3.forceLink(links).id(d => d.id).distance(250))
                .force('charge', d3.forceManyBody().strength(-250))
                .force('center', d3.forceCenter(width / 2, height / 2))
                .force('collision', d3.forceCollide().radius(d => radiusScale(d.insightCount || 0) + 10));

            // Update positions on simulation tick
            this.simulation.on('tick', () => {
                linkElements
                    .attr('x1', d => d.source.x)
                    .attr('y1', d => d.source.y)
                    .attr('x2', d => d.target.x)
                    .attr('y2', d => d.target.y);
                
                linkClickAreas
                    .attr('x1', d => d.source.x)
                    .attr('y1', d => d.source.y)
                    .attr('x2', d => d.target.x)
                    .attr('y2', d => d.target.y);

                nodeGroup
                    .attr('transform', d => `translate(${d.x},${d.y})`);
            });
            console.log('Simulation tick handler set');

            console.log('Graph rendering completed successfully');
            
        } catch (error) {
            console.error('Error in renderGraph:', error);
            console.error('Error stack:', error.stack);
            throw error;
        }
    }
    
    getNodeRadius(node) {
        switch (node.type) {
            case 'hcp': return 15;
            case 'theme': return 20;
            case 'product': return 12;
            default: return 10;
        }
    }
    
    getNodeColor(node) {
        if (node.sentiment) {
            return this.nodeColors[node.sentiment.toLowerCase()];
        }
        return this.nodeColors[node.type] || '#ccc';
    }
    
    showTooltip(event, node) {
        const tooltipContent = this.createTooltipContent(node);
        this.tooltip.html(tooltipContent)
            .style('left', (event.pageX + 10) + 'px')
            .style('top', (event.pageY - 10) + 'px')
            .style('opacity', 1);
    }
    
    hideTooltip() {
        this.tooltip.style('opacity', 0);
    }
    
    createTooltipContent(node) {
        let content = `<strong>${node.label}</strong><br>`;
        content += `Type: ${node.type.charAt(0).toUpperCase() + node.type.slice(1)}<br>`;
        
        if (node.sentiment) {
            content += `Sentiment: ${node.sentiment}<br>`;
        }
        
        if (node.insightCount) {
            content += `Insights: ${node.insightCount}<br>`;
        }
        
        if (node.summaries && node.summaries.length > 0) {
            const firstSummary = node.summaries[0];
            content += `Summary: ${firstSummary.substring(0, 100)}...`;
            if (node.summaries.length > 1) {
                content += ` (+${node.summaries.length - 1} more)`;
            }
        }
        
        return content;
    }
    
    handleNodeClick(node) {
        console.log('Node clicked:', node);
        console.log('Node sentiment:', node.sentiment);
        console.log('Node sentiment class:', this.getSentimentClass(node.sentiment));
        
        // Create a copy of the node with sentimentClass added
        this.selectedNode = {
            ...node,
            sentimentClass: this.getSentimentClass(node.sentiment)
        };
        
        this.selectedTheme = null;
        this.selectedLink = null; // Clear link selection
        this.relatedHCPs = [];
        this.sharedThemes = []; // Clear shared themes
        
        // Reset all nodes to default color first
        this.resetNodeColors();
        
        // Reset link colors to default
        if (this.svg) {
            this.svg.selectAll('line')
                .attr('stroke', '#999')
                .attr('stroke-opacity', 0.6)
                .attr('stroke-width', d => Math.max(3, Math.sqrt(d.value) * 2));
        }
        
        // Highlight the selected node with blue color
        this.highlightSelectedNode(node.id);
        
        // Populate themes for this HCP
        if (node.themes && node.themes.length > 0) {
            this.themes = node.themes.map(theme => ({
                id: theme,
                label: theme,
                insightCount: 1, // We'll need to calculate this properly
                sentiment: node.sentiment,
                sentimentClass: this.getSentimentClass(node.sentiment)
            }));
        } else {
            this.themes = [];
        }
    }
    
    resetNodeColors() {
        if (!this.svg) {
            console.log('SVG not available for resetNodeColors');
            return;
        }
        
        console.log('Resetting all node colors to default');
        this.svg.selectAll('.node circle')
            .attr('fill', '#69b3a2')
            .attr('stroke', '#fff')
            .attr('stroke-width', 3);
    }
    
    highlightSelectedNode(nodeId) {
        if (!this.svg) {
            console.log('SVG not available for highlightSelectedNode');
            return;
        }
        
        console.log('Attempting to highlight node:', nodeId);
        
        // Make the selected node stand out with blue color
        const selectedNode = this.svg.selectAll('.node')
            .filter(d => d.id === nodeId);
            
        console.log('Found selected node elements:', selectedNode.size());
        
        selectedNode.select('circle')
            .attr('fill', '#3498db')  // Blue color for selected node
            .attr('stroke', '#2e5caa')
            .attr('stroke-width', 4);
            
        console.log('Highlighted node:', nodeId, 'with blue color');
    }
    
    handleThemeClick(event) {
        const themeId = event.currentTarget.dataset.themeId;
        const theme = this.themes.find(t => t.id === themeId);
        
        if (theme) {
            console.log('Theme clicked:', theme);
            this.selectedTheme = theme;
            this.selectedNode = {
                ...theme,
                sentimentClass: this.getSentimentClass(theme.sentiment)
            };
            
            // Find related HCPs for this theme
            this.findRelatedHCPs(theme);
            
            // Update node styling to highlight related HCPs
            this.highlightRelatedNodes(theme);
        }
    }
    
    handleHCPClick(event) {
        const hcpId = event.currentTarget.dataset.hcpId;
        const hcp = this.graphData.nodes.find(n => n.id === hcpId);
        
        if (hcp) {
            console.log('HCP clicked:', hcp);
            this.selectedNode = {
                ...hcp,
                sentimentClass: this.getSentimentClass(hcp.sentiment)
            };
            this.selectedTheme = null;
            this.relatedHCPs = [];
            
            // Update node styling
            this.updateNodeSelection(hcpId);
        }
    }
    
    handleThemeListClick(event) {
        const themeId = event.currentTarget.dataset.themeId;
        const theme = this.availableThemes.find(t => t.id === themeId);
        
        if (theme) {
            console.log('Theme from list clicked:', theme);
            
            // Update selected theme to trigger re-render
            this.selectedThemeFromList = theme;
            
            // Find HCPs that have this theme
            this.findRelatedHCPs(theme);
            
            // Highlight nodes that have this theme
            this.highlightNodesByTheme(theme);
            
            // Clear other selections
            this.selectedNode = null;
            this.selectedLink = null;
            this.selectedTheme = null;
        }
    }
    
    highlightNodesByTheme(theme) {
        if (!this.svg) return;
        
        console.log('Highlighting nodes with theme:', theme.label);
        
        // Reset all nodes to default color first
        this.resetNodeColors();
        
        // Find HCP nodes that have this theme
        const hcpNodesWithTheme = this.graphData.nodes.filter(node => 
            node.type === 'hcp' && 
            node.themes && 
            node.themes.includes(theme.label)
        );
        
        console.log('HCP nodes with theme', theme.label, ':', hcpNodesWithTheme);
        
        // Highlight the matching HCP nodes
        const nodeIds = hcpNodesWithTheme.map(n => n.id);
        
        this.svg.selectAll('.node')
            .filter(d => nodeIds.includes(d.id))
            .select('circle')
            .attr('fill', '#3498db')  // Blue for theme-related nodes
            .attr('stroke', '#2e5caa')
            .attr('stroke-width', 4);
        
        // Dim nodes that don't have this theme
        this.svg.selectAll('.node')
            .filter(d => !nodeIds.includes(d.id))
            .select('circle')
            .attr('fill', '#cccccc')  // Gray for non-matching nodes
            .attr('stroke', '#999')
            .attr('stroke-width', 1);
    }
    
    findRelatedHCPs(theme) {
        // Find HCPs that have this specific theme
        this.relatedHCPs = this.graphData.nodes
            .filter(node => node.themes && node.themes.includes(theme.label))
            .map(hcp => ({
                ...hcp,
                sentimentClass: this.getSentimentClass(hcp.sentiment)
            }))
            .sort((a, b) => (b.insightCount || 0) - (a.insightCount || 0));
            
        console.log('Related HCPs for theme:', theme.label, this.relatedHCPs);
    }
    
    highlightRelatedNodes(theme) {
        if (!this.svg) return;
        
        // Reset all nodes to default color
        this.svg.selectAll('.node circle')
            .attr('fill', '#69b3a2')
            .attr('stroke', '#fff')
            .attr('stroke-width', 3);
        
        // Highlight nodes that have this theme
        const relatedNodeIds = this.relatedHCPs.map(hcp => hcp.id);
        
        this.svg.selectAll('.node')
            .filter(d => relatedNodeIds.includes(d.id))
            .select('circle')
            .attr('fill', '#3498db')  // Blue for related nodes
            .attr('stroke', '#2e5caa')
            .attr('stroke-width', 4);
            
        // Dim nodes that don't have this theme
        this.svg.selectAll('.node')
            .filter(d => !relatedNodeIds.includes(d.id))
            .select('circle')
            .attr('fill', '#cccccc')  // Gray for unrelated nodes
            .attr('stroke', '#999')
            .attr('stroke-width', 1);
            
        // If there's a selected node, make sure it stays highlighted
        if (this.selectedNode && relatedNodeIds.includes(this.selectedNode.id)) {
            this.svg.selectAll('.node')
                .filter(d => d.id === this.selectedNode.id)
                .select('circle')
                .attr('fill', '#e74c3c')  // Keep selected node red
                .attr('stroke', '#2e5caa')
                .attr('stroke-width', 4);
        }
    }
    
    updateNodeSelection(selectedId) {
        // Update visual selection in the graph
        if (this.svg) {
            this.svg.selectAll('.node circle')
                .attr('stroke', '#fff')
                .attr('stroke-width', 2);
                
            this.svg.selectAll('.node')
                .filter(d => d.id === selectedId)
                .select('circle')
                .attr('stroke', '#2e5caa')
                .attr('stroke-width', 4);
        }
    }
    
    getSentimentClass(sentiment) {
        console.log('getSentimentClass called with:', sentiment);
        if (!sentiment) {
            console.log('No sentiment, returning neutral');
            return 'neutral';
        }
        const lowerSentiment = sentiment.toLowerCase();
        console.log('Lowercase sentiment:', lowerSentiment);
        if (lowerSentiment.includes('positive')) {
            console.log('Returning positive');
            return 'positive';
        }
        if (lowerSentiment.includes('negative')) {
            console.log('Returning negative');
            return 'negative';
        }
        console.log('Returning neutral');
        return 'neutral';
    }
    
    dragstarted(event, d) {
        if (!event.active) this.simulation.alphaTarget(0.3).restart();
        d.fx = d.x;
        d.fy = d.y;
    }

    dragged(event, d) {
        d.fx = event.x;
        d.fy = event.y;
    }

    dragended(event, d) {
        if (!event.active) this.simulation.alphaTarget(0);
        d.fx = null;
        d.fy = null;
    }
    
    // Filter handlers
    handleAllInsights() {
        this.resetNodeColors();
        this.updateButtonVariants('all');
        this.currentFilter = 'all';
    }
    
    handlePositiveFilter() {
        this.highlightNodesBySentiment('positive');
        this.updateButtonVariants('positive');
        this.currentFilter = 'positive';
    }
    
    handleNeutralFilter() {
        this.highlightNodesBySentiment('neutral');
        this.updateButtonVariants('neutral');
        this.currentFilter = 'neutral';
    }
    
    handleNegativeFilter() {
        this.highlightNodesBySentiment('negative');
        this.updateButtonVariants('negative');
        this.currentFilter = 'negative';
    }
    
    highlightNodesBySentiment(sentiment) {
        if (!this.svg) {
            console.log('SVG not available for highlightNodesBySentiment');
            return;
        }
        
        console.log('Highlighting nodes with sentiment:', sentiment);
        
        // Reset all nodes to default color first
        this.resetNodeColors();
        
        // Find HCP nodes with the specified sentiment
        const hcpNodesWithSentiment = this.graphData.nodes.filter(node => 
            node.type === 'hcp' && 
            node.sentiment && 
            this.getSentimentClass(node.sentiment) === sentiment
        );
        
        console.log('HCP nodes with', sentiment, 'sentiment:', hcpNodesWithSentiment);
        
        // Highlight the matching HCP nodes
        const nodeIds = hcpNodesWithSentiment.map(n => n.id);
        
        this.svg.selectAll('.node')
            .filter(d => nodeIds.includes(d.id))
            .select('circle')
            .attr('fill', this.getSentimentHighlightColor(sentiment))
            .attr('stroke', '#2e5caa')
            .attr('stroke-width', 4);
            
        // Dim nodes that don't match the sentiment
        this.svg.selectAll('.node')
            .filter(d => !nodeIds.includes(d.id))
            .select('circle')
            .attr('fill', '#cccccc')  // Gray for non-matching nodes
            .attr('stroke', '#999')
            .attr('stroke-width', 1);
    }
    
    getSentimentHighlightColor(sentiment) {
        switch (sentiment) {
            case 'positive':
                return '#4CAF50';  // Green
            case 'negative':
                return '#F44336';  // Red
            case 'neutral':
                return '#FFC107';  // Yellow
            default:
                return '#69b3a2';  // Default
        }
    }
    
    filterData(sentiment) {
        this.currentFilter = sentiment;
        
        if (sentiment === 'all') {
            this.filteredData = this.graphData;
        } else {
            const filteredNodes = this.graphData.nodes.filter(node => 
                node.sentiment && node.sentiment.toLowerCase() === sentiment
            );
            
            const nodeIds = new Set(filteredNodes.map(n => n.id));
            const filteredLinks = this.graphData.links.filter(link => 
                nodeIds.has(link.source.id || link.source) && 
                nodeIds.has(link.target.id || link.target)
            );
            
            this.filteredData = {
                nodes: filteredNodes,
                links: filteredLinks
            };
        }
        
        this.renderGraph();
    }
    
    updateButtonVariants(activeFilter) {
        this.allInsightsVariant = activeFilter === 'all' ? 'brand' : 'neutral';
        this.positiveVariant = activeFilter === 'positive' ? 'brand' : 'neutral';
        this.neutralVariant = activeFilter === 'neutral' ? 'brand' : 'neutral';
        this.negativeVariant = activeFilter === 'negative' ? 'brand' : 'neutral';
    }
    
    resetView() {
        if (this.simulation) {
            this.simulation.alpha(1).restart();
        }
        
        // Reset selections and colors
        this.selectedNode = null;
        this.selectedTheme = null;
        this.selectedLink = null;
        this.selectedThemeFromList = null;
        this.relatedHCPs = [];
        this.themes = [];
        this.sharedThemes = [];
        
        // Reset filter state
        this.currentFilter = 'all';
        this.updateButtonVariants('all');
        
        // Reset node colors
        this.resetNodeColors();
        
        // Reset link colors
        if (this.svg) {
            this.svg.selectAll('line')
                .attr('stroke', '#999')
                .attr('stroke-opacity', 0.6)
                .attr('stroke-width', d => Math.sqrt(d.value));
        }
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    
    handleLinkClick(link) {
        console.log('Link clicked:', link);
        console.log('Link data structure:', JSON.stringify(link, null, 2));
        
        // The source and target are now full node objects, not just IDs
        const sourceNode = link.source;
        const targetNode = link.target;
        
        console.log('Source node:', sourceNode);
        console.log('Target node:', targetNode);
        
        if (sourceNode && targetNode) {
            // Set the selected link
            this.selectedLink = link;
            this.selectedNode = null;
            this.selectedTheme = null;
            
            console.log('selectedLink set to:', this.selectedLink);
            console.log('selectedNode set to:', this.selectedNode);
            console.log('selectedTheme set to:', this.selectedTheme);
            
            // Highlight the connected nodes
            this.highlightConnectedNodes(link);
            
            // Show shared themes in the panel
            this.showSharedThemes(link, sourceNode, targetNode);
        }
    }
    
    highlightConnectedNodes(link) {
        if (!this.svg) return;
        
        // Reset all nodes to default color
        this.resetNodeColors();
        
        // Highlight the connected nodes
        this.svg.selectAll('.node')
            .filter(d => d.id === link.source.id || d.id === link.target.id)
            .select('circle')
            .attr('fill', '#9b59b6')  // Purple for connected nodes
            .attr('stroke', '#2e5caa')
            .attr('stroke-width', 4);
            
        // Dim other nodes
        this.svg.selectAll('.node')
            .filter(d => d.id !== link.source.id && d.id !== link.target.id)
            .select('circle')
            .attr('fill', '#cccccc')  // Gray for unconnected nodes
            .attr('stroke', '#999')
            .attr('stroke-width', 1);
            
        // Highlight the clicked link
        this.svg.selectAll('line')
            .attr('stroke', '#999')
            .attr('stroke-opacity', 0.6)
            .attr('stroke-width', d => Math.max(3, Math.sqrt(d.value) * 2));
            
        this.svg.selectAll('line')
            .filter(d => d === link)
            .attr('stroke', '#9b59b6')  // Purple for selected link
            .attr('stroke-opacity', 1)
            .attr('stroke-width', Math.max(5, Math.sqrt(link.value) * 3));
    }
    
    showSharedThemes(link, sourceNode, targetNode) {
        console.log('showSharedThemes called with:', { link, sourceNode, targetNode });
        console.log('link.commonThemes:', link.commonThemes);
        
        // Handle different possible data structures
        let commonThemes = [];
        if (link.commonThemes) {
            if (Array.isArray(link.commonThemes)) {
                commonThemes = link.commonThemes;
            } else if (typeof link.commonThemes === 'string') {
                commonThemes = [link.commonThemes];
            }
        }
        
        console.log('Processed commonThemes:', commonThemes);
        
        // Create shared themes data for the panel
        this.sharedThemes = commonThemes.map(theme => ({
            id: theme,
            label: theme,
            sourceHCP: sourceNode.label,
            targetHCP: targetNode.label,
            sourceSentiment: sourceNode.sentiment,
            sourceSentimentClass: this.getSentimentClass(sourceNode.sentiment),
            targetSentiment: targetNode.sentiment,
            targetSentimentClass: this.getSentimentClass(targetNode.sentiment),
            insightCount: link.value || commonThemes.length
        }));
        
        console.log('Created sharedThemes:', this.sharedThemes);
        console.log('this.sharedThemes after assignment:', this.sharedThemes);
        
        // Clear other data
        this.themes = [];
        this.relatedHCPs = [];
        
        // Force a reactive update
        this.sharedThemes = [...this.sharedThemes];
        console.log('Final sharedThemes after spread:', this.sharedThemes);
    }
    
    autoSelectDefaultNode() {
        // Find the node corresponding to the recordId passed to the LWC
        const defaultNode = this.graphData.nodes.find(node => 
            node.recordId === this.recordId
        );
        
        if (defaultNode) {
            console.log('Found default node for recordId:', this.recordId, defaultNode);
            
            // Set as selected node
            this.selectedNode = {
                ...defaultNode,
                sentimentClass: this.getSentimentClass(defaultNode.sentiment)
            };
            this.selectedTheme = null;
            this.selectedLink = null;
            this.relatedHCPs = [];
            this.sharedThemes = [];
            
            // Highlight the node in the graph
            if (this.svg) {
                // Reset all nodes to default color first
                this.resetNodeColors();
                
                // Reset link colors to default
                this.svg.selectAll('line')
                    .attr('stroke', '#999')
                    .attr('stroke-opacity', 0.6)
                    .attr('stroke-width', d => Math.max(3, Math.sqrt(d.value) * 2));
                
                // Highlight the default node
                this.highlightSelectedNode(defaultNode.id);
            }
            
            // Populate themes for the default node
            if (defaultNode.themes && defaultNode.themes.length > 0) {
                this.themes = defaultNode.themes.map(theme => ({
                    id: theme,
                    label: theme,
                    insightCount: 1, // We'll need to calculate this properly
                    sentiment: defaultNode.sentiment,
                    sentimentClass: this.getSentimentClass(defaultNode.sentiment)
                }));
            } else {
                this.themes = [];
            }
            
            console.log('Auto-selected default node with themes:', this.themes);
        } else {
            console.log('Default node not found for recordId:', this.recordId);
        }
    }
    
    handleThemeDetailsClick(event) {
        event.stopPropagation(); // Prevent triggering the theme click
        const themeId = event.currentTarget.dataset.themeId;
        console.log('Theme details button clicked:', themeId);
        
        // Find the theme in either themes or sharedThemes
        let theme = this.themes.find(t => t.id === themeId);
        let isSharedTheme = false;
        
        if (!theme) {
            theme = this.sharedThemes.find(t => t.id === themeId);
            isSharedTheme = true;
        }
        
        if (theme) {
            // Toggle details visibility
            if (theme.showDetails) {
                // Hide details
                theme.showDetails = false;
                theme.detailsText = '';
            } else {
                // Show details
                theme.showDetails = true;
                this.loadThemeDetailsInline(theme, isSharedTheme);
            }
            
            // Force reactive update
            if (isSharedTheme) {
                this.sharedThemes = [...this.sharedThemes];
            } else {
                this.themes = [...this.themes];
            }
        }
    }
    
    _buildInsightSection(details, hcpName, keyPrefix) {
        if (!details || details.length === 0) {
            return {
                key: keyPrefix,
                heading: hcpName,
                insights: [],
                empty: true,
                emptyMessage: `No insights found for ${hcpName}.`
            };
        }
        return {
            key: keyPrefix,
            heading: hcpName,
            insights: details.map((insight, idx) => ({
                key: `${keyPrefix}_${idx}`,
                name: insight.Name || 'Untitled Insight',
                date: insight.CreatedDate ? new Date(insight.CreatedDate).toLocaleDateString() : 'N/A',
                detail: insight.Content || 'No detail available'
            })),
            empty: false
        };
    }

    async loadThemeDetailsInline(theme, isSharedTheme) {
        try {
            console.log('Loading theme details for:', theme.label);
            theme.detailsText = null;
            theme.detailsSections = null;

            if (isSharedTheme) {
                const sourceNode = this.graphData.nodes.find(n => n.label === theme.sourceHCP);
                const targetNode = this.graphData.nodes.find(n => n.label === theme.targetHCP);
                const sourceId = sourceNode ? sourceNode.recordId : null;
                const targetId = targetNode ? targetNode.recordId : null;

                if (!sourceId && !targetId) {
                    theme.detailsText = 'Unable to determine HCPs for this theme.';
                    this.sharedThemes = [...this.sharedThemes];
                    return;
                }

                const [sourceDetails, targetDetails] = await Promise.all([
                    sourceId ? getInsightsByTheme({ theme: theme.label, accountId: sourceId }) : Promise.resolve([]),
                    targetId ? getInsightsByTheme({ theme: theme.label, accountId: targetId }) : Promise.resolve([])
                ]);

                theme.detailsSections = [
                    this._buildInsightSection(sourceDetails, theme.sourceHCP, 'src'),
                    this._buildInsightSection(targetDetails, theme.targetHCP, 'tgt')
                ];
                this.sharedThemes = [...this.sharedThemes];
            } else {
                const accountId = this.selectedNode ? this.selectedNode.recordId : null;
                if (!accountId) {
                    theme.detailsText = 'Unable to determine HCP for this theme.';
                    this.themes = [...this.themes];
                    return;
                }

                const details = await getInsightsByTheme({ theme: theme.label, accountId: accountId });
                theme.detailsSections = [
                    this._buildInsightSection(details, this.selectedNode.label, 'single')
                ];
                this.themes = [...this.themes];
            }

        } catch (error) {
            console.error('Error loading theme details:', error);
            theme.detailsText = 'Error loading theme details.';
            theme.detailsSections = null;

            if (isSharedTheme) {
                this.sharedThemes = [...this.sharedThemes];
            } else {
                this.themes = [...this.themes];
            }
        }
    }

    get showAgentforceButton() {
        return this.selectedNode || this.selectedLink;
    }

    async handleAskAgentforce() {
        let contextObj;

        if (this.selectedLink && this.sharedThemes && this.sharedThemes.length > 0) {
            // Link selected — compare two HCPs
            const sourceNode = this.graphData.nodes.find(n => n.label === this.sharedThemes[0].sourceHCP);
            const targetNode = this.graphData.nodes.find(n => n.label === this.sharedThemes[0].targetHCP);
            contextObj = {
                name1: sourceNode ? sourceNode.label : this.sharedThemes[0].sourceHCP,
                name2: targetNode ? targetNode.label : this.sharedThemes[0].targetHCP,
                topics: this.sharedThemes.map(t => t.label).join(', '),
                sentiment1: sourceNode ? sourceNode.sentiment : 'Unknown',
                sentiment2: targetNode ? targetNode.sentiment : 'Unknown',
                summaries1: sourceNode && sourceNode.summaries ? sourceNode.summaries.join('; ') : '',
                summaries2: targetNode && targetNode.summaries ? targetNode.summaries.join('; ') : ''
            };
        } else if (this.selectedNode) {
            // Single HCP node selected
            contextObj = {
                name: this.selectedNode.label,
                topics: this.selectedNode.themes ? this.selectedNode.themes.join(', ') : '',
                sentiment: this.selectedNode.sentiment || 'Unknown',
                summaries: this.selectedNode.summaries ? this.selectedNode.summaries.join('; ') : ''
            };
        } else {
            return;
        }

        this.showAgentforceModal = true;
        this.agentforceLoading = true;
        this.agentforceResponse = '';

        try {
            const response = await askAgentforce({ contextJson: JSON.stringify(contextObj) });
            this.agentforceResponse = response;
        } catch (error) {
            console.error('Error calling Agentforce:', error);
            this.agentforceResponse = 'Error: ' + (error.body?.message || error.message || 'Unable to get Agentforce analysis.');
        } finally {
            this.agentforceLoading = false;
        }
    }

    closeAgentforceModal() {
        this.showAgentforceModal = false;
        this.agentforceResponse = '';
        this.agentforceLoading = false;
    }

    get parsedAgentforceResponse() {
        if (!this.agentforceResponse) return [];
        return this._parseMarkdown(this.agentforceResponse);
    }

    _stripBold(text) {
        return text.replace(/\*\*/g, '');
    }

    _parseMarkdown(text) {
        const lines = text.split('\n');
        const blocks = [];
        let idx = 0;

        for (const raw of lines) {
            const line = raw.trim();

            // Empty line → spacer
            if (!line) {
                // Avoid consecutive spacers
                if (blocks.length > 0 && !blocks[blocks.length - 1].isSpacer) {
                    blocks.push({ key: `b${idx++}`, isSpacer: true });
                }
                continue;
            }

            // Markdown headings: ## Heading or ### Heading
            const headingMatch = line.match(/^(#{1,3})\s+(.+)/);
            if (headingMatch) {
                const level = headingMatch[1].length;
                const headingText = this._stripBold(headingMatch[2]);
                if (level <= 2) {
                    blocks.push({ key: `b${idx++}`, isHeading: true, text: headingText });
                } else {
                    blocks.push({ key: `b${idx++}`, isSubheading: true, text: headingText });
                }
                continue;
            }

            // Standalone bold line → treat as subheading (e.g. **Summary:**)
            const boldLineMatch = line.match(/^\*\*(.+?)\*\*:?\s*$/);
            if (boldLineMatch) {
                blocks.push({ key: `b${idx++}`, isSubheading: true, text: boldLineMatch[1].replace(/:$/, '') });
                continue;
            }

            // Numbered or bulleted list item: 1. text, - text, * text
            const listMatch = line.match(/^(\d+[.)]\s+|- |\* )(.+)/);
            if (listMatch) {
                const bullet = listMatch[1].trim();
                const content = listMatch[2];
                // Check for bold prefix: **Label:** rest
                const boldPrefixMatch = content.match(/^\*\*(.+?)\*\*:?\s*(.*)/);
                if (boldPrefixMatch) {
                    blocks.push({
                        key: `b${idx++}`,
                        isListItem: true,
                        bullet,
                        boldPrefix: boldPrefixMatch[1] + ':',
                        text: ' ' + boldPrefixMatch[2]
                    });
                } else {
                    blocks.push({
                        key: `b${idx++}`,
                        isListItem: true,
                        bullet,
                        boldPrefix: null,
                        text: this._stripBold(content)
                    });
                }
                continue;
            }

            // Label: Value pattern with bold label: **Sentiment:** Positive
            const labelMatch = line.match(/^\*\*(.+?)\*\*:?\s+(.+)/);
            if (labelMatch) {
                blocks.push({
                    key: `b${idx++}`,
                    isLabelValue: true,
                    label: labelMatch[1] + ':',
                    value: ' ' + this._stripBold(labelMatch[2])
                });
                continue;
            }

            // Regular paragraph
            blocks.push({ key: `b${idx++}`, isParagraph: true, text: this._stripBold(line) });
        }

        return blocks;
    }

    handleZoomIn() {
        if (this.svg && this.zoom) {
            this.svg.transition().duration(200).call(this.zoom.scaleBy, 1.2);
        }
    }

    handleZoomOut() {
        if (this.svg && this.zoom) {
            this.svg.transition().duration(200).call(this.zoom.scaleBy, 0.8);
        }
    }
}