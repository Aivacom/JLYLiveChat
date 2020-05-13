package com.mediaroom.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.mediaroom.MyApplication;

import java.util.Timer;
import java.util.TimerTask;


/**
 * @author zhaochong
 * @desc TODO
 * @date on 2019-09-04
 * @email zoro.zhaochong@gmail.com
 */
public abstract class BaseActivity extends AppCompatActivity {

    protected final String TAG = getClass().getSimpleName();

    private LoadingDialog dialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        Log.i(TAG, "======================= onCreate ========================");
        if (MyApplication.getInstance().getAppStatus() != Constant.STATUS_NORMAL) {
            restartApp();
            return;
        }
        setStatusBar();
        setContentView(getLayoutResId());
        initView();
        initData();
    }

    protected abstract int getLayoutResId();

    protected abstract void initView();

    protected abstract void initData();


    public Context getContext() {
        return this;
    }

    private void setStatusBar() {
        //状态栏透明化: 侵入式透明status bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Window window = getWindow();
            // Translucent status bar
            window.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, WindowManager
                    .LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    public void showDialogProgress() {
        LoadingDialog.Builder builder = new LoadingDialog.Builder(this)
                .setCancelable(false);
        dialog = builder.create();
        dialog.show();
    }

    public void dissMissDialogProgress() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    //设置返回按钮：不应该退出程序---而是返回桌面
    //复写onKeyDown事件
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Intent home = new Intent(Intent.ACTION_MAIN);
            home.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            home.addCategory(Intent.CATEGORY_HOME);
            startActivity(home);
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_UP:
                View view = getCurrentFocus();
                hideKeyboard(ev, view, BaseActivity.this);//调用方法判断是否需要隐藏键盘
                break;
            default:
                break;
        }
        return super.dispatchTouchEvent(ev);
    }

    public void hideKeyboard(MotionEvent event, View view,
                             Activity activity) {
        try {
            if (view != null && view instanceof EditText) {
                int[] location = {0, 0};
                view.getLocationInWindow(location);
                int left = location[0], top = location[1], right = left
                        + view.getWidth(), bottom = top + view.getHeight();
                // 判断焦点位置坐标是否在空间内，如果位置在控件外，则隐藏键盘
//                if (event.getRawX() < left || event.getRawX() > right
//                        || event.getY() < top || event.getRawY() > bootom) {
                if (event.getY() < top || event.getRawY() > bottom) {//左右不隐藏键盘
                    // 隐藏键盘
                    IBinder token = view.getWindowToken();
                    InputMethodManager inputMethodManager = (InputMethodManager) activity
                            .getSystemService(Context.INPUT_METHOD_SERVICE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                        inputMethodManager.hideSoftInputFromWindow(token,
                                InputMethodManager.HIDE_NOT_ALWAYS);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * 弹起软键盘
     *
     * @param editText
     */
    public void openKeyBoard(EditText editText) {
        editText.setVisibility(View.VISIBLE);
        editText.setFocusable(true);
        editText.setFocusableInTouchMode(true);
        editText.requestFocus();
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                InputMethodManager imm =
                        (InputMethodManager)
                                MyApplication.getInstance()
                                        .getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.showSoftInput(editText, 0);
                editText.setSelection(editText.getText().length());
            }
        }, 200);
    }

    protected void restartApp() {
        Intent LaunchIntent = getPackageManager().getLaunchIntentForPackage(getApplication().getPackageName());
        LaunchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(LaunchIntent);
    }

//    @Override
//    protected void onStart() {
//        super.onStart();
//        Log.i(TAG, "======================= onStart ========================");
//    }
//
//    @Override
//    protected void onResume() {
//        super.onResume();
//        Log.i(TAG, "======================= onResume ========================");
//    }
//
//    @Override
//    protected void onRestart() {
//        super.onRestart();
//        Log.i(TAG, "======================= onRestart ========================");
//    }
//
//    @Override
//    protected void onPause() {
//        super.onPause();
//        Log.i(TAG, "======================= onPause ========================");
//    }
//
//    @Override
//    protected void onStop() {
//        super.onStop();
//        Log.i(TAG, "======================= onStop ========================");
//    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "======================= onDestroy ========================");
    }
}

