﻿<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
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
	
	boolean is_debug = (params.get("debug") != null && params.get("debug").equals("true") ? true : false);
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
<link rel="stylesheet" type="text/css" href="./css/material-components-web.min.css?_dc=202502212154" />
<link rel="stylesheet" type="text/css" href="./css/apps.min.css?_dc=202502212154" />
<link rel="stylesheet" type="text/css" href="./css/custom_lang_<%=lang.toLowerCase()%>.css?_dc=202502212154" />
<%
if (theme != null && theme.length() > 0)
{
	out.println("<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/" + theme.toLowerCase() + ".css?_dc=202502212154\" />");
}
%>
<link rel="stylesheet" type="text/css" href="./css/custom.css?_dc=202502212154" />

<script type="text/javascript" src="./js/jquery-3.6.4.min.js"></script>    
<script type="text/javascript" src="../config.js?_dc=202502212154"></script>
<script type="text/javascript" src="../bootconfig<%=(is_debug ? "_debug" : "")%>.js?_dc=202502212154"></script>
<script type="text/javascript" src="./js/igca<%=(is_debug ? "" : ".min")%>.js?_dc=202502212154"></script>

<script type="text/javascript">
var useLocale = "<%=lang%>";
var m$mts = "<%=mts%>";
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

var init_dashboard = function(instance) {
	var menu_logout = new IG$._menu_button($(".user-info"), [
		{
			nmae: "b_passwd",
			text: "Password",
			handler: function() {
				var m_pwd = $("#m_pwd"),
					u1 = $("#u1", m_pwd),
					u2 = $("#u2", m_pwd),
					u3 = $("#u3", m_pwd);
					
				u1.val("");
				u2.val("");
				u3.val("");
				
				m_pwd.show();
			}
		},
		{
			nmae: "b_logout",
			text: "Logout",
			handler: function() {
				IG$.showLogout();
			}
		}
	], {
		btn_styles: ["fadeInRight"],
		menu_position: {
			top: 40,
			left: "initial",
			right: 10
		}
	});
	menu_logout.create();
	
	var set_themes = function(theme) {
		var vars = {}, 
			hash,
			murl = window.location.href,
			qseq = murl.indexOf("?"),
			url = qseq > 0 ? murl.substring(0, qseq) : null,
	    	hashes = qseq > 0 ? murl.slice(qseq + 1).split('&') : null,
	    	nurl,
	    	i,
	    	nseq = 0;
	    
	    if (hashes)
	    {
		    for(i = 0; i < hashes.length; i++)
		    {
		        hash = hashes[i].split('=');
		        vars[hash[0]] = hash[1];
		    }
	    }
	    
	    vars["theme"] = theme.code || "";
	    
	    nurl = url + "?";
	    
	    $.each(vars, function(k, v) {
	    	nurl += (nseq > 0 ? "&" : "") + k + "=" + v;
	    	nseq++;
	    });
	    
	    window.location.replace(nurl);
	};
	
	var theme_options = [];
	
	$.each(ig$.themes, function(i, theme) {
		theme_options.push({
			text: theme.disp,
			handler: function() {
				set_themes(theme);
			}
		})
	});
	
	var menu_theme = new IG$._menu_button($("#b_style"), theme_options, {
		btn_styles: ["fadeInRight"],
		menu_position: {
			top: 40,
			left: "initial",
			right: 10
		}
	});
	menu_theme.create();

	// play dashboard
	var is_playing = false,
		b_play = $("#b_play");

	b_play.bind("click", function() {
		var mainPanel = instance.mainPanel;
		is_playing = !is_playing;
		b_play.removeClass("fa-play")
			.removeClass("fa-pause");

		b_play.addClass(is_playing ? "fa-pause" : "fa-play");
		mainPanel.stopPlay();
		is_playing && mainPanel.startPlay();
	});
}

