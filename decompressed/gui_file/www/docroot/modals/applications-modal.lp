--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-core')

local lp = require("web.lp")
local proxy = require("datamodel")
local ui_helper = require("web.ui_helper")
local message_helper = require("web.uimessage_helper")
local content_helper = require("web.content_helper")
local format,sub,match,untaint = string.format, string.sub, string.match, string.untaint

local function appapply(action)
  proxy.set("rpc.system." .. action, "1")
  lp.flush()
  if ( action == "install_emptyblacklist" ) then
	action = "install_blacklist"
  end
  local uci_set = action:gsub("(.*)_","")
  local action_type = action:gsub("_(.*)","")
  if action_type == "install" then
	state = "1"
  else
	state = "0"
  end
  if not ( uci_set == "blacklist" ) and not ( uci_set == "xupnp" ) then
	proxy.set("uci.env.var." .. uci_set .. "_webui",state)
  else
	proxy.set("uci.env.var." .. uci_set .. "_app",state)
  end
  ngx.header.content_type = "application/json"
  ngx.print('{ "success":"true" }')
  ngx.timer.at(0, function()
    proxy.apply()
  end)
  ngx.exit(ngx.HTTP_OK)
end

if ngx.req.get_method() == "POST" then
  local action = ngx.req.get_post_args().action
  -- do not call get_post_args before we know that we don't have a file sent otherwise it will fail
  if action == "install_luci" then
	return appapply("install_luci")
  end
  if action == "remove_luci" then
	return appapply("remove_luci")
  end
  if action == "install_aria2" then
	return appapply("install_aria2")
  end
  if action == "remove_aria2" then
	return appapply("remove_aria2")
  end
  if action == "install_telstra" then
	return appapply("install_telstra")
  end
  if action == "remove_telstra" then
	return appapply("remove_telstra")
  end
  if action == "install_transmission" then
	return appapply("install_transmission")
  end
  if action == "remove_transmission" then
	return appapply("remove_transmission")
  end
  if action == "install_blacklist" then
	return appapply("install_blacklist")
  end
  if action == "install_emptyblacklist" then
	return appapply("install_emptyblacklist")
  end
  if action == "remove_blacklist" then
	return appapply("remove_blacklist")
  end
  if action == "install_xupnp" then
	return appapply("install_xupnp")
  end
  if action == "remove_xupnp" then
	return appapply("remove_xupnp")
  end
end

local mapParams = {
	marketing_version = "uci.version.version.@version[0].marketing_version",
	luci_webui = "uci.env.var.luci_webui",										 
    aria2_webui = "uci.env.var.aria2_webui",
    transmission_webui = "uci.env.var.transmission_webui",
	local_ip_modem = "uci.network.interface.@lan.ipaddr",
	blacklist_application = "uci.env.var.blacklist_app",
	xupnp_application = "uci.env.var.xupnp_app",
	telstra_webui = "uci.env.var.telstra_webui",
}
content_helper.getExactContent(mapParams)

local StateParams = {}

for Params in pairs(mapParams) do
	if mapParams[Params] and mapParams[Params] == "1" then
		StateParams[Params] = ""
	else
		StateParams[Params] = T"not"
	end
end
	
