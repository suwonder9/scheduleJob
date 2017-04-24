package wonder.scheduleJob;


import org.springframework.util.ClassUtils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * 调度任务实现类
 */
public class ExecutionJobImpl implements ExecutionJob {

    private Object target;

    private final Method method;

    public ExecutionJobImpl(Object target, String methodName) {
        this.target = target;
        this.method = getMethod(target, methodName);
    }

    /**
     * 开始执行Job方法
     * 调用具体的任务的方法
     *
     * @throws InvocationTargetException
     */
    @Override
    public void execute() throws InvocationTargetException {
        try {
            method.invoke(target);
        } catch (Exception e) {
            throw new InvocationTargetException(e);
        }
    }

    public Object getTarget() {
        return target;
    }

    public void setTarget(Object target) {
        this.target = target;
    }

    public Method getMethod(Object obj, String methodName) {
        return ClassUtils.getMethod(obj.getClass(), methodName);
    }
}
