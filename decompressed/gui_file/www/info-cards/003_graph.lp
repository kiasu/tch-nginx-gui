--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-core')

local proxy = require("datamodel")
local ui_helper = require("web.ui_helper")

local  format = string.format

local interface = proxy.get("uci.network.interface.@wan.ifname")

if interface and ( proxy.get("uci.network.interface.@wan.up") == "1" ) then
	local int_rx = format("/sys/class/net/%s/statistics/rx_bytes",interface[1].value)
	local int_tx = format("/sys/class/net/%s/statistics/tx_bytes",interface[1].value)
	
	local file = io.open(int_rx,"r")
	local rx_traffic = file:read()
	file:close()
	file = io.open(int_tx,"r")
	local tx_traffic = file:read()
	file:close()

  ngx.print('\
\
<div class="infocard" id="graphtab">\
  <div class="smallcard">\
    ');  ngx.print( ui_helper.createCardHeader(T"WAN Traffic", nil, nil, nil, nil) ); ngx.print('\
    <div class="content card_bg" data-bg-text="&#xf129;">\
	<div class="divtable">\
	<form class="form-horizontal">\
	<fieldset>');
	
	local html = {}
	html[#html + 1] = '<div style="height:400px; width:700px"><canvas id="WANChart"></canvas></div>'
	html[#html + 1] = '<div id="rx_traffic_complete" class="hide" data-bind="text: rx_traffic_complete">' .. rx_traffic .. '</div>'
	html[#html + 1] = '<div id="tx_traffic_complete" class="hide" data-bind="text: tx_traffic_complete">' .. tx_traffic .. '</div>'
	
	ngx.print(html)
ngx.print('\
	  </fieldset>\
	  </form>\
	  </div>\
    </div>\
  </div>\
</div>\
<script>\
function formatBytes(bytes,decimals) {\
   if(bytes == 0) return "0 Bytes";\
	var k = 1024,\
    dm = decimals || 2,\
    sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],\
    i = Math.floor(Math.log(bytes) / Math.log(k));\
   return (bytes / Math.pow(k, i)) > 0 ? parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i] : "0";\
}\
var TrafficChartOption = {\
		responsive:true,\
		maintainAspectRatio: false,\
        legend: {display: false},\
        scales: {\
		xAxes: [{\
                display: false\
            }],\
		yAxes: [{ticks: {\
				min: 0,\
				callback: function(value) { \
					return formatBytes(value,2) \
				},}}],},\
		tooltips: {\
                enabled: true,\
                mode: "single",\
                callbacks: {\
                    label: function(tooltipItems, data) { \
                        return formatBytes(tooltipItems.yLabel , 2);},\
					title: function(tooltipItems, data) {\
						return;}}},\
		spanGaps:true,\
		legend: {display: false},};\
var wan_ctx = document.getElementById("WANChart").getContext("2d");\
var wanRxdatasets = [];\
var wanTxdatasets = [];\
var timelabel = [];\
var WANChart = new Chart(wan_ctx, {\
    type: "line",\
    data: {labels: timelabel,\
	"datasets":[{"data":wanRxdatasets,\
			"pointBackgroundColor": "#90cd8a",\
			"backgroundColor": "#90cd8a50",\
		},\
		{"data":wanTxdatasets,\
			"pointBackgroundColor": "#f58368",\
			"backgroundColor": "#f5836850",\
    }]},\
    options: TrafficChartOption \
});\
var InfoGraphCardInterval;\
$(document).ready(function () {\
	var InfoGraphCardBinding = { \
		rx_traffic_complete: ko.observable(),\
		tx_traffic_complete: ko.observable(),\
	};\
	function InfoGraphCardRefresh() {\
		var tx_traffic_complete = document.getElementById("tx_traffic_complete");\
		var rx_traffic_complete = document.getElementById("rx_traffic_complete");\
		if (tx_traffic_complete) {\
			var tx_traffic_old = tx_traffic_complete.textContent;\
			var rx_traffic_old = rx_traffic_complete.textContent;\
			var interface = "'); ngx.print(interface[1].value); ngx.print('";\
			$.post("/ajax/traffic_graph.lua?interface=" + interface + \
				"&oldrx=" + rx_traffic_old + "&oldtx=" + tx_traffic_old,\
				[tch.elementCSRFtoken()], function(data) {\
					var rx_traffic = data.rx_traffic-data.old_rx_traffic;\
					var tx_traffic = data.tx_traffic-data.old_tx_traffic;\
					InfoGraphCardBinding.rx_traffic_complete(data.rx_traffic);\
					InfoGraphCardBinding.tx_traffic_complete(data.tx_traffic);\
					var date = new Date();\
					timelabel.push(date.getHours()+":"+date.getMinutes()+":"+date.getSeconds());\
					wanRxdatasets.push(rx_traffic);\
					wanTxdatasets.push(tx_traffic);\
					if (wanTxdatasets.length > 30) {\
						wanTxdatasets.shift();\
						wanRxdatasets.shift();\
						timelabel.shift();\
					}\
					WANChart.update();\
			}, "json");\
		};\
	};\
\
	InfoGraphCardRefresh();\
	ko.applyBindings(InfoGraphCardBinding, document.getElementById("graphtab"));\
	InfoGraphCardInterval = setInterval(InfoGraphCardRefresh, 10000);\
	KoRequest.push(InfoGraphCardInterval);\
})\
</script>\
'); 

end
