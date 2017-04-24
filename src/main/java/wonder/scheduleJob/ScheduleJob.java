package wonder.scheduleJob;

import java.lang.annotation.*;

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface ScheduleJob {
    /**
     * job 名称
     */
    public String name();

    /**
     * cron表达式
     */
    public String cron();

    /**
     * 启动方法
     */
    public String method();

    /**
     * 自动启动
     */
    public boolean autoStartup() default true;

    /**
     * 延迟多久启动（单位：秒）
     */
    public int startupDelay() default 0;
}
