package wonder.work;


import org.springframework.stereotype.Component;
import wonder.scheduleJob.ScheduleJob;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Created by sujinxian on 2017/4/12.
 */
@Component
@ScheduleJob(name = "卢春晓的批量任务", cron = "0 0/1 * * * ? ", method = "exec")
public class EchoRuningText {

    public void exec() {
        System.out.println("schedule EchoRuningText is running ! ");
        System.out.println(LocalDateTime.now());
    }

}
