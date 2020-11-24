<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="/browserTag" prefix="brow"%>
<%@ taglib uri="/WEB-INF/weaver.tld" prefix="wea"%>
<%@ page import="weaver.general.Util,java.text.SimpleDateFormat" %>
<%@ page import="java.util.*"%>
<%@ page import="weaver.conn.RecordSetDataSource" %>
<%@ page import="weaver.workflow.workflow.WorkflowComInfo" %>
<%@ include file="/systeminfo/init_wev8.jsp" %>
<jsp:useBean id="TzWorkflowUtil" class="weaver.interfaces.workflow.util.TzWorkflowUtil" scope="page" />

<HTML>
	<HEAD>
		<LINK rel="stylesheet" type="text/css" href="/css/Weaver_wev8.css">
		<SCRIPT language="javascript" src="/js/weaver_wev8.js"></script>
		<script language=javascript src="/workplan/calendar/src/Plugins/jquery.form_wev8.js"></script>
		<script type="text/javascript" src="/js/ecology8/base/jquery-ui_wev8.js"></script>
		<script type="text/javascript" src="/js/dragBox/ajaxmanager_wev8.js"></script>
		<script type="text/javascript" src="/js/dragBox/rightspluingForBrowserNew_wev8.js"></script>
		<script type='text/javascript' src='/js/jquery-autocomplete/jquery.autocomplete_wev8.js'></script>
		<script type="text/javascript">
			var parentWin = null;
			var dialog = null;
			var config = null;
			try {
				parentWin = parent.parent.getParentWindow(parent);
				dialog = parent.parent.getDialog(parent);
			} catch (e) {
			}
			jQuery(document).ready(function(){
                try{
                    parent.jQuery("#objName").html("<%=SystemEnv.getHtmlLabelName(	33924,user.getLanguage())%>");
				}catch (e) {
                }
			});
		</script>
		<link type="text/css" href="/js/dragBox/e8browser_wev8.css" rel=stylesheet>
		<style type="text/css">
		.LayoutTable .fieldName {
			padding-left:20px!important;
		}
		</style>
	</HEAD>

	<%
		String f_weaver_belongto_userid=Util.fromScreen(request.getParameter("f_weaver_belongto_userid"),user.getLanguage());
		String f_weaver_belongto_usertype=request.getParameter("f_weaver_belongto_usertype");//需要增加的代码
		if("".equals(f_weaver_belongto_userid)){
		   f_weaver_belongto_userid = Util.null2String((String)session.getAttribute("f_weaver_belongto_userid"));
		}
		if("".equals(f_weaver_belongto_usertype)){
		   f_weaver_belongto_usertype = Util.null2String((String)session.getAttribute("f_weaver_belongto_usertype"));
		}
		user = HrmUserVarify.getUser(request, response, f_weaver_belongto_userid, f_weaver_belongto_usertype) ;//需要增加的代码
		if (user == null) {
			response.sendRedirect("/login/Login.jsp");
			return;
		}
		String usertype = "0";
		if("2".equals(user.getLogintype())) usertype = "1";

		int userid = TzWorkflowUtil.getUserId(user.getLoginid());
		if(userid < 1){
			response.sendRedirect("/notice/noright.jsp") ;
			return;
		}
		RecordSetDataSource rs = TzWorkflowUtil.getRs();
		String requestname = Util.null2String(request.getParameter("requestname"));
		String creater = Util.null2String(request.getParameter("creater"));
		String createdatestart = Util.null2String(request.getParameter("createdatestart"));
		String createdateend = Util.null2String(request.getParameter("createdateend"));
		String requestmark = Util.null2String(request.getParameter("requestmark"));
		String department = Util.null2String(request.getParameter("department"));
		String workflowid = Util.null2String(request.getParameter("workflowid"));
		String currworkflowid = Util.null2String(request.getParameter("currworkflowid"));
		if(!"".equals(workflowid) && currworkflowid.equals("")){
		    String currworkflowname = Util.null2String(new WorkflowComInfo().getWorkflowname(workflowid));
			currworkflowid = TzWorkflowUtil.getWorkflowID(currworkflowname)+""; //当前系统的流程 转换成外部系统表的流程
			if("-1".equals(currworkflowid))currworkflowid="";
		}
		String workflowname = TzWorkflowUtil.getWorkflowname(currworkflowid);

        //搜索时获取systemIds,第一次弹出时取resourceids
		String resourceids = Util.null2String(request.getParameter("systemIds"));
		if ("".equals(resourceids)) {
			resourceids = Util.null2String(request.getParameter("beanids"));
		}
		String resourcenames = Util.null2String(request.getParameter("resourcenames"));

		int __requestid = Util.getIntValue(request.getParameter("__requestid"));
		int _fna_wfid = Util.getIntValue(request.getParameter("fna_wfid"));
		int _fna_fieldid = Util.getIntValue(request.getParameter("fna_fieldid"));

	%>
	<BODY scroll="no" style="overflow-x: hidden;overflow-y:hidden">
	<table id="topTitle" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		</td>
		<td class="rightSearchSpan" style="text-align:right;">
			<input type="button" value="<%=SystemEnv.getHtmlLabelName(197,user.getLanguage())%>" class="e8_btn_top"  onclick="javascript:doSearch(),_self"/>
			<span title="<%=SystemEnv.getHtmlLabelName(23036,user.getLanguage())%>" class="cornerMenu"></span>
		</td>
	</tr>
	</table>
	<%@ include file="/systeminfo/RightClickMenuConent_wev8.jsp" %>

		<div class="zDialog_div_content">
		<FORM id=weaver name=SearchForm style="margin-bottom: 0" action="MultiRequestBrowser.jsp" method=post onsubmit="btnOnSearch();return false;">
			<input type="hidden" name="pagenum" id="pagenum" value=''>
			<input type="hidden" name="resourceids" value="">
			<input type="hidden" name="issearch" id="issearch"  >

			<div style="width:0px;height:0px;overflow:hidden;">
				<button type=submit></BUTTON>
			</div>

			<DIV align=right style="display: none">
				<%
					RCMenu += "{" + SystemEnv.getHtmlLabelName(197, user.getLanguage()) + ",javascript:document.SearchForm.btnsearch.click(),_self} ";
					RCMenuHeight += RCMenuHeightStep;
				%>
				<button type="button" class=btnSearch accessKey=S type=submit id=btnsearch onclick="javascript:doSearch(),_self"> <U>S</U>-<%=SystemEnv.getHtmlLabelName(197, user.getLanguage())%></BUTTON>
				<%
					RCMenu += "{" + SystemEnv.getHtmlLabelName(826, user.getLanguage()) + ",javascript:btn_ok(),_self} ";
					RCMenuHeight += RCMenuHeightStep;
				%>
				<button type="button" class=btn accessKey=O id=btnok onclick="btn_ok();"><U>O</U>-<%=SystemEnv.getHtmlLabelName(826, user.getLanguage())%></BUTTON>
				<%
					RCMenu += "{"+ SystemEnv.getHtmlLabelName(201, user.getLanguage())+ ",javascript:btn_cancel(),_self} ";
					RCMenuHeight += RCMenuHeightStep;
				%>
				<button type="button" class=btnReset accessKey=T type=reset id=btncancel onclick="btn_cancel();">	<U>T</U>-<%=SystemEnv.getHtmlLabelName(201, user.getLanguage())%></BUTTON>
				<%
					RCMenu += "{"+ SystemEnv.getHtmlLabelName(311, user.getLanguage())+ ",javascript:btn_clear(),_self} ";
					RCMenuHeight += RCMenuHeightStep;
				%>
				<button type="button" class=btn accessKey=2 id=btnclear onclick="btn_clear();"><U>2</U>-<%=SystemEnv.getHtmlLabelName(311, user.getLanguage())%></BUTTON>
			</DIV>
			<div id="e8QuerySearchArea" style="overflow:auto;height: 155px;">
			<wea:layout type="4col">
				<wea:group attributes="{'groupSHBtnDisplay':'none'}" context="<%=SystemEnv.getHtmlLabelName(15774, user.getLanguage())%>">
					<wea:item><%=SystemEnv.getHtmlLabelName(26876, user.getLanguage())%></wea:item>
					<wea:item><input name="requestname" class="Inputstyle" value='<%=requestname%>' /></wea:item>
					<wea:item><%=SystemEnv.getHtmlLabelName(33806, user.getLanguage())%></wea:item>
					<wea:item>
						<span>
							<brow:browser viewType="0" name="currworkflowid"
										 browserValue='<%=currworkflowid%>'
										 browserUrl="/systeminfo/BrowserMain.jsp?url=/interface/CommonBrowser.jsp?type=browser.tzWorkBaseBrowser"
										 hasInput="true" isSingle="true" hasBrowser="true"
										 isMustInput='1' linkUrl="#" width="80%"
										 completeUrl="/data.jsp?type=161&fielddbtype=browser.tzWorkBaseBrowser"
										 browserSpanValue='<%=workflowname%>'></brow:browser>
						</span>
					</wea:item>

					<wea:item><%=SystemEnv.getHtmlLabelName(714, user.getLanguage())%></wea:item>
					<wea:item><input name="requestmark" class="Inputstyle" value='<%=requestmark%>' /></wea:item>

					<wea:item><%=SystemEnv.getHtmlLabelName(882, user.getLanguage())%></wea:item>
					<wea:item>
						<input name="creater" class="Inputstyle" value='<%=creater%>' />
					</wea:item>

					<wea:item><%=SystemEnv.getHtmlLabelName(19225, user.getLanguage())%></wea:item>
					<wea:item>
						<input name="department" class="Inputstyle" value='<%=department%>' />
					</wea:item>

					<wea:item><%=SystemEnv.getHtmlLabelName(722, user.getLanguage())%></wea:item>
					<wea:item><button type="button" class=Calendar id=selectbirthday onclick="getTheDate(createdatestart,createdatestartspan)"></BUTTON>
						<SPAN id=createdatestartspan><%=createdatestart%></SPAN>
						- &nbsp;<button type="button" class=Calendar id=selectbirthday1 onclick="getTheDate(createdateend,createdateendspan)"></BUTTON>
						<SPAN id=createdateendspan><%=createdateend%></SPAN>
						<input type="hidden" id="createdatestart" name="createdatestart" value="<%=createdatestart%>">
						<input type="hidden" id="createdateend" name="createdateend" value="<%=createdateend%>">
					</wea:item>
				</wea:group>
			</wea:layout>
			</div>

			<div id="dialog">
				<div id='colShow'></div>
			</div>
			<input type="hidden" name="f_weaver_belongto_userid" value="<%=request.getParameter("f_weaver_belongto_userid") %>">
			<input type="hidden" name="f_weaver_belongto_usertype" value="<%=request.getParameter("f_weaver_belongto_usertype") %>">
			<input type="hidden" id="browserhref" name="browserhref" value="/interface/workflow/ForwardPage.jsp?requestid=">
		</FORM>
		</div>
		<script type="text/javascript">
		var parentWin = null;
		var dialog = null;
		var config = null;
		try {
			parentWin = parent.parent.getParentWindow(parent);
			dialog = parent.parent.getDialog(parent);
		} catch (e) {
		}
		function showMultiRequestDialog(selectids) {
			config = rightsplugingForBrowser.createConfig();
			config.srchead = [ "<%=SystemEnv.getHtmlLabelName(33569, user.getLanguage())%>", "<%=SystemEnv.getHtmlLabelName(882, user.getLanguage())%>", "<%=SystemEnv.getHtmlLabelName(1339, user.getLanguage())%>" ];
			config.container = jQuery("#colShow");
		    config.searchLabel="";
		    config.hiddenfield="requestid";
		    config.saveLazy = true;//取消实时保存
		    config.saveurl= "/interface/workflow/MultiRequestBrowserAjax.jsp?f_weaver_belongto_userid=<%=user.getUID()%>&f_weaver_belongto_usertype=<%=usertype%>&src=save&fna_wfid=<%=_fna_wfid%>&fna_fieldid=<%=_fna_fieldid%>&__requestid=<%=__requestid%>";
		    config.srcurl = "/interface/workflow/MultiRequestBrowserAjax.jsp?f_weaver_belongto_userid=<%=user.getUID()%>&f_weaver_belongto_usertype=<%=usertype%>&src=src&fna_wfid=<%=_fna_wfid%>&fna_fieldid=<%=_fna_fieldid%>&__requestid=<%=__requestid%>";
		    config.desturl = "/interface/workflow/MultiRequestBrowserAjax.jsp?f_weaver_belongto_userid=<%=user.getUID()%>&f_weaver_belongto_usertype=<%=usertype%>&src=dest&fna_wfid=<%=_fna_wfid%>&fna_fieldid=<%=_fna_fieldid%>&__requestid=<%=__requestid%>";
		    config.delteurl= "/interface/workflow/MultiRequestBrowserAjax.jsp?f_weaver_belongto_userid=<%=user.getUID()%>&f_weaver_belongto_usertype=<%=usertype%>&src=save&fna_wfid=<%=_fna_wfid%>&fna_fieldid=<%=_fna_fieldid%>&__requestid=<%=__requestid%>";
		    config.pagesize = 10;
		    config.formId = "weaver";
		    config.formatCallbackFn = function(config,destMap,destMapKeys){
		         var ids="",names="";
		         var nameKey = destMap["__nameKey"];
		         for(var i=0;destMapKeys&&i<destMapKeys.length;i++){	              
						var key = destMapKeys[i];
						var dataitem = destMap[key];
						var name = dataitem[nameKey];
						if(name.indexOf("<B>")!=-1){
						   name = name.substring(0,name.indexOf("<B>"));
						}
						if(ids==""){
							ids = key;
						}else{
							ids = ids+","+key;
						}
						if(names==""){
		        			names = name;
		        		}else{
		        			names=names + ","+name;
		        		}
				}
		         return {id:ids,name:names};
		    },
		    config.selectids = selectids;
		    config.searchAreaId = "e8QuerySearchArea";
			try{
				config.dialog = dialog;
			}catch(e){
			   console.log(e);
			}
		   	jQuery("#colShow").html("");
		    rightsplugingForBrowser.createRightsPluing(config);
		
		    jQuery("#btn_Ok").bind("click",function(){
		    	rightsplugingForBrowser.system_btnok_onclick(config);
		    });
		    jQuery("#btn_Clear").bind("click",function(){
				rightsplugingForBrowser.system_btnclear_onclick(config);
		    });
		    jQuery("#btn_Cancel").bind("click",function(){	    	
				rightsplugingForBrowser.system_btncancel_onclick(config);
		    });
		    jQuery("#btn_Search").bind("click",function(){
		    	rightsplugingForBrowser.system_btnsearch_onclick(config);
		    });
		 
		}
		
		function btnOnSearch(){
		    jQuery("#btn_Search").trigger("click");
		}
		function onClose(){
			try{
				if(dialog){
					jQuery("#btn_Cancel").trigger("click");
				}else{
					window.parent.close();
				}
			}catch(e){
				window.parent.close();
			}
		}
		function onReset(){
			SearchForm.reset();
		}
		function doSearch()
		{
		    btnOnSearch();
		}
		jQuery(document).ready(function(){
			showMultiRequestDialog("<%=resourceids%>");
		});
		
		function btn_ok(){
	        jQuery("#btn_Ok").trigger("click");
	    }
		function btn_search(){
        	jQuery("#btn_Search").trigger("click");
    	}
		function btn_cancel(){
        	jQuery("#btn_Cancel").trigger("click");
   		}
		function btn_clear(){
        	jQuery("#btn_Clear").trigger("click");
        }
	</script>
		<div id="zDialog_div_bottom" class="zDialog_div_bottom"  style="padding:0px!important;">
		<div style="padding:5px 0px;">
			<wea:layout needImportDefaultJsAndCss="false">
				<wea:group context="" attributes='{\"groupDisplay\":\"none\"}'>
					<wea:item type="toolbar">
					 
						<input type="button" style="display: none;" class=zd_btn_submit
							accessKey=S id=btn_Search
							value="S-<%=SystemEnv.getHtmlLabelName(197, user
										.getLanguage())%>"></input>
					
						<input type="button" class=zd_btn_submit accessKey=O id=btn_Ok
							value="O-<%=SystemEnv.getHtmlLabelName(826, user
										.getLanguage())%>"></input>
						<input type="button" class=zd_btn_submit accessKey=2 id=btn_Clear
							value="2-<%=SystemEnv.getHtmlLabelName(311, user
										.getLanguage())%>"></input>
						<input type="button" class=zd_btn_cancle accessKey=T id=btn_Cancel
							value="T-<%=SystemEnv.getHtmlLabelName(201, user
										.getLanguage())%>"></input>
					</wea:item>
				</wea:group>
			</wea:layout>
			</div>
