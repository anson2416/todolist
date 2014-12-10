import "dart:html";import "dart:convert";import "dart:async";WebSocket k;var t=JSON.decode(querySelector("#config").text);void main(){q();querySelector("#submit").onClick.listen((MouseEvent j){print("Send mesaage");var h=querySelector("#editor div div div .editor");h.querySelectorAll("br").forEach((Element j){j.text="<{#}>";});var n=querySelector(".colors .fa.fa-check").id;var o=JSON.encode({'Type':'new','Data':{'channel':'piazza','content':h.text,'color':n}});print(h.text);k.send(o);h.text="";querySelector("button.close").click();});querySelectorAll(".dropdown-menu li a .fa-times").forEach((Element EB){s(EB.parent);});var m=querySelectorAll(".colors .color-box");const l=" fa fa-check";for(Element g in m){g.onClick.listen((MouseEvent j){var FB=g.id;var i=g.getAttribute("class");if(i.indexOf(l)==-1){g.setAttribute("class",i+l);for(Element g in m){if(g.id!=FB){i=g.getAttribute("class").replaceAll(l,"");g.setAttribute("class",i);}}}});}}void q([int i=2]){var n=false;print("Connecting to websocket");k=new WebSocket('ws://127.0.0.1:${t["port"]}/ws');void o(){if(!n){new Timer(new Duration(milliseconds:1000*i),()=>q(i*2));}n=true;}k.onOpen.listen((j){print('Connected');i=2;});k.onClose.listen((j){print('Websocket closed, retrying in ${i} seconds');o();});k.onError.listen((j){print("Error connecting to ws");o();});k.onMessage.listen((MessageEvent j){var h=JSON.decode(j.data.toString());switch (h["Type"]){case "newMsg":var g;switch (h["Data"]["Color"]){case 0:g="default";break;case 1:g="red";break;case 2:g="pink";break;case 3:g="orange";break;case 4:g="yellow";break;case 5:g="lime";break;case 6:g="green";break;case 7:g="teal";break;case 8:g="blue";break;case 9:g="indigo";break;case 10:g="deep-purple";break;case 11:g="purple";break;}var l=new Element.html('''
          <div id="${h["Data"]["ID"]}" class="col-xs-12 col-sm-6 col-md-4">
		      	<div class="content">
			      	<div class="panel-body">${h["Data"]["Content"]}</div>
              <div class="panel-footer ${g}">
                <i class="fa fa-clock-o"></i><a>time</a>
                <div class="btn-group">
                  <a data-toggle="dropdown"><i class="fa fa-ellipsis-v"></i></a>
                  <ul class="dropdown-menu">
                    <li>
                      <a><i class="fa fa-check"></i> 标记为已完成</a>
                    </li>
                    <li class="divider"></li>
                    <li>
                      <a><i class="fa fa-times"></i> 删除</a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        ''');s(l.querySelector(".dropdown-menu li a .fa-times").parent);var m=querySelector("body .container .row div");if(m==null){querySelector("body .container .row").append(l);}else{m.parent.insertBefore(l,m);}break;case "error":print(h["Data"]);break;}});}void s(Element g){g.onClick.listen((MouseEvent i){var h=g.parent.parent.parent.parent.parent.parent;h.remove();k.send(JSON.encode({'Type':'remove','Data':{'id':h.id}}));});}const GB='mangledGlobalNames';class u{static const String HB="Chrome";static const String IB="Firefox";static const String JB="Internet Explorer";static const String KB="Opera";static const String LB="Safari";final String DB;final String minimumVersion;const u(this.DB,[this.minimumVersion]);}class v{const v();}class AB{final String name;const AB(this.name);}class BB{const BB();}class CB{const CB();}