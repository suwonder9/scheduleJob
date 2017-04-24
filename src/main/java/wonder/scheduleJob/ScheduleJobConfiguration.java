package wonder.scheduleJob;

import org.quartz.JobDataMap;
import org.quartz.Trigger;
import org.quartz.impl.JobDetailImpl;
import org.quartz.impl.triggers.CronTriggerImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.util.ClassUtils;

import java.text.ParseException;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

@Configuration
@ConditionalOnBean(annotation = ScheduleJob.class)
public class ScheduleJobConfiguration {
    private static final ProxyJobFactory JOB_FACTORY = new ProxyJobFactory();

    @Autowired
    private ConfigurableApplicationContext context;

    @Autowired
    private Environment env;

    @Bean
    public Runnable createAbstractScheduleFactoryBean() throws ParseException {
        DefaultListableBeanFactory beanFactory = (DefaultListableBeanFactory) context.getBeanFactory();
        //根据注解查询所有的调度任务类
        Map<String, Object> jobMaps = beanFactory.getBeansWithAnnotation(ScheduleJob.class);
        Object[] jobs = jobMaps.values().toArray();
        //创建新指定任务数的线程
        Executor taskExecutor = Executors.newFixedThreadPool(jobMaps.size());

        for (int i = 0; i < jobMaps.size(); i++) {
            Object obj = jobs[i];
            //获取ScheduleJob具体类
            ScheduleJob job = ClassUtils.getUserClass(obj).getAnnotation(ScheduleJob.class);
            //设置任务代理类
            JobProxy jobProxy = new JobProxy();
            //设值调度类
            jobProxy.setJob(new ExecutionJobImpl(obj,job.method()));
            jobProxy.setName(job.name());
            jobProxy.setCron(job.cron());

            //创建触发器
            Trigger trigger = createTrigger(jobProxy);

            BeanDefinitionBuilder beanDefinitionBuilder = BeanDefinitionBuilder.rootBeanDefinition(AbstractScheduleFactoryBean.class);
            beanDefinitionBuilder.addPropertyValue("taskExecutor",taskExecutor);
            beanDefinitionBuilder.addPropertyValue("triggers",trigger);
            beanDefinitionBuilder.addPropertyValue("autoStartup",job.autoStartup());
            beanDefinitionBuilder.addPropertyValue("startupDelay",job.startupDelay());
            beanDefinitionBuilder.addPropertyValue("jobFactory",JOB_FACTORY);
            beanDefinitionBuilder.addPropertyValue("jobProxy",jobProxy);

            beanFactory.registerBeanDefinition(""+i,beanDefinitionBuilder.getBeanDefinition());

            System.out.println("初始化job 成功，"+job.name());
        }

        return null;
    }

    /**
     * 创建触发器  触发任务的执行
     *
     * @param jobProxy
     * @return
     * @throws ParseException
     */
    private static Trigger createTrigger(JobProxy jobProxy) throws ParseException {
        String name = jobProxy.getName();

        //jobDataMap 是JobDetail的成员，并添加了一些便利的方法用于存储与读取原生类型数据，
        // 里面包含了当Job实例运行时，你希望提供给它的所有数据对象
        JobDataMap jobDataMap = new JobDataMap();
        jobDataMap.put("jobProxy",jobProxy);

        JobDetailImpl jobDetail = new JobDetailImpl();
        jobDetail.setName(name);
        jobDetail.setJobClass(JobProxy.class);
        jobDetail.setJobDataMap(jobDataMap);

        jobDataMap.put("jobDetail",jobDetail);

        CronTriggerImpl trigger = new CronTriggerImpl();
        trigger.setJobKey(jobDetail.getKey());
        trigger.setName(name);
        trigger.setJobDataMap(jobDataMap);
        trigger.setCronExpression(jobProxy.getCron());

        return trigger;
    }

}
