package com.mediaroom.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.util.TypedValue;

import com.alibaba.fastjson.JSON;
import com.mediaroom.MyApplication;
import com.mediaroom.bean.RepToken;

import org.json.JSONObject;

import java.io.IOException;

import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class Utils {
    private static final String TAG = Utils.class.getSimpleName();


    public static byte[] getToken(final String uid, String appId, Callback call) {
        byte[] token = null;
        try {
            JSONObject request = new JSONObject();
            request.put("uid", uid);
            request.put("validTime", 30000000);
            request.put("appId", appId);
            if (call != null) {
                Utils.post("https://webapi.sunclouds.com/webservice/app/v2/auth/genToken", request.toString(), call);
            } else {
                String respString = Utils.post("https://webapi.sunclouds.com/webservice/app/v2/auth/genToken", request.toString(), null);
                RepToken repToken = JSON.parseObject(respString, RepToken.class);
                if (repToken.getObject() != null) {
                    token = repToken.getObject().getBytes();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return token;
    }

    @SuppressWarnings({"SameParameterValue", "ConstantConditions"})
    private static String post(String url, String json, Callback call) {
        String rep = null;
        OkHttpClient client = new OkHttpClient();
        RequestBody body = RequestBody.create(MediaType.get("application/json;charset=utf-8"), json);
        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();
        if (call != null) {
            client.newCall(request).enqueue(call);
        } else {
            try (Response response = client.newCall(request).execute()) {
                rep = response.body().string();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return rep;
    }

    public static void setUid(Context context, String uid) {
        SpUtil.putString(context, Constant.SP_UID, uid);
    }

    public static String getUid(Context context) {
        return SpUtil.getString(context, Constant.SP_UID);
    }

    public static void setIsLogin(Context context, boolean islogin) {
        SpUtil.putBoolean(context, Constant.SP_ISLOGIN, islogin);
    }

    public static boolean getIsLogin(Context context) {
        return SpUtil.getBoolean(context, Constant.SP_ISLOGIN, false);
    }

    /**
     * 获取当前进程名
     */
    private static String getCurrentProcessName() {
        int pid = android.os.Process.myPid();
        String processName = "";
        ActivityManager manager = (ActivityManager) MyApplication.getInstance().getApplicationContext().getSystemService
                (Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo process : manager.getRunningAppProcesses()) {
            if (process.pid == pid) {
                processName = process.processName;
            }
        }
        return processName;
    }

    public static boolean isMainProcess() {
        return MyApplication.getInstance().getPackageName().equals(getCurrentProcessName());
    }

    /**
     * dp转px
     * @param dpVal
     * @return
     */
    public static int dp2px(float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, MyApplication.getInstance().getResources().getDisplayMetrics());
    }
}
