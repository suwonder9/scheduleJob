<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>调度日志</title>
<link rel="stylesheet" href="/css/bootstrap.min.css" />
</head>
<body>
<nav class="navbar navbar-default navbar-static-top">
	<ul class="nav navbar-nav">
		<li><a href="/job/list">调度管理</a></li>
		<li class="active"><a href="#">调度日志</a></li>
		<li><a href="/druid">数据源监控</a></li>
	</ul>
</nav>
<div class="container-fluid">
	<table align="center" class="table table-bordered">
		<tr>
			<td width="3%">编号</td>
			<td width="15%">名称</td>
			<td width="5%">状态</td>
			<td width="10%">开始时间</td>
			<td width="10%">结束时间</td>
			<td width="7%">运行时长(ms)</td>
			<td width="50%">错误信息</td>
		</tr>
		<#list logs as log>
			<tr>
				<td>${log_index+1}</td>
				<td>${log['name']}</td>
				<td>${log['status']!}</td>
				<td>${log['beginTime']!}</td>
				<td>${log['endTime']!}</td>
				<td>${log['runDuration']!}</td>
				<td>${log['errorMsg']!}</td>
			</tr>
		</#list>
	</table>
</div>
<ul class="pager">
	<li>总共${count}/共${size}页</li>
	<#if page lte 1>
		<li><a href="#">Previous</a></li>
	<#else>
		<li><a href="/job/log/${id}/${page-1}">Previous</a></li>
	</#if>
	
  	<#if page gte size>
		<li><a href="#">Next</a></li>
	<#else>
		<li><a href="/job/log/${id}/${page+1}">Next</a></li>
	</#if>
</ul>
</body>
</html>