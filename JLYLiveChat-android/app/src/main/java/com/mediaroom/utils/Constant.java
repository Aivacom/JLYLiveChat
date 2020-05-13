package com.mediaroom.utils;


import android.os.Environment;

import com.mediaroom.R;

import java.io.File;

public class Constant {
    public static final int STATUS_FORCE_KILLED = -1;//应用在后台被强杀
    public static final int STATUS_NORMAL = 2; //APP正常态

    public static final String TAG = "mediaroom";
    public static long mAppId = 1470236061;
    public static String uid;

    public static final String FEEDBACK_CRASHLOGID = "SCloudLiveChat-android";

    public static long mSceneId = 0;
    public static String logFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + R.string.app_name + File.separator + "logs/";

    public static final int CHAT_GROUPID = 888;
    public static final String ROOMID_KEY = "roomid";
    public static final String ROOMOWNERID_KEY = "roomowner";
    public static final String ROOMISLIVE_KEY = "roomlive";
    public static final String ROOMISSUBCRIBE_KEY = "roomsubcribe";
    public static final String ROOMISSUBCRIBE_MREMOTEUID_KEY = "roomsubcribemremoteuid";

    public static byte[] token;

    //平台化定义相同的语义
    public static final String LIVE_CONNECT_APPLY = "live_connect_apply";
    public static final String LIVE_CONNECT_ACCEPT = "live_connect_accept";
    public static final String LIVE_CONNECT_REFUSE = "live_connect_refuse";
    public static final String LIVE_CONNECT_CANCEL = "live_connect_cancel";

    public static final String LIVE_MODETYPE = "live_modetype";
    public static final String MEMBERS_MODETYPE = "members_modetype";

    public static final String SP_UID = "sp_uid";
    public static final String SP_ISLOGIN = "sp_islogin";
}
