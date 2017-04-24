package wonder.scheduleJob;

import org.springframework.scheduling.quartz.SchedulerFactoryBean;

/**
 * 创建ScheduleFactoryBean
 */
public class AbstractScheduleFactoryBean extends SchedulerFactoryBean {

    private JobProxy jobProxy;

    public JobProxy getJobProxy() {
        return jobProxy;
    }

    public void setJobProxy(JobProxy jobProxy) {
        this.jobProxy = jobProxy;
    }
}
