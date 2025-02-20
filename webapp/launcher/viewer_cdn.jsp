<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("utf-8");

	java.util.Map<String, String> params = new java.util.HashMap<>();
	java.util.Enumeration<String> param_names = request.getParameterNames();
	
	// XSS vulnerabilities
	while (param_names.hasMoreElements())
	{
		String pname = param_names.nextElement();
		
		if (pname != null && pname.length() > 0)
		{
			String pvalue = request.getParameter(pname);
			if (pvalue != null && pvalue.length() > 0)
			{
				pvalue = pvalue.replaceAll("\\\\", "");
				pvalue = pvalue.replaceAll("\'", "\\\\\'");
				pvalue = pvalue.replaceAll("\"", "\\\\\"");
				pvalue = pvalue.replaceAll("<", "&lt;");
				pvalue = pvalue.replaceAll(">", "&gt;");
				params.put(pname, pvalue);
			}
		}
	}

	String _d = params.get("_d");
	String ukey = "?_d=" + _d;
	String lang = params.get("lang");
	lang = (lang == null) ? "en_US" : lang;
	String mts = params.get("mts");
	mts = (mts == null) ? "" : mts;
	String tmp = params.get("tmp");
	tmp = (tmp == null) ? "" : tmp;

    String version = com.amplix.rpc.igcServer.version;
    
    String theme = params.get("theme");
	
	String objid = params.get("objid");
    objid = objid != null && objid.trim().length() > 0 ? objid : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Amplix</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<link rel="icon" href="../favicon.png" type="image/png">
<link rel="stylesheet" type="text/css" href="https://cloud.amplixbi.com/launcher/css/apps.min.css?_dc=202502212154" />
<link rel="stylesheet" type="text/css" href="https://cloud.amplixbi.com/launcher/css/custom_lang_<%=lang.toLowerCase()%>.css?_dc=202502212154" />
<%
if (theme != null && theme.length() > 0)
{
	out.println("<link rel=\"stylesheet\" type=\"text/css\" href=\"https://cloud.amplixbi.com/launcher/css/" + theme.toLowerCase() + ".css?_dc=202502212154\" />");
}
%>
<link rel="stylesheet" type="text/css" href="https://cloud.amplixbi.com/launcher/viewer/css/viewer.css?_dc=202502212154" />
<link rel="stylesheet" type="text/css" href="https://cloud.amplixbi.com/launcher/css/custom.css?_dc=202502212154" />

<style>
#wrap {
	top: 0px;
}
#content {
	top: <%= (objid == null ? "102" : "0") %> px;
}
</style>

<script type="text/javascript" src="https://cloud.amplixbi.com/launcher/js/jquery-3.6.4.min.js"></script>    
<script type="text/javascript" src="https://cloud.amplixbi.com/config.js?_dc=202502212154"></script>
<script type="text/javascript" src="../bootconfig_cdn.js?_dc=202502212154"></script>
<script type="text/javascript" src="https://cloud.amplixbi.com/launcher/js/igca.min.js?_dc=202502212154"></script>

<script type="text/javascript">
var useLocale = "<%=lang%>";
var m$mts = "<%=mts%>" || "0122483f-0155fb46";
var m$_d = "";
//Fix issues on chrome iframe session persistency.
//var use_session_key = true;

function getLocale()
{
    var hash = window.location.hash.substring(1).split('&'),
        i, k, v, m;
    
    for (i=0; i < hash.length; i++)
    {
        m = hash[i].indexOf("=");
        if (m > 0)
        {
            k = hash[i].substring(0, m);
            v = hash[i].substring(m+1);
            
            if (k == "lang" && v)
            {
                useLocale = v;
                break;
            }
        }
    }
}

getLocale();

function loadParameter(param) {
    window._report_prompt = [];
    var i;
    for (i=0; param._report_prompt.length; i++)
    {
        window._report_prompt.push(param._report_prompt);
    }
}
</script>
<script type="text/javascript">
<%
if (theme != null && theme.length() > 0)
{
	out.println("ig$.theme_id=\"" + theme + "\";");
}
%>

var modules = ["framework", "app_viewer", "appnc", "vis_ec", "vis_ec_theme", "custom_viewer", "custom"];
IG$.__microloader(modules, function() {
	$s.ready(function() {
		var viewer_inst = new IG$.amplix_instance({
			target: "#mainview"
		});
		
		viewer_inst.onLoad(function() {
			var me = this;
		});
		
		viewer_inst.create();
	});
});
</script>
</head>
<body scroll="no">
<%
	if (objid == null) {
%>
<div id="top_viewer" style="">
	<div id="slide_menu"></div>
	<div id="amp-header"> 
	  <div id="nav">
	    <span class="f_left logo">
	    amplix
	    <!-- a href="./"><img src="./images/logo.png" width="300" height="38" alt="logo"/></a -->
	    </span>
	    <ul id="d_nav">
	      
	    </ul>
	  </div>
	</div>
	<div id="title_area">
	  <h1>Dashboard Viewer</h1>
	</div>
</div>
<% } %>
<div id="wrap">
  <div id="content" style="top: 0px;">
    <div style="overflow-x:hidden;" width="100%" height="100%" name="mainview" id="mainview">
    	<div id="loading-mask" style=""></div>
		<div id="loading">
			<div class="cmsg">
				<div class="msg">Loading Amplix...</div>
				<div class="lpb">
					<div id="lpt" style="width: 10%;"></div>
				</div>
			</div>
		</div>
    </div>
  </div>
</div>
</body>
</html>
