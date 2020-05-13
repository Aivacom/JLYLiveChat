package com.mediaroom.ui;


import android.support.v7.widget.Toolbar;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.mediaroom.BuildConfig;
import com.mediaroom.R;
import com.mediaroom.facade.FeedBackManager;
import com.mediaroom.utils.BaseActivity;

import org.jetbrains.annotations.NotNull;

import tv.athena.feedback.api.FeedbackData;


public class FeedBackActivity extends BaseActivity {

    TextView mVersionText, mToolbarTitle;
    EditText mFeedbackEdit;
    Button mFeedbackBtn;


    @Override
    protected int getLayoutResId() {
        return R.layout.activity_feedback;
    }

    @Override
    protected void initView() {
        mFeedbackBtn = findViewById(R.id.iv_feedback);
        mVersionText = findViewById(R.id.tv_app_version);
        mFeedbackEdit = findViewById(R.id.et_feedback_content);
        Toolbar toolbar = findViewById(R.id.toolbar);
        mToolbarTitle = findViewById(R.id.toolbar_title);
        toolbar.setTitle("");
        mToolbarTitle.setText(R.string.upload_log_tittle);
        toolbar.setNavigationOnClickListener(v -> FeedBackActivity.this.finish());
        mFeedbackBtn.setOnClickListener(view -> {

            FeedBackManager.getInstance().feedBackLog(mFeedbackEdit.getText().toString(), new FeedbackData.FeedbackStatusListener() {
                @Override
                public void onFailure(@NotNull FailReason failReason) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            dissMissDialogProgress();
                            Toast.makeText(FeedBackActivity.this, "反馈失败", Toast.LENGTH_SHORT).show();
                        }
                    });
                }

                @Override
                public void onComplete() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            dissMissDialogProgress();
                            Toast.makeText(FeedBackActivity.this, "反馈成功", Toast.LENGTH_SHORT).show();
                        }
                    });
                }

                @Override
                public void onProgressChange(int i) {
                    dissMissDialogProgress();
                }
            });
            finish();
        });
        mVersionText.setText(FeedBackActivity.this.getString(R.string.app_version, BuildConfig.VERSION_NAME + "-livechat-" + BuildConfig.VERSION_CODE));
    }

    @Override
    protected void initData() {

    }
}