ngx.print('\
\
');  ngx.print(ui_helper.createHeader(T"Application List", false, false))   ngx.print('\
<div class="modal-body update">\
');  
ngx.print(ui_helper.createMessages(message_helper.popMessages()))

  ngx.print('\
<fieldset>\
    <form class="form-horizontal" method="post" action="modals/applications-modal.lp">\
    ');  
	  local info_box = {
        alert = {
			class = "alert alert-info",
		}
      }
	  local install_luci = {
        button = {
          id = "btn-install-luci"
        }
      }
	  local remove_luci = {
        button = {
          id = "btn-remove-luci"
        }
      }
      local html = {}
	  html[#html+1] = '<div class="span3">'
	  html[#html+1] = "<fieldset>"
	  html[#html + 1] = '<legend>' .. T"Luci GUI" .. '</legend>'
	  html[#html + 1] = ui_helper.createAlertBlock(T"This will install uhttpd and luci", info_box)
	  html[#html + 1] = T"State: "
	  html[#html + 1] = "<strong>" .. T"Luci is " .. StateParams["luci_webui"] .. T" installed" .. "</strong></br>"
	  local luci_link = format("http://%s:9080",mapParams.local_ip_modem)
	  html[#html + 1] = T"Webui on: " .. '<a target="_blank" href="' .. luci_link .. '">' .. luci_link .. "</a>"
	  html[#html + 1] = "</br>"
	  html[#html + 1] = "</br>"
	  if mapParams["luci_webui"] and mapParams["luci_webui"] == "1" then
		html[#html + 1] = ui_helper.createSimpleButton(T"Remove Luci", "icon-refresh", remove_luci)
	  else
		html[#html + 1] = ui_helper.createSimpleButton(T"Install Luci", "icon-refresh", install_luci)
	  end
	  html[#html + 1] = "</br>"
	  html[#html+1] = "</fieldset>"
	  html[#html+1] = "</div>"
	  local install_aria2 = {
        button = {
          id = "btn-install-aria2"
        }
      }
	  local remove_aria2 = {
        button = {
          id = "btn-remove-aria2"
        }
      }
	  html[#html+1] = '<div class="span3">'
	  html[#html+1] = "<fieldset>"
	  html[#html + 1] = '<legend>' .. T"Aria2 GUI" .. '</legend>'
	  html[#html + 1] = ui_helper.createAlertBlock(T"This will install aria2 and ariang webui", info_box)
	  html[#html + 1] = T"State: "
	  html[#html + 1] = "<strong>" .. T"Aria2 is " .. StateParams["aria2_webui"] .. T" installed" .. "</strong></br>"
	  local aria_link = format("http://%s/aria",mapParams.local_ip_modem)  
	  html[#html + 1] = T"Webui on: " .. '<a target="_blank" href="' .. aria_link .. '">' .. aria_link .."</a>"
	  html[#html + 1] = "</br>"
	  html[#html + 1] = "</br>"
	  if mapParams["aria2_webui"] and mapParams["aria2_webui"] == "1" then
		html[#html + 1] = ui_helper.createSimpleButton(T"Remove Aria2", "icon-refresh", remove_aria2)
	  else
		html[#html + 1] = ui_helper.createSimpleButton(T"Install Aria2", "icon-refresh", install_aria2)
	  end
	  html[#html+1] = "</fieldset>"
	  html[#html+1] = "</div>"
	  local install_transmission = {
        button = {
          id = "btn-install-transmission"
        }
      }
	  local remove_transmission = {
        button = {
          id = "btn-remove-transmission"
        }
      }
	  html[#html+1] = '<div class="span4">'
	  html[#html+1] = "<fieldset>"
	  html[#html + 1] = '<legend>' .. T"Transmission GUI" .. '</legend>'
	  html[#html + 1] = ui_helper.createAlertBlock(T"This will install transmission and transmission-webui", info_box)
	  html[#html + 1] = T"State: "
	  html[#html + 1] = "<strong>" .. T"Transmission is " .. StateParams["transmission_webui"] .. T" installed" .. "</strong></br>"
	  local transmission_link = format("http://%s/transmission/web/",mapParams.local_ip_modem) 
	  html[#html + 1] = T"Webui on: " .. '<a target="_blank" href="' .. transmission_link .. '">' .. transmission_link .."</a>"
	  html[#html + 1] = "</br>"
	  local transmission_direct_link = format("http://%s:9091/transmission",mapParams.local_ip_modem)
	  html[#html + 1] = T" (or " .. '<a target="_blank" href="' .. transmission_direct_link .. '">' .. transmission_direct_link .. "</a>" .. " )"
	  html[#html + 1] = "</br>"
	  html[#html + 1] = "</br>"
	  if mapParams["transmission_webui"] and mapParams["transmission_webui"] == "1" then
		html[#html + 1] = ui_helper.createSimpleButton(T"Remove Transmission", "icon-refresh", remove_transmission)
	  else
		html[#html + 1] = ui_helper.createSimpleButton(T"Install Transmission", "icon-refresh", install_transmission)
	  end
	  html[#html+1] = "</fieldset>"
	  html[#html+1] = "</div>"
	  html[#html + 1] = "</br>"
	  local install_blacklist = {
        button = {
          id = "btn-install-blacklist"
        }
      }
	  local install_empty_blacklist = {
        button = {
          id = "btn-install-empty-blacklist"
        }
      }
	  local remove_blacklist = {
        button = {
          id = "btn-remove-blacklist"
        }
      }
	  html[#html+1] = '<div class="span3">'
	  html[#html+1] = "<fieldset>"
	  html[#html + 1] = '<legend>' .. T"Blacklist App" .. '</legend>'
	  html[#html + 1] = ui_helper.createAlertBlock(T"This will install the blacklist application", info_box)
	  html[#html + 1] = T"State: "
	  html[#html + 1] = "<strong>" .. T"The Blacklist app is " .. StateParams["blacklist_application"] .. T" installed" .. "</strong></br>"
	  local blacklist_link = "http://blacklist.satellitar.it/"
	  html[#html + 1] = T"Support site: " .. '<a  target="_blank" href="' .. blacklist_link .. '">' .. blacklist_link .."</a>"
	  html[#html + 1] = "</br>"
	  html[#html + 1] = "</br>"
	  if mapParams["blacklist_application"] and mapParams["blacklist_application"] == "1" then
		html[#html + 1] = ui_helper.createSimpleButton(T"Remove Blacklist", "icon-refresh", remove_blacklist)
		html[#html + 1] = ui_helper.createSimpleButton(T"Update blacklist app", "icon-refresh", install_empty_blacklist)
	  else
		html[#html + 1] = ui_helper.createSimpleButton(T"Install Blacklist", "icon-refresh", install_blacklist)
		html[#html + 1] = ui_helper.createSimpleButton(T"Install empty blacklist", "icon-refresh", install_empty_blacklist)
	  end
	  
	  html[#html+1] = "</fieldset>"
	  html[#html+1] = "</div>"
	  html[#html + 1] = "</br>"
	  if tonumber(mapParams.marketing_version:sub(1,4)) >= 17.3 then
		local install_xupnp = {
			button = {
			id = "btn-install-xupnp"
			}
		}
		local remove_xupnp = {
			button = {
			id = "btn-remove-xupnp"
			}
		}
		html[#html+1] = '<div class="span3">'
		html[#html+1] = "<fieldset>"
		html[#html + 1] = '<legend>' .. T"XUPnP App" .. '</legend>'
		html[#html + 1] = ui_helper.createAlertBlock(T"This will install the XUPnP application", info_box)
		html[#html + 1] = T"State: "
		html[#html + 1] = "<strong>" .. T"The XUPnP app is " .. StateParams["xupnp_application"] .. T" installed" .. "</strong></br>"
		local xupnp_link = format("http://%s:4044/ui/",mapParams.local_ip_modem) 
		html[#html + 1] = T"Webui on: " .. '<a target="_blank" href="' .. xupnp_link .. '">' .. xupnp_link .."</a>"
		html[#html + 1] = "</br>"
		html[#html + 1] = "</br>"
		if mapParams["xupnp_application"] and mapParams["xupnp_application"] == "1" then
			html[#html + 1] = ui_helper.createSimpleButton(T"Remove XUPnP", "icon-refresh", remove_xupnp)
		else
			html[#html + 1] = ui_helper.createSimpleButton(T"Install XUPnP", "icon-refresh", install_xupnp)
		end
		html[#html+1] = "</fieldset>"
		html[#html + 1] = "</br>"
		html[#html+1] = "</div>"
	  end
	  local install_telstra = {
        button = {
          id = "btn-install-telstra"
        }
      }
	  local remove_telstra = {
        button = {
          id = "btn-remove-telstra"
        }
      }
	  html[#html+1] = '<div class="span3">'
	  html[#html+1] = "<fieldset>"
	  html[#html + 1] = '<legend>' .. T"Telstra GUI" .. '</legend>'
	  html[#html + 1] = ui_helper.createAlertBlock(T"This will install Telstra webui", info_box)
	  html[#html + 1] = T"State: "
	  html[#html + 1] = "<strong>" .. T"Telstra is " .. StateParams["telstra_webui"] .. T" installed" .. "</strong></br>"
	  local telstra_gui = "/telstra-gui.lp"
	  html[#html + 1] = T"Webui on: " .. '<a target="_blank" href="' .. telstra_gui .. '">' .. telstra_gui .."</a>"
	  html[#html + 1] = "</br>"
	  html[#html + 1] = T"Change the default page in system-extra to set this gui as default"
	  html[#html + 1] = "</br>"
	  if mapParams["telstra_webui"] and mapParams["telstra_webui"] == "1" then
		html[#html + 1] = ui_helper.createSimpleButton(T"Remove Telstra GUI", "icon-refresh", remove_telstra)
	  else
		html[#html + 1] = ui_helper.createSimpleButton(T"Install Telstra GUI", "icon-refresh", install_telstra)
	  end
	  html[#html+1] = "</fieldset>"
	  html[#html+1] = "</div>"
      ngx.print(html)
      ngx.print('\
    </form>\
  </fieldset>\
</div>\
\
<script>\
(function() {\
  var target = $(".modal form").attr("action");\
  var installMsg = "');  ngx.print(T'Installing...'); ngx.print('";\
  var removeMsg = "');  ngx.print(T'Removing...'); ngx.print('";\
\
  function post(action,processMsg) {\
    $.post(\
      target,\
      { action: action, CSRFtoken: $("meta[name=CSRFtoken]").attr("content") },\
      null,\
      "json"\
    );\
	tch.showProgress(processMsg);\
    return false;\
  }\
  $("#btn-install-luci").on("click", function() {\
     post("install_luci",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-luci").on("click", function() {\
     post("remove_luci",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-aria2").on("click", function() {\
     post("install_aria2",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-aria2").on("click", function() {\
     post("remove_aria2",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-telstra").on("click", function() {\
     post("install_telstra",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-telstra").on("click", function() {\
     post("remove_telstra",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-transmission").on("click", function() {\
     post("install_transmission",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-transmission").on("click", function() {\
     post("remove_transmission",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-blacklist").on("click", function() {\
     post("install_blacklist",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-empty-blacklist").on("click", function() {\
     post("install_emptyblacklist",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-blacklist").on("click", function() {\
     post("remove_blacklist",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-install-xupnp").on("click", function() {\
     post("install_xupnp",installMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
  $("#btn-remove-xupnp").on("click", function() {\
     post("remove_xupnp",removeMsg);\
	 setTimeout(function(){location.reload();}, 2000);\
     });\
}());\
</script>\
');  ngx.print(ui_helper.createFooter())   ngx.print('\
');