</div>
<%@ include file="/systeminfo/RightClickMenu_wev8.jsp" %>
</BODY></HTML>

<script>

jQuery(".e8_sep_line:eq(0)").hide();


 function BrowseTable_onmouseover(event){
    var eventObj =event.srcElement ? event.srcElement : event.target;
	if(eventObj.tagName =='TD'){
		jQuery(eventObj).parents("tr:first")[0].className="Selected";
	}else if (eventObj.tagName == 'A'){
		jQuery(eventObj).parents("tr:first")[0].className="Selected";
	}
 }
 
 function BrowseTable_onmouseout(event){
    var eventObj =event.srcElement ? event.srcElement : event.target;
	if(eventObj.tagName =='TD'||eventObj.tagName == 'A'){
		var trObj =jQuery(eventObj).parents("tr:first")[0];
		if(trObj.rowIndex%2 == 0)
			trObj.className ="DataLight";
		else
			trObj.className ="DataDark";
	}
 }
 
 function BrowseTable_onclick(event){
    var e =event.srcElement ? event.srcElement : event.target;
	if(e.tagName == "TD" || e.tagName == "A"){
		//var newEntry = e.parentElement.cells(0).innerText+"~"+e.parentElement.cells(1).innerText ;
		var node = $(e).closest("tr").children("td:first");
		var newEntry = $(node).text();
		newEntry = newEntry + "~" +  $(node).next().text();
		if(!isExistEntry(newEntry,resourceArray)){
			addObjectToSelect(document.all("srcList"),newEntry);
			reloadResourceArray();
		}
	}
 }
 
 function btnok_onclick(){
	 setResourceStr();
	 var returnjson = {id:resourceids,name:resourcenames};
     if(dialog){
	    try{
	        dialog.callback(returnjson);
	    }catch(e){}
		try{
	        dialog.close(returnjson);
		}catch(e){}
	}else{ 
	   	window.parent.returnValue = returnjson;
		window.parent.close();
	 }
 }
 function btnclear_onclick(){
 	var returnjson = {id:"",name:"",fieldtype:"",options:""}; 
	if(dialog){
	    try{
	        dialog.callback(returnjson);
	    }catch(e){}
		try{
	        dialog.close(returnjson);
		}catch(e){}
	}else{ 
	   	window.parent.returnValue = returnjson;
		window.parent.close();
	 }
 }
 function btncancel_onclick(){
	if(dialog) {
		dialog.close();
	} else { 
	    window.parent.close();
   	}
 }
 
 jQuery("#BrowseTable").bind("mouseover",BrowseTable_onmouseover);
 jQuery("#BrowseTable").bind("mouseout",BrowseTable_onmouseout);
 jQuery("#BrowseTable").bind("click",BrowseTable_onclick);
 
 jQuery("#btnok").bind("click",btnok_onclick);
 jQuery("#btnclear").bind("click",btnclear_onclick);
