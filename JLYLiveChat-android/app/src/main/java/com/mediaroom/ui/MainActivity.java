package com.mediaroom.ui;


import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.text.TextUtils;

import com.mediaroom.R;
import com.mediaroom.facade.HummerManager;
import com.mediaroom.utils.BaseActivity;
import com.mediaroom.utils.ConfirmDialog;
import com.mediaroom.utils.Constant;
import com.mediaroom.utils.LogUtil;
import com.mediaroom.utils.PermissionUtils;
import com.mediaroom.utils.Utils;

public class MainActivity extends BaseActivity {
    DealRoomFragment dealRoomFragment;
    LoginFragment loginFragment;

    public static final int SHOW_LOGINFRAGMENT = 0;
    public static final int SHOW_DEALROOMFRAGMENT = 1;
    private ConfirmDialog confirmDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        if (savedInstanceState != null) {
            FragmentManager fragmentManager = getSupportFragmentManager();
            dealRoomFragment = (DealRoomFragment) fragmentManager.findFragmentByTag(DealRoomFragment.class.getSimpleName());
            loginFragment = (LoginFragment) fragmentManager.findFragmentByTag(DealRoomFragment.class.getSimpleName());
        }
        super.onCreate(savedInstanceState);
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }


    @Override
    protected void initData() {
//        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
//            finish();
//            return;
//        }
        PermissionUtils.checkAndRequestMorePermissions(MainActivity.this, PermissionUtils.permissions, PermissionUtils.REQUEST_CODE_PERMISSIONS,
                () -> LogUtil.v(Constant.TAG, "已授予权限"));
    }

    @Override
    protected void initView() {
        initFragment();
    }

    private void initFragment() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        if (dealRoomFragment == null) {
            dealRoomFragment = DealRoomFragment.newInstance();
            FragmentTransaction ft = fragmentManager.beginTransaction();
            ft.add(R.id.content, dealRoomFragment, DealRoomFragment.class.getSimpleName()).commit();
        }

        if (loginFragment == null) {
            loginFragment = LoginFragment.newInstance();
            FragmentTransaction ft2 = fragmentManager.beginTransaction();
            ft2.add(R.id.content, loginFragment, LoginFragment.class.getSimpleName()).commit();
        }

        Constant.uid = Utils.getUid(MainActivity.this);
        if (!TextUtils.isEmpty(Constant.uid) && Utils.getIsLogin(MainActivity.this)) {
            showFragment(SHOW_DEALROOMFRAGMENT);
        } else {
            showFragment(SHOW_LOGINFRAGMENT);
        }
    }

    public void showFragment(int position) {
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.hide(loginFragment);
        ft.hide(dealRoomFragment);
        if (position == SHOW_LOGINFRAGMENT) {
            ft.show(loginFragment).commitNow();
        } else {
            ft.show(dealRoomFragment).commitNow();
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        if (HummerManager.isForceOut) {
            showQuitConfirm(R.string.mult_joinchatroom);
            return;
        }
        if (!HummerManager.isOwner && HummerManager.closeChatRoom) {
            showQuitConfirm(R.string.close_room);
            return;
        }
        if (!HummerManager.isOwner && HummerManager.isKick) {
            showQuitConfirm(R.string.kicked_room);
            return;
        }
    }


    private void showQuitConfirm(int id) {
        if (confirmDialog != null && confirmDialog.isShowing()) {
            return;
        }
        confirmDialog = new ConfirmDialog(this, new ConfirmDialog.OnConfirmCallback() {
            @Override
            public void onSure() {
                HummerManager.isForceOut = false;
                HummerManager.isOwner = false;
                HummerManager.closeChatRoom = false;
                HummerManager.isKick = false;
                confirmDialog.dismiss();
            }

            @Override
            public void onCancel() {
            }
        });
        confirmDialog.setTitle("提示");
        confirmDialog.setDesc(getResources().getString(id));
        confirmDialog.setButton("知道了");
        confirmDialog.show();
    }
}
