package com.mediaroom.utils;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;

import com.mediaroom.R;


public abstract class BaseDialog extends Dialog {
    protected View view = null;

    public BaseDialog(Context context) {
        this(context, R.style.dialog_center);
    }


    public BaseDialog(Context context, int themeResId) {
        super(context, themeResId);
        view = getLayoutInflater().inflate(getLayout(), null);
        setContentView(view);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setGravity(getGravity());
        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
        WindowManager.LayoutParams p = getWindow().getAttributes();
        p.width = (int) (dm.widthPixels * getWidth());
        setCanceledOnTouchOutside(false);
    }

    /**
     * 得到对应的布局
     *
     * @return
     */
    protected abstract int getLayout();

    /**
     * 设置dialog的宽度， 默认是屏幕的 3/4
     *
     * @return
     */
    protected double getWidth() {
        return 3.0 / 4;
    }

    /**
     * 设置dialog的弹出位置，默认是在中间
     */
    protected int getGravity() {
        return Gravity.CENTER;
    }

    interface InitDialogListener{
        void initDialogEvent(View view);
    }
}
