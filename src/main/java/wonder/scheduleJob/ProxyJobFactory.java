package wonder.scheduleJob;


import org.quartz.Job;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.spi.JobFactory;
import org.quartz.spi.TriggerFiredBundle;


public class ProxyJobFactory implements JobFactory {

    /**
     * 创建一个新的调度任务
     *
     * @param bundle
     * @param scheduler
     * @return
     * @throws SchedulerException
     */
    public Job newJob(TriggerFiredBundle bundle, Scheduler scheduler) throws SchedulerException {
        return (Job)bundle.getJobDetail().getJobDataMap().get("jobProxy");
    }
}
