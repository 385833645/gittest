
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="weaver.general.*"%>
<%@ page import="java.util.*"%>
<%@ page import="weaver.hrm.*"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ page import="net.sf.json.JSONObject"%>
<%@ page import="weaver.conn.RecordSetDataSource" %>
<jsp:useBean id="TzWorkflowUtil" class="weaver.interfaces.workflow.util.TzWorkflowUtil" scope="page" />

<%!
    public JSONArray sortArray(JSONArray array,String resourceids){
		JSONArray array2 = new JSONArray();
	    String[] resources = resourceids.split(",");
	    for(String resource:resources){
	    	for(int i = 0;i< array.size();i++){
	    		if(array.getJSONObject(i).get("requestid").equals(resource)){
	    			array2.add(array.getJSONObject(i));
	    		}
	    	}
	    }
	    //System.err.print(array2.toString());
	    return array2;
	}
%>
<%
    request.setCharacterEncoding("utf8");
	String f_weaver_belongto_userid=request.getParameter("f_weaver_belongto_userid");
	String f_weaver_belongto_usertype=request.getParameter("f_weaver_belongto_usertype");//需要增加的代码
	if("".equals(f_weaver_belongto_userid)){
	   f_weaver_belongto_userid = Util.null2String((String)session.getAttribute("f_weaver_belongto_userid"));
	}
	if("".equals(f_weaver_belongto_usertype)){
	   f_weaver_belongto_usertype = Util.null2String((String)session.getAttribute("f_weaver_belongto_usertype"));
	}
	User user = HrmUserVarify.getUser(request, response, f_weaver_belongto_userid, f_weaver_belongto_usertype) ;//需要增加的代码
	if (user == null) {
		response.sendRedirect("/login/Login.jsp");
		return;
	}

	int userid = TzWorkflowUtil.getUserId(user.getLoginid());
	if(userid < 1){
		response.sendRedirect("/notice/noright.jsp") ;
		return;
	}
	RecordSetDataSource rs = TzWorkflowUtil.getRs();
	new BaseBean().writeLog(">>>MultiRequestBrowserAjax.jsp DatasourceId:"+TzWorkflowUtil.getTzDatasourceId());
	String resourceids = Util.null2String(request.getParameter("systemIds"));
	if(resourceids.startsWith(",")){
		resourceids=resourceids.substring(1);
	}
	String src = Util.null2String(request.getParameter("src"));
	JSONArray jsonArr = new JSONArray();
	JSONObject json = new JSONObject();
	JSONObject tmp = new JSONObject();
	if (resourceids.trim().startsWith(",")) {
		resourceids = resourceids.substring(1);
	}
	String excludeId = Util.null2String(request.getParameter("excludeId"));
	if(excludeId.startsWith(",")){
		excludeId=excludeId.substring(1);
	}

	if ("dest".equalsIgnoreCase(src)) {
		if (!"".equals(resourceids)) {
			String sql = "select requestid,creatertype,requestname, requestnamenew,creater,createdate,createtime,workflowid from workflow_requestbase where requestid in ("	+ resourceids + ")";
			rs.executeSql(sql);
			while (rs.next()) {
				String request_id = Util.null2String(rs.getString("requestid"));
				String creater_name = Util.null2String(rs.getString("creater"));
				String create_date = Util.null2String(rs.getString("createdate"));
				String create_time = Util.null2String(rs.getString("createtime"));
				String request_name = Util.null2String(rs.getString("requestname"));
				String request_name_new = Util.null2String(rs.getString("requestnamenew"));
				String workflowid = Util.null2String(rs.getString("workflowid"));
                String titles = "";
		        if (!"".equals(request_name_new) && !request_name.equals(request_name_new)) {
		            if (request_name_new.indexOf(request_name_new) != -1) {
		                titles = request_name_new.substring(request_name.length() - 1, request_name_new.length());
		            }
		        }
				if (!titles.equals(""))
					request_name=request_name+"<B>("+titles+")</B>";
				String createtype = Util.null2String(rs.getString("createtype"));
				if ("1".equals(createtype)){
					creater_name=TzWorkflowUtil.getCustomerInfoname(creater_name);
				}else{
					creater_name=TzWorkflowUtil.getResourcename(creater_name);
				}
				tmp.put("requestid", request_id);
				tmp.put("requestname",request_name);
				tmp.put("creater", creater_name);
				tmp.put("createtime", create_date + " " + create_time);
				jsonArr.add(tmp);
			}
			jsonArr = sortArray(jsonArr,resourceids);
			json.put("currentPage", 1);
			json.put("totalPage", 1);
			json.put("mapList", jsonArr.toString());
			out.println(json.toString());
			return;
		} else {
			json.put("currentPage", 1);
			json.put("totalPage", 1);
			json.put("mapList", jsonArr.toString());
			out.println(json.toString());
			return;
		}
	}
	String createdatestart = Util.null2String(request.getParameter("createdatestart"));
	String createdateend = Util.null2String(request.getParameter("createdateend"));
	String requestmark = Util.null2String(request.getParameter("requestmark"));
	String workflowid = Util.null2String(request.getParameter("currworkflowid"));
	String department = Util.null2String(request.getParameter("department"));
	String requestname = Util.null2String(request.getParameter("requestname"));
	String creater = Util.null2String(request.getParameter("creater"));
	String usertype = "0";
	if (user.getLogintype().equals("2"))
		usertype = "1";

	StringBuffer sqlwhere = new StringBuffer();
	if (!requestname.equals("")) {
		sqlwhere.append(" and a.requestnamenew like '%" + Util.fromScreen2(requestname, user.getLanguage()) + "%' ");
	}
	if (!createdatestart.equals("")) {
		sqlwhere.append(" and a.createdate >='" + createdatestart + "' ");
	}
	if (!createdateend.equals("")) {
		sqlwhere.append(" and a.createdate <='" + createdateend + "' ");
	}
	if (!workflowid.equals("") && !workflowid.equals("0")) {
		if(!workflowid.equals("-999")){
			sqlwhere.append(" and a.workflowid in ( " + TzWorkflowUtil.getAllVersionStringByWFIDs(workflowid) + ")");
		}else{
			sqlwhere.append(" and a.workflowid in ("+workflowid+")");
		}
	}

	if (!creater.equals("") && department.equals("")) {
		sqlwhere.append(" and a.creater in (select id from hrmresource where lastname='"+creater+"' ) and a.creatertype=0 ");
	}

	if (!department.equals("")) {
	    String s = "";
	    if(!creater.equals("")){
	        s = " and h.lastname='"+creater+"' ";
		}
		sqlwhere.append(" and a.creater in (select h.id from hrmresource h,hrmdepartment d where h.departmentid=d.id "+s+" and d.departmentname like '%" + department + "%')");
	}

	if (!requestmark.equals("")) {
		sqlwhere.append(" and a.requestmark like '%" + requestmark + "%' ");
	}

	if (sqlwhere.equals(""))
		sqlwhere.append(" and a.requestid > 0 ");
		
	if (rs.getDBType().equals("oracle")) {
		sqlwhere.append(" and (nvl(a.currentstatus,-1) = -1 or (nvl(a.currentstatus,-1)=0 and a.creater="+ userid + ")) ");
	} else {
		sqlwhere.append(" and (isnull(a.currentstatus,-1) = -1 or (isnull(a.currentstatus,-1)=0 and a.creater=" + userid + ")) ");
	}
	sqlwhere.append(" and b.requestid = a.requestid ");
	sqlwhere.append(" and b.userid in ("+userid+")" );
    sqlwhere.append(" and b.usertype="+usertype
            +" and a.workflowid = c.id" 
            +" and c.isvalid in (1,3) and (c.istemplate is null or c.istemplate<>'1')");
	
    sqlwhere.append(" and islasttimes=1 ");
	
	String sqlend=" order by createdate desc, createtime desc";
	String sqlstr = "";
	int perpage = Util.getIntValue(request.getParameter("pageSize"), 10);
	int pagenum = Util.getIntValue(request.getParameter("currentPage"),1);
	if (rs.getDBType().equals("oracle")) {
		sqlstr = "select * from (select row_number() over(order by createdate desc, createtime desc) rn,a.requestid,a.requestname,a.requestnamenew,a.creater,a.createdate,a.createtime,a.creatertype,a.workflowid from workflow_requestbase a, workflow_currentoperator b, workflow_base c "
	    +" where 1=1 "+sqlwhere.toString()+" ) where rn > "+(pagenum-1)*perpage+" and rn <="+pagenum*perpage+sqlend;
	}else{
	    sqlstr = "select top "+perpage+" a.requestid,a.requestname,a.requestnamenew,a.creater,a.createdate,a.createtime,a.creatertype,a.workflowid from workflow_requestbase a, workflow_currentoperator b, workflow_base c "
	    +" where a.requestid not in (select top "+(pagenum-1)*perpage+" a.requestid from workflow_requestbase a where 1=1 "+sqlwhere.toString()+sqlend+")"
	    +sqlwhere.toString()+sqlend;
	}
	//new weaver.general.BaseBean().writeLog("流程查询SQL========"+sqlstr);
    rs.executeSql(sqlstr);
    while(rs.next()){
		String request_id = Util.null2String(rs.getString("requestid"));
		String creater_name = Util.null2String(rs.getString("creater"));
		String create_date = Util.null2String(rs.getString("createdate"));
		String create_time = Util.null2String(rs.getString("createtime"));
		String request_name = Util.null2String(rs.getString("requestname"));
		String createtype = Util.null2String(rs.getString("creatertype"));
		String request_name_new = Util.null2String(rs.getString("requestnamenew"));
		String titles = "";
		if (!"".equals(request_name_new) && !request_name.equals(request_name_new)) {
			if (request_name_new.indexOf(request_name_new) != -1) {
				titles = request_name_new.substring(request_name.length() - 1, request_name_new.length());
			}
		}
		if (!titles.equals(""))
			request_name=request_name+"<B>("+titles+")</B>";
		if ("1".equals(createtype)){
				creater_name=TzWorkflowUtil.getCustomerInfoname(creater_name);
			}else{
				creater_name=TzWorkflowUtil.getResourcename(creater_name);
		}
		tmp.put("requestid", request_id);
		tmp.put("requestname",request_name);
		tmp.put("creater", creater_name);
		tmp.put("createtime", create_date + " " + create_time);
		jsonArr.add(tmp);
	}
	json.put("currentPage", pagenum);
	//json.put("totalPage", totalPage);
	json.put("sql",sqlstr);
	json.put("mapList", jsonArr.toString());
	//System.out.println(sqlstr);
	out.println(json.toString());
	return;
%>