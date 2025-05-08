IG$.__chartoption.charttype.push(
	{
		label: "Circle Packing",
		charttype: "circlepacking",
		subtype: "circlepacking",
		img: "circlepacking",
		grp: "scientific"
	}
);

IG$.cVis.circlepacking = $s.extend(IG$.cVis.base, {
	draw: function(results) {
		var me = this;
		
		if (IG$.cVis.circlepacking._loading)
		{
			setTimeout(function() {
				me.draw(results);
			}, 500);
			
			return;
		}
		
		if (!IG$.cVis.circlepacking._loaded)
		{
			var js = [
					"./js/d3-hierarchy.min.js",
					"./custom/custom.circlepacking.worker.js"
				];
			
			IG$.cVis.circlepacking._loading = 1;
			
			IG$.getScriptCache(
				js, 
				new IG$.callBackObj(this, function() {
					IG$.cVis.circlepacking._loaded = 1;
					me.draw(results);
				})
			);
		}
	},
	updatedisplay: function(w, h) {
	},
	getEchartData: function(chart, pobj) {
		var svgnode,
			nodename,
			svg;
		
		svgnode = IG$.getFstChld(chart.getDom());
		if (IG$.XGetNodeName(svgnode).toUpperCase() == "DIV")
		{
			svgnode = IG$.getFstChld(svgnode);
			nodename = IG$.XGetNodeName(svgnode).toUpperCase();
			
			if (nodename == "SVG")
			{
				IG$.XSetAttr(svgnode, "xmlns:xlink", "http://www.w3.org/1999/xlink");
				IG$.XSetAttr(svgnode, "xmlns", "http://www.w3.org/2000/svg");
				IG$.XSetAttr(svgnode, "version", "1.1");
	
				svg = IG$.toXMLString(svgnode);
				pobj.image_type = "svg";
				pobj.image_data = Base64.encode(svg); 
			}
			else
			{
				svg = chart.getDataURL({
					type: "png",
					pixelRatio: 2,
					backgroundColor: "#fff"
				});
				pobj.image_type = "png";
				pobj.image_data = svg;
			}
			
			pobj.image_width = $(svgnode).width();
			pobj.image_height = $(svgnode).height();
		}
	},
	getExportData: function(pobj, callback) {
		var me = this;

		me.customchart && me.getEchartData(me.customchart, pobj);
			
		callback.execute(pobj);
	}
});