</script>

<script language="javascript">
resourceids = "<%=resourceids%>";
resourcenames = "<%=resourcenames%>";

//Load
var resourceArray = new Array();
for(var i =1;i<resourceids.split(",").length;i++){
	
	resourceArray[i-1] = resourceids.split(",")[i]+"~"+resourcenames.split(",")[i];
	//alert(resourceArray[i-1]);
}

loadToList();
function loadToList(){
	var selectObj = document.all("srcList");
	for(var i=0;i<resourceArray.length;i++){
		addObjectToSelect(selectObj,resourceArray[i]);
	}
	
}

function addObjectToSelect(obj,str){
	if(!!!obj || obj.tagName != "SELECT") return;
	var oOption = document.createElement("OPTION");
	obj.options.add(oOption);
	//oOption.value = str.split("~")[0];
	$(oOption).val(str.split("~")[0]);
	//oOption.innerText = str.split("~")[1];
	$(oOption).text(str.split("~")[1]);
	
}

function isExistEntry(entry,arrayObj){
	for(var i=0;i<arrayObj.length;i++){
		if(entry == arrayObj[i].toString()){
			return true;
			
		}
	}
	return false;
}

function upFromList(){
	var destList  = document.all("srcList");
	//var len = destList.options.length;
	var len = $(destList).children("option").size();
	for(var i = 0; i <= (len-1); i++) {
		if ((destList.options[i] != null) && (destList.options[i].selected == true)) {
			if(i>0 && destList.options[i-1] != null){
				fromtext = destList.options[i-1].text;
				fromvalue = destList.options[i-1].value;
				totext = destList.options[i].text;
				tovalue = destList.options[i].value;
				destList.options[i-1] = new Option(totext,tovalue);
				destList.options[i-1].selected = true;
				destList.options[i] = new Option(fromtext,fromvalue);		
			}
      }
   }
   reloadResourceArray();
}
function addToList(){
	var str = document.all("forAddSingleClick").value;
	if(!isExistEntry(str,resourceArray)&&str!=""){
		addObjectToSelect(document.all("srcList"),str);
		document.all("forAddSingleClick").value="";
	}		
	reloadResourceArray();
}
function addAllToList(){
	var table =$("#BrowseTable");
	$("#BrowseTable").find("tr").each(function(){
		var str=$($(this)[0].cells[0]).text()+"~"+$($(this)[0].cells[1]).text();
		if(!isExistEntry(str,resourceArray))
			addObjectToSelect($("select[name=srcList]")[0],str);
	});
	reloadResourceArray();
}

