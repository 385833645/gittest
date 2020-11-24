<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="weaver.general.Util" %>
<%@ page import="weaver.hrm.HrmUserVarify" %>
<%@ page import="weaver.hrm.User" %>
<%@ page import="weaver.general.BaseBean" %>
<%@ page import="weaver.general.AES" %>
<%
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user = HrmUserVarify.getUser (request , response) ;
    if (user == null) {
        response.sendRedirect("/login/Login.jsp");
        return;
    }
    String requestid = Util.null2String(request.getParameter("requestid"));
    String gotoPage = "/workflow/request/DevViewRequest.jsp";
    if(!"".equals(requestid)){
        String tempurl = "";
        BaseBean baseBean = new BaseBean();
        try {
            gotoPage += "?para="+AES.encrypt(requestid+"#"+user.getLoginid(),"forwardpage");

            String para = gotoPage + "" + "#" + user.getLoginid() ;
            String password=new BaseBean().getPropValue("AESpassword", "pwd");
            if(password.equals(""))password="1";
            para = AES.encrypt(para,password);

            String tz_address = Util.null2String(baseBean.getPropValue("TzOAInfo","tz_address")).trim();
            tempurl = tz_address+"/login/VerifySSoLogin.jsp?para=" + para;
            //System.out.println("==tempurl:"+tempurl);
        } catch (Exception e) {
            new BaseBean().writeLog(">>>>>>>/interface/workflow/ForwardPage.jsp "+e);
        }
        if("sysadmin".equals(user.getLoginid())){
            String tz_tntrance = Util.null2String(baseBean.getPropValue("TzOAInfo","tz_tntrance")).trim();
            response.sendRedirect(tz_tntrance+"&gopage="+gotoPage);
            return;
        }
        if(!"".equals(tempurl))response.sendRedirect(tempurl);
        else out.println("异常！");
        return;
    }
%>