var modules = ["framework", "app_dashboard", "appnc", "vis_ec", "vis_ec_theme", "custom"];
IG$.__microloader(modules, function() {
	$s.ready(function() {
		var dasboard_inst = new IG$.amplix_instance({
			target: "#mainview"
		});
		
		dasboard_inst.onLoad(function() {
			var me = this;
			init_dashboard(dashboard_inst);
		});
		
		dasboard_inst.create();

		_load_cuddler(dashboard_inst);
	});
});
</script>
<!-- start ai data explorer -->
<link rel="stylesheet" href="./css/igccud.min.css?_dc=202502212154"></link>
<script type="text/javascript">
function _load_cuddler(instance) {
	var assist_message = [
		"Welcome to amplixbi! <br/>I am here to assit you!",
		"We have agents to help you. <br/> Just click me!"
	];

	function rotate_msg() {
		if (window.assist_message && assist_message.length > 0)
		{
			var mindex = window._curmsg || 0;
			
			$("#assist_message").fadeIn();
			$("#assist_message").html(assist_message[mindex % assist_message.length]);
			
			window._curmsg = mindex + 1;
			
			if (assist_message.length > 1)
			{
				setTimeout(function() {
					$("#assist_message").fadeOut();
					setTimeout(rotate_msg, 2000);
				}, 3000);
			}
		}
	}

	rotate_msg();

	$("#robo_wrap").bind("click", function(e) {
		e.preventDefault();
		e.stopPropagation();
		
		$("#robo_main").show();
		
		var robo_inst;

		if (!IG$._robo_inst)
		{
			robo_inst = IG$._robo_inst = new IG$._wcollab({
				instance: instance,
				_container: $("#robo_embed_area")
			});
		}
		else
		{
			robo_inst = IG$._robo_inst;
		}

		robo_inst.load_app();
	});
	
	$("#robo_close", "#robo_main").bind("click", function(e) {
		e.preventDefault();
		e.stopPropagation();
		
		$("#robo_main").fadeOut();
	});
}
</script>
<!-- end ai data explorer -->
</head>
<body scroll="no">
 	<div id="mainview">
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
 	
 	<div id="navbar" class="navbar">
 		<div class="navbar-header">
 			<div id="navbar_dmenu" class="igc-nav-btn-menu"></div>
 			<a class="navbar-brand" id="logo_txt">
 				Amplix
 			</a>
 		</div>
 		<div class="navbar-top-menu">
 		</div>
 		<div class="navbar-btns-cnt">
 			<ul class="navbar-btns">
 				<li class="light-blue">
 					<span class="user-info">
						<span class="fa fa-play" id="b_play"></span>
 						<span class="fa fa-tasks" style="font-size:14px;" id="b_style"></span>
						<span class="igc-uname" id="igc_login_dr">
							<span id="igc_login_user"></span><b class="caret"></b>
						</span> 
						<span id="igc_logout" class="igc-logout fa-sign-out"></span>
 					</span>
 				</li>
 			</ul>
 		</div>
 	</div>
 	
 	<div id="sidebar-shortcuts" class="sidebar-shortcuts">
 		<div class="sidebar-btn sidebar-btn-d-menu">
 		</div>
 		<div class="sidebar-btn sidebar-btn-n-menu">
 		</div>
 	</div>
 	<div id="sidebar" class="sidebar">
 		<div class="side-nav">
 		</div>
 	</div>
 	
 	<div id="sidebar_fav" class="sidebar">
 		<div class="side-nav">
 		</div>
 	</div>
 	
 	<div id="breadcrumbs" class="breadcrumbs">
 		<ul class="breadcrumb">
 			<!-- li><span class="link">Home</span></li -->
 		</ul>
 		<div class="nav-search" style="display:none;">
 			<span class="input-icon">
 				<input type="text" placeholder="Search ..." class="nav-search-input" autocomplete="off"></input>
 				<i class="nav-search-icon">M</i>
 			</span>
 		</div>
 	</div>
 	
    <ul id="m_style" class="dropdown-menu animated fadeInRight m-t-xs">
    </ul>
    
    <!-- start ai data explorer --> 
	<div class="robo_wrap" id="robo_wrap" style="display:none;">
		<div class="robo_icon">
			<img src="./images/cuddler.png" width="55px" height="42px">
		</div>
		<div class="assist_message" id="assist_message">
		</div>
	</div>
	<div class="robo_main fadeInRight animated" id="robo_main">
		<div class="robo_area">
			<div class="robo_title">
				<span class="robo_title_text">AI Data Explorer!</span>
				<div class="robo_title_button">
					<a id="robo_close" class="robo_close">
						<i class="robo-window-close"></i>
					</a>
				</div>
			</div>
			<div class="robo_embed_area" id="robo_embed_area">
			</div>
		</div>
	</div>
	<!-- end ai data explorer -->
</body>
</html>
