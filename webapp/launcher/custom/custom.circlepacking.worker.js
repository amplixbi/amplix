IG$.cVis.circlepacking.prototype.drawCirclePacking = function() {
	var me = this,
		chartview = me.chartview,
		results = me.results,
		tabledata = results._tabledata,
		container = $(chartview.container),
		sop = chartview._ILb,
		cop = chartview.cop,
		i, j,
		jcontainer,
		data = [],
		colfix = results.colfix,
		rowfix = results.rowfix,
		cols = results.cols,
		rec, d, t,
		width,
		height,
		data = {
			name: "root",
			$map : {},
			children: []
		},
		maxDepth = 0,
		myChart,
		option;
	
	container.empty();
	jcontainer = $("<div class='amp-tg-gr'></div>").appendTo(container);
	
	width = container.width();
	height = container.height();
	jcontainer.width(width);
	jcontainer.height(height);

	var root = {
		id: "root",
		name: "ALL",
		depth: 0,
		value: 0,
		index: 0,
		pvalue: 0
	};
	var seriesData = [root];
	
	var tparent = {},
		tval;

	for (i=rowfix; i < tabledata.length; i++)
	{
		rec = tabledata[i];
		
		for (j=0; j < colfix; j++)
		{
			t = rec[j].text || rec[j].code;
			
			if (j == 0)
			{
				tval = data.$map[t];
				
				if (!tval)
				{
					tval = {
						id: "root." + t,
						name: root.name + " > " + t,
						$map: {},
						depth: j,
						value: 0,
						index: i,
						children: []
					};
					
					data.children.push(tval);
					seriesData.push(tval);
					data.$map[t] = tval;
				}
			}
			else
			{
				tval = tparent[j-1].$map[t];
				if (!tval)
				{
					tval = {
						id: tparent[j-1].id + "." + t,
						value: 0,
						depth: j,
						index: i,
						name: tparent[j-1].name + " > " + t,
						$map: {}
					};
					
					if (j < colfix - 1)
						tval.children = [];
					
					tparent[j-1].children.push(tval);
					tparent[j-1].$map[t] = tval;
					seriesData.push(tval);
				}
			}
			
			tparent[j] = tval;
		}
		
		t = Number(rec[colfix].code);
		if (!isNaN(t)) {
			root.value += t;
			if (colfix > 1) {
				for (j=0; j < colfix - 1; j++) {
					tparent[j].value += t;
				}
			}
			tparent[colfix-1].value = t;
		}
	}

	for (i=0; i < seriesData.length; i++) {
		var p = Math.round((seriesData[i].value / root.value) * 10000) / 100;
		seriesData[i].pvalue = "" + p + "%";
	}

	maxDepth = colfix;

	var displayRoot = stratify();

	function stratify() {
		return d3
		  .stratify()
		  .parentId(function (d) {
			return d.id.substring(0, d.id.lastIndexOf('.'));
		  })(seriesData)
		  .sum(function (d) {
			return d.value || 0;
		  })
		  .sort(function (a, b) {
			return b.value - a.value;
		  });
	}
	function overallLayout(params, api) {
		var context = params.context;
		d3
		  .pack()
		  .size([api.getWidth() - 2, api.getHeight() - 2])
		  .padding(3)(displayRoot);
		context.nodes = {};
		displayRoot.descendants().forEach(function (node, index) {
		  context.nodes[node.id] = node;
		});
	}

	function renderItem(params, api) {
		var context = params.context;
		// Only do that layout once in each time `setOption` called.
		if (!context.layout) {
		  context.layout = true;
		  overallLayout(params, api);
		}
		var nodePath = api.value('id');
		var node = context.nodes[nodePath];
		if (!node) {
		  // Reder nothing.
		  return;
		}
		var isLeaf = !node.children || !node.children.length;
		var focus = new Uint32Array(
		  node.descendants().map(function (node) {
			return node.data.index;
		  })
		);
		var nodeName = isLeaf
		  ? nodePath
			  .slice(nodePath.lastIndexOf('.') + 1)
			  .split(/(?=[A-Z][^A-Z])/g)
			  .join('\n')
		  : '';
		var z2 = api.value('depth') * 2;
		return {
		  type: 'circle',
		  focus: focus,
		  shape: {
			cx: node.x,
			cy: node.y,
			r: node.r
		  },
		  transition: ['shape'],
		  z2: z2,
		  textContent: {
			type: 'text',
			style: {
			  // transition: isLeaf ? 'fontSize' : null,
			  text: nodeName,
			  fontFamily: 'Arial',
			  width: node.r * 1.3,
			  overflow: 'truncate',
			  fontSize: node.r / 3
			},
			emphasis: {
			  style: {
				overflow: null,
				fontSize: Math.max(node.r / 3, 12)
			  }
			}
		  },
		  textConfig: {
			position: 'inside'
		  },
		  style: {
			fill: api.visual('color')
		  },
		  emphasis: {
			style: {
			  fontFamily: 'Arial',
			  fontSize: 12,
			  shadowBlur: 20,
			  shadowOffsetX: 3,
			  shadowOffsetY: 5,
			  shadowColor: 'rgba(0,0,0,0.3)'
			}
		  }
		};
	}
	
	if (window.echarts)
	{
		option = {
			dataset: {
				source: seriesData
			},
			tooltip: {},
			visualMap: [
				{
					show: false,
					min: 0,
					max: maxDepth,
					dimension: 'depth',
					inRange: {
						color: ['#006edd', '#e0ffff']
					}
				}
			],
			hoverLayerThreshold: Infinity,
			series: {
				type: 'custom',
				renderItem: renderItem,
				progressive: 0,
				coordinateSystem: 'none',
				encode: {
					tooltip: 'pvalue',
					itemName: 'name'
				}
			}
		};

		if (!me.customchart) {
			myChart = me.customchart = echarts.init(jcontainer[0], cop.echart_theme || ig$.echarts_theme || 'amplix', {
				renderer: "canvas"
			});

			me.customchart.setOption(option);

			myChart.on('click', { seriesIndex: 0 }, function (params) {
				drillDown(params.data.id);
			});
			function drillDown(targetNodeId) {
				displayRoot = stratify();
				if (targetNodeId != null) {
				  displayRoot = displayRoot.descendants().find(function (node) {
					return node.data.id === targetNodeId;
				  });
				}
				// A trick to prevent d3-hierarchy from visiting parents in this algorithm.
				displayRoot.parent = null;
				myChart.setOption({
				  dataset: {
					source: seriesData
				  }
				});
			}
			  // Reset: click on the blank area.
			myChart.getZr().on('click', function (event) {
				if (!event.target) {
				  drillDown();
				}
			});
		} else {
			me.customchart.setOption(option);
		}
	}
}

IG$.cVis.circlepacking.prototype.draw = function(results) {
	var me = this;

	me.results = results;
	
	me.drawCirclePacking();
};
	  
IG$.cVis.circlepacking.prototype.updatedisplay = function(w, h) {
	var me = this;
	
	if (me.customchart && me.results)
	{
		// me.drawCirclePacking();
		me.customchart.resize();
	}
};

IG$.cVis.circlepacking.prototype.dispose = function() {
	var me = this,
		customchart = me.customchart;
		
	if (customchart)
	{
		customchart.dispose && customchart.dispose();
		customchart.destroy && customchart.destroy();

		me.customchart = null;
	}
};