function def(obj){
	if(obj==null||obj=="undefined"||obj=="")return false;
	return true;
}

function deleteFromList(){
	var destList  = document.all("srcList");
	var options = $(destList).children("option");
	options.each(function(){
		if(def($(this).attr("selected"))){
			$(this).remove();
		}
	});
	$(destList).closest("select").attr("style", "width:100%");
	reloadResourceArray();
}
function deleteAllFromList(){
	var destList  = document.all("srcList");
	var options = $(destList).children("option");
	var len = options.size();
	for(var i = (len-1); i >= 0; i--) {
	if ($(options[i]) != null) {
	         $(options[i]).remove();
		  }
	}
	reloadResourceArray();
}
function downFromList(){
	var destList  = document.all("srcList");
	
	var len = destList.options.length;
	for(var i = (len-1); i >= 0; i--) {
		if ((destList.options[i] != null) && (destList.options[i].selected == true)) {
			if(i<(len-1) && destList.options[i+1] != null){
				fromtext = destList.options[i+1].text;
				fromvalue = destList.options[i+1].value;
				totext = destList.options[i].text;
				tovalue = destList.options[i].value;
				destList.options[i+1] = new Option(totext,tovalue);
				destList.options[i+1].selected = true;
				destList.options[i] = new Option(fromtext,fromvalue);		
			}
      }
   }
   reloadResourceArray();
}
//reload resource Array from the List
function reloadResourceArray(){
	resourceArray = new Array();
	var destList = document.all("srcList");
	var options = $(destList).children("option");
	for(var i=0;i<options.size();i++){
		
		resourceArray[i] = $(options[i]).val()+"~"+$(options[i]).text();//destList.options[i].value+"~"+destList.options[i].text ;
	}
	//alert(resourceArray.length);
}

function setResourceStr(){
	
	resourceids ="";
	resourcenames = "";
	for(var i=0;i<resourceArray.length;i++){
		resourceids += ","+resourceArray[i].split("~")[0] ;
		resourcenames += ","+resourceArray[i].split("~")[1] ;
	}
	//alert(resourceids+"--"+resourcenames);
	document.all("resourceids").value = resourceids.substring(1)
}

function doSearch()
{
    //document.getElementById("issearch").value="issearch";
	//setResourceStr();
    //document.all("resourceids").value = resourceids.substring(1) ;
    //document.SearchForm.submit();
    btnOnSearch();
}

</SCRIPT>
<SCRIPT language="javascript"  defer="defer" src="/js/datetime_wev8.js"></script>
<SCRIPT language="javascript"  src="/js/selectDateTime_wev8.js"></script>
<SCRIPT language="javascript" defer="defer" src='/js/JSDateTime/WdatePicker_wev8.js?rnd="+Math.random()+"'></script>