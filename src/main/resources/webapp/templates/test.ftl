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
	<table align="center" class="table table-bordered">
		<tr>
			<td width="3%">编号</td>
			<td width="15%">名称</td>
			<td width="8%">执行周期</td>
			<td width="7%">上次任务状态</td>
			<td width="7%">当前任务状态</td>
			<td width="10%">最后一次运行时间</td>
			<td width="8%">上一次运行时长(ms)</td>
			<td width="10%">下次执行时间</td>
			<td width="8%">下次执行间隔</td>
			<td width="5%">失败次数</td>
			<td width="5%">总执行次数</td>
			<td width="5%">调度状态</td>
			<td width="9%">操作</td>
		</tr>
		<#list jobs?keys as key>
			<#if jobs[key].isRunning()>
				<tr>
			<#else>
				<tr class="danger">
			</#if>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.jobId}</td>
				<td style="vertical-align: middle;">
					<a href="/job/log/${jobs[key].jobProxy.uuid!}/1">${jobs[key].jobProxy.name!}</a>
				</td>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.cron!}</td>
				<td style="vertical-align: middle;">
					<#if jobs[key].jobProxy.prevStatus! == '执行失败'>
						<span class="text-red">${jobs[key].jobProxy.prevStatus!}</span>
					<#else>
						${jobs[key].jobProxy.prevStatus!}
					</#if>
				</td>
				<td style="vertical-align: middle;">
					<#if jobs[key].jobProxy.currentStatus! == '执行失败'>
						<span class="text-red">${jobs[key].jobProxy.currentStatus!}</span>
					<#else>
						${jobs[key].jobProxy.currentStatus!}
					</#if>
				</td>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.lastExecTime}</td>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.prevTimespent}</td>
				<td style="vertical-align: middle;">${jobs[key].getNextDateTime()}</td>
				<td style="vertical-align: middle;">${jobs[key].getNextInterval()}</td>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.failCount}</td>
				<td style="vertical-align: middle;">${jobs[key].jobProxy.count}</td>
				<td style="vertical-align: middle;">
					<#if jobs[key].isRunning()>
						运行中
					<#else>
						已停止
					</#if>
				</td>
				<td style="vertical-align: middle;">
					<#if jobs[key].isRunning()>
						<a class="jobStop" jobId="${key?substring(1)}" href="#">停止</a>
						<#if jobs[key].jobProxy.currentStatus! != '正在执行'>
							&nbsp;&nbsp;<a class="runJob" jobId="${key?substring(1)}" href="#">立即执行</a>
						</#if>
					<#else>
						<a class="jobStart" jobId="${key?substring(1)}" href="#">启动</a>
					</#if>
				</td>
			</tr>
		</#list>
	</table>
</div>
<script src="/js/jquery.min.js"></script>
<script type="text/javascript">
$(document).ready(function() { 
	$(".jobStop").click(function(){
		if(confirm("确定要停止该任务"))
		{
			$.post('/job/stop/'+$(this).attr('jobId'), {}, function(resp){
				if(resp == '1')
				{
					window.location.reload();
				}
				else
				{
					alert('操作失败');
				}
			});
		}
	});
	$(".jobStart").click(function(){
		if(confirm("确定要启动该任务"))
		{
			$.post('/job/start/'+$(this).attr('jobId'), {}, function(resp){
				if(resp == '1')
				{
					window.location.reload();
				}
				else
				{
					alert('操作失败');
				}
			});
		}
	});
	$(".runJob").click(function(){
		if(confirm("确定要立即执行该任务"))
		{
			$.post('/job/run/'+$(this).attr('jobId'), {}, function(resp){
				if(resp == '1')
				{
					window.location.reload();
				}
				else
				{
					alert('操作失败');
				}
			});
		}
	});
});
</script>
</body>