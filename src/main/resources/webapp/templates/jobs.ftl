<!DOCTYPE html>
<html>
<head lang="zh">
<meta charset="UTF-8" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>调度管理</title>
<link rel="stylesheet" href="/css/bootstrap.min.css" />
<style type="text/css">
	.text-red {
		color: red;
	}
	.text-purple {
		color: rgb(128, 0, 255);
	}
	#msg {
		text-align: center;
		color: red;
	}
</style>
</head>
<body>
<nav class="navbar navbar-default navbar-static-top">
	<ul class="nav navbar-nav">
		<li class="active"><a href="#">调度管理</a></li>
		<li><a href="#">调度日志</a></li>
		<li><a href="/druid">数据源监控</a></li>
	</ul>
</nav>

<div class="container-fluid">
	<table align="center" class="table table-bordered table-hover table-condensed">
		<tr>
			<th width="3%">编号</th>
			<th width="15%">名称</th>
			<th width="8%">执行周期</th>
			<th width="7%">上次任务状态</th>
			<th width="7%">当前任务状态</th>
			<th width="10%">最后一次运行时间</th>
			<th width="8%">上一次运行时长(ms)</th>
			<th width="10%">下次执行时间</th>
			<th width="8%">下次执行间隔</th>
			<th width="5%">失败次数</th>
			<th width="5%">总执行次数</th>
			<th width="5%">调度状态</th>
			<th width="9%">操作</th>
		</tr>
		<#list jobs?values as value>
			<td></td>
			<td>${value.jobProxy.name}</td>
			<td>${value.jobProxy.cron}</td>
		</#list>
	</table>
</div>
</body>