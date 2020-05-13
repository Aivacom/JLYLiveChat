package com.mediaroom.utils;

import android.support.v4.app.Fragment;

public abstract class BaseFragment extends Fragment {

    private LoadingDialog dialog;

    protected void showDialogProgress() {
        LoadingDialog.Builder builder = new LoadingDialog.Builder(getActivity())
                .setCancelable(true);
        dialog = builder.create();
        dialog.show();
    }

    protected void dissMissDialogProgress() {
        if (dialog != null) {
            dialog.dismiss();
        }
    }

}
