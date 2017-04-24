package wonder.scheduleJob;

import java.lang.reflect.InvocationTargetException;

/**
 * Created by sujinxian on 2017/4/12.
 */
public interface ExecutionJob {

    /**
     * job method
     *
     * @throws InvocationTargetException
     */
    public void execute() throws InvocationTargetException;
}
