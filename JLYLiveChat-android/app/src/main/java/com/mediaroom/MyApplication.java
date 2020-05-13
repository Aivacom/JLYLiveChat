package com.mediaroom;

import android.app.Application;
import android.support.multidex.MultiDex;

import com.hummer.im.HMR;
import com.mediaroom.facade.FacadeRtcManager;
import com.mediaroom.facade.FeedBackManager;
import com.mediaroom.utils.Constant;
import com.mediaroom.utils.Utils;

public class MyApplication extends Application {
    private static MyApplication instance;

    private int appStatus; //默认为被后台回收了

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        MultiDex.install(this);
        FeedBackManager.getInstance().init(this);
        init(Constant.mAppId);
        initThunderSDk();
        setAppStatus(Constant.STATUS_NORMAL);
//        LogToFile.init(this);
//        CrashHandler crashHandler = CrashHandler.getInstance();
//        crashHandler.init(this);

    }

    public void init(long appId) {
        // 当业务层接管了连接通道时，应使用 ServiceChannel.DelegateMode 模式，例如Hamo等接入了UDB的业务。
        // 当业务希望Hummer自身维护通道，则应使用ServiceChannel.AutonomousMode，实现通道自治性
        // 否则，欢迎与我方洽谈，使用业务通道
        //When the business layer took over the connection channel, should use ServiceChannel.
        // DelegateMode mode, such as Hamo UDB access business.When the business wants its own
        // maintenance channel, should use ServiceChannel. AutonomousMode, achieve channel autonomy,
        // Otherwise, you are welcome to negotiate with us and use the business channel
        if (Utils.isMainProcess()) {
            HMR.init(MyApplication.getInstance(), appId);
        }
    }

    public void initThunderSDk() {
        FacadeRtcManager.getInstance()
                .initializeRtc(MyApplication.getInstance(), String.valueOf(Constant.mAppId), Constant.mSceneId, FacadeRtcManager.getInstance().getThunderEventHandler())
                .setLogFilePath(Constant.logFilePath);
//                .setLogCallback(FacadeRtcManager.getInstance().getThunderLogCallback());
    }

    public static MyApplication getInstance() {
        return instance;
    }

    public int getAppStatus() {
        return appStatus;
    }

    public void setAppStatus(int appStatus) {
        this.appStatus = appStatus;
    }

}
