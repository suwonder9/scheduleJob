package wonder.scheduleJob;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.quartz.Job;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.lang.reflect.InvocationTargetException;

/**
 * 任务代理类
 */
public class JobProxy implements Job {

    private Log logger = LogFactory.getLog(JobProxy.class);

    private ExecutionJob job;

    private String name;

    private String cron;

    /**
     * 执行job
     *
     * @param context
     * @throws JobExecutionException
     */
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        try {
            JobDetail jobDetail = context.getJobDetail();
            logger.info("jobDetail = "+jobDetail);
            logger.info("job name = "+jobDetail.getClass().getName());
            logger.info("job .class = "+jobDetail.getJobClass());
            job.execute();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }

    public ExecutionJob getJob() {
        return job;
    }

    public void setJob(ExecutionJob job) {
        this.job = job;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCron() {
        return cron;
    }

    public void setCron(String cron) {
        this.cron = cron;
    }
}
