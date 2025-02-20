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
	
	String theme = params.get("theme");
    theme = (theme == null) ? "" : theme;
	
	boolean is_debug = (params.get("debug") != null && params.get("debug").equals("true") ? true : false);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<link rel="icon" href="../favicon.png" type="image/png">
<title>Amplix Login</title>

<style type="text/css">
body {
	width: 100%;
	height: 100%;
}

body, div {
	margin: 0px;
	padding: 0px;
	overflow: hidden;
}
</style>
<link rel="stylesheet" href="./css/appsl.min.css?_dc=202502212154" type="text/css">
<link rel="stylesheet" type="text/css" href="./css/custom_lang_<%=lang.toLowerCase()%>.css?_dc=202502212154" />
<link rel="stylesheet" type="text/css" href="./css/custom.css?_dc=202502212154" />
<script type="text/javascript" src="./js/jquery-3.6.4.min.js"></script>
<script type="text/javascript" src="../config.js?_dc=202502212154"></script>
<script type="text/javascript" src="./js/igc8<%=(is_debug ? "" : ".min")%>.js?_dc=202502212154"></script>

<script type="text/javascript">
var useLocale = "en_US";
var loadingApp;
//Fix issues on chrome iframe session persistency.
//var use_session_key = true;

function parseLocation() {
	var hash = window.location.hash.substring(1);
	
	if (hash == "" && window.location.search && window.location.search != "")
	{
		hash = window.location.search.substring(1).split('&');
	}
	else
	{
		hash = hash.split('&');
	}
	
	for (var i=0; i < hash.length; i++)
	{
		if (hash[i].length > 0 && hash[i].indexOf('=') > -1)
		{
			var hname = hash[i].substring(0, hash[i].indexOf('=')),
				hvalue = hash[i].substring(hash[i].indexOf('=') + 1);
			
			switch (hname)
			{
			case 'lang':
				useLocale = hvalue;
				break;
			case "theme":
				ig$.theme_id = hvalue;
            	break;
			case 'app':
				loadingApp = hvalue;
				break;
			}
		}
	}
}

ig$.theme_id = ig$.theme_id || "<%=theme%>" || $.cookie("theme");

