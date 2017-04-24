package wonder.controller;

import org.apache.catalina.servlet4preview.http.HttpServletRequest;
import org.omg.CORBA.Object;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import wonder.scheduleJob.AbstractScheduleFactoryBean;

import java.util.Map;

/**
 * Created by Administrator on 2017/4/19 0019.
 */
@Controller
@RequestMapping("/scheduleJob")
public class ScheduleJobController {

    @Autowired
    private ApplicationContext context;

    @GetMapping("list")
    public String getScheduleJobList(HttpServletRequest request){
        Map<String,AbstractScheduleFactoryBean> scheduleJobs = context.getBeansOfType(AbstractScheduleFactoryBean.class);
        request.setAttribute("jobs",scheduleJobs);
        return "jobs";
    }
}