function initPage() {
	var uid = $.cookie("lui") || "",
		upd = "",
		mts = "<%=mts%>";
		
	if (ig$.theme_id)
    {
    	IG$.getScriptCache(
   	        ["./css/" + ig$.theme_id.toLowerCase() + ".css"], 
   	        new IG$.callBackObj(this, function() {
   	            // __microloader();
   	        }),
   	        true
   	    );
    }
	
	var instance = new IG$.amplix_instance({
	});
	
	IG$.createLoginPanel(instance, uid, upd, false);

	var bg = $("div.login-progress").hide();

	$("#b_loc" + (instance.id)).bind("change", function(e) {
		var b_loc = $("#b_loc" + (instance.id)),
			selvalue = $("option:selected", b_loc).val(),
			redirect = $(location).attr('href'),
			p, hv, h = {},
			k, v,
			i, s = false;
			
		if (selvalue && selvalue != window.useLocale)
		{
			$.removeCookie("lang");
        	$.cookie("lang", selvalue, {
        		path: "/"
        	});
        	
			if (redirect.indexOf("?") > -1)
			{
				p = redirect.substring(0, redirect.indexOf("?"));
				hv = redirect.substring(redirect.indexOf("?") + 1);
				h = hv.split("&");
				
				for (i=0; i < h.length; i++)
				{
					if (h[i].substring(0, 5) == "lang=")
					{
						h[i] = h[i].substring(0, 5) + selvalue;
						s = true;
						break;
					}
				}
				
				hv = h.join("&");
				
				redirect = p + "?" + hv;
			}
			
			if (s == true)
			{
				bg.show();
				
				setTimeout(function() {
					window.location.replace(redirect);
				}, 100);
			}
		}
	});
	
	$("#b_theme" + (instance.id)).bind("change", function(e) {
        var b_theme = $("#b_theme" + (instance.id)),
            selvalue = $("option:selected", b_theme).val(),
            redirect = $(location).attr('href'),
            p, hv, h = {},
            k, v,
            i, s = false;
        
        if (selvalue != ig$.theme_id)
        {
        	$.removeCookie("theme");
        	$.cookie("theme", selvalue, {
        		path: "/"
        	});
        	
            if (redirect.indexOf("?") > -1)
            {
                p = redirect.substring(0, redirect.indexOf("?"));
                hv = redirect.substring(redirect.indexOf("?") + 1);
                h = hv.split("&");
                
                for (i=0; i < h.length; i++)
                {
                    if (h[i].substring(0, 6) == "theme=")
                    {
                        h[i] = h[i].substring(0, 6) + selvalue;
                        s = true;
                        break;
                    }
                }
                
                if (!s)
                {
                	h.push("theme=" + selvalue);
                	s = true;
                }
                
                hv = h.join("&");
                
                redirect = p + "?" + hv;
            }
            
            if (s == true)
            {
                bg.show();
                
                setTimeout(function() {
                    window.location.replace(redirect);
                }, 100);
            }
        }
    });
		
	$('#login_btn' + (instance.id)).bind('click', function() {
		var userid = $('#userid' + (instance.id)).val(),
			passwd = $('#userpassword' + (instance.id)).val();
		
		if (!userid)
		{
			IG$.ShowError(IRm$.r1("L_BLANK_USERID"));
			return false;
		}
		
		if (!passwd)
		{
			IG$.ShowError(IRm$.r1("L_BLANK_PASSWORD"));
			return false;
		}
		
		IG$.doStartSession(instance, userid, passwd, bg, mts);
		return false;
	});
	$('#userpassword' + (instance.id)).bind('keypress', function(e) {
		if (e.keyCode == 13)
		{
			var userid = $('#userid' + (instance.id))[0].value,
				passwd = $('#userpassword' + (instance.id))[0].value;
			
			if (!userid)
			{
				IG$.ShowError(IRm$.r1("L_BLANK_USERID"));
				return false;
			}
			
			if (!passwd)
			{
				IG$.ShowError(IRm$.r1("L_BLANK_PASSWORD"));
				return false;
			}
			
			IG$.doStartSession(instance, userid, passwd, bg, mts);
			
			return false;
		}
		
		return true;
	});

	$("#twoway_validate" + (instance.id)).bind("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        var twoway_key = $("#twoway_key" + (instance.id)).val();
        $("#twoway_key" + (instance.id)).val("");
        $(this).blur();
        
        if (!twoway_key)
        {
            IG$.ShowError(IRm$.r1("L_BLANK_TWOWAY_KEY"));
            return false;
        }
        
        IG$.val2FA(twoway_key, null, window.m$mts);
        return false;
    });

    $("#twoway_key" + (instance.id)).bind("keyup", function(e) {
        if (e.keyCode == 13)
        {
            e.preventDefault();
            e.stopPropagation();

            var twoway_key = $("#twoway_key" + (instance.id)).val();
            $("#twoway_key" + (instance.id), loginWindow).val("");
            $(this).blur();
            
            if (!twoway_key)
            {
                IG$.ShowError(IRm$.r1("L_BLANK_TWOWAY_KEY"));
                return false;
            }
            
            IG$.val2FA(twoway_key, null, window.m$mts);
            return false;
        }
    });

	$("#twoway_key" + (instance.id)).bind("done", function(e) {
		var twoway_key = $("#twoway_key" + (instance.id)).val();
		$("#twoway_key" + (instance.id), loginWindow).val("");
		$(this).blur();
		
		if (!twoway_key)
		{
			IG$.ShowError(IRm$.r1("L_BLANK_TWOWAY_KEY"));
			return false;
		}
		
		IG$.val2FA(twoway_key, null, window.m$mts);
		return false;
    });

    $("#twoway_retry" + (instance.id)).bind("click", function(e) {
        e.preventDefault();
        e.stopPropagation();

        $("#login_path").show();
        $("#twoway_form").hide();

        return false;
    });

	IRm$.r2/*loadResources*/({
        func: function() {
        	IG$.chkSess(instance, null, function() {
                IG$.chkSvrInfo(instance, function() {
                    $('#loginWindow').show();
                });
            });
            
            IG$.showLogin(instance);
        }
    }, false);
}

$(document).ready(function() {
	parseLocation();
	setTimeout(function() {
		$("#loading").remove();
		$("#loading-mask").remove();
	}, 100);
	initPage();
});
</script>
</head>
<body scroll="no">
	<div id="loading-mask" style=""></div>
	<div id="loading">
		<div class="cmsg">
			<div class="msg">Loading Amplix...</div>
			<div class="lpb">
				<div id="lpt" style="width: 10%;"></div>
			</div>
		</div>
	</div>
</body>
</html>