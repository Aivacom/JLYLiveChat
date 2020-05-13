package com.mediaroom.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;

public class PermissionUtils {
    public static final int REQUEST_CODE_PERMISSIONS=2;

    public static String[] permissions = new String[]{Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE};
    /**
     * 检测权限
     * check Permission
     *
     * @return true：已授权； false：未授权；
     */
    public static boolean checkPermission(Context context, String permission) {
        if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED)
            return true;
        else
            return false;
    }

    /**
     * 检测多个权限
     * check more Permissions
     *
     * @return 未授权的权限
     */
    public static List<String> checkMorePermissions(Context context, String[] permissions) {
        List<String> permissionList = new ArrayList<>();
        for (int i = 0; i < permissions.length; i++) {
            if (!checkPermission(context, permissions[i]))
                permissionList.add(permissions[i]);
        }
        return permissionList;
    }

    /**
     * 请求权限
     * request Permission
     */
    public static void requestPermission(Context context, String permission, int requestCode) {
        ActivityCompat.requestPermissions((Activity) context, new String[]{permission}, requestCode);
    }

    /**
     * 请求多个权限
     * request more Permissions
     */
    public static void requestMorePermissions(Context context, List permissionList, int requestCode) {
        String[] permissions = (String[]) permissionList.toArray(new String[permissionList.size()]);
        requestMorePermissions(context, permissions, requestCode);
    }

    /**
     * 请求多个权限
     * request more Permissions
     */
    public static void requestMorePermissions(Context context, String[] permissions, int requestCode) {
        ActivityCompat.requestPermissions((Activity) context, permissions, requestCode);
    }

    /**
     * 判断是否已拒绝过权限
     * Determine whether permission has been denied
     *
     * @return
     * @describe :如果应用之前请求过此权限但用户拒绝，此方法将返回 true;
     * -----------如果应用第一次请求权限或 用户在过去拒绝了权限请求，
     * -----------并在权限请求系统对话框中选择了 Don't ask again 选项，此方法将返回 false。
     * This method returns true if the application previously requested this permission but the
     * user rejected it.If the application first requests permission or the user has rejected
     * permission requests in the past,Select the Don't ask again option in the permission request
     * system dialog box, and this method returns false.
     *
     */
    public static boolean judgePermission(Context context, String permission) {
        if (ActivityCompat.shouldShowRequestPermissionRationale((Activity) context, permission))
            return true;
        else
            return false;
    }

    /**
     * 检测权限并请求权限：如果没有权限，则请求权限
     * Detect permissions and request permissions: if there are no permissions, request permissions
     */
    public static void checkAndRequestPermission(Context context, String permission, int requestCode) {
        if (!checkPermission(context, permission)) {
            requestPermission(context, permission, requestCode);
        }
    }

    /**
     * 检测并请求多个权限
     * Detects and requests multiple permissions
     */
    public static void checkAndRequestMorePermissions(Context context, String[] permissions, int requestCode) {
        List<String> permissionList = checkMorePermissions(context, permissions);
        requestMorePermissions(context, permissionList, requestCode);
    }


    /**
     * 检测权限
     * check one Permission
     *
     * @describe：具体实现由回调接口决定
     */
    public static void checkPermission(Context context, String permission, PermissionCheckCallBack callBack) {
        if (checkPermission(context, permission)) { // 用户已授予权限
            callBack.onHasPermission();
        } else {
            if (judgePermission(context, permission))  // 用户之前已拒绝过权限申请
                callBack.onUserHasAlreadyTurnedDown(permission);
            else                                       // 用户之前已拒绝并勾选了不在询问、用户第一次申请权限。
                callBack.onUserHasAlreadyTurnedDownAndDontAsk(permission);
        }
    }

    /**
     * 检测多个权限
     * check more Permissions
     *
     * @describe：具体实现由回调接口决定
     */
    public static void checkMorePermissions(Context context, String[] permissions, PermissionCheckCallBack callBack) {
        List<String> permissionList = checkMorePermissions(context, permissions);
        if (permissionList.size() == 0) {  // 用户已授予权限
            callBack.onHasPermission();
        } else {
            boolean isFirst = true;
            for (int i = 0; i < permissionList.size(); i++) {
                String permission = permissionList.get(i);
                if (judgePermission(context, permission)) {
                    isFirst = false;
                    break;
                }
            }
            String[] unauthorizedMorePermissions = (String[]) permissionList.toArray(new String[permissionList.size()]);
            if (isFirst)// 用户之前已拒绝过权限申请
                callBack.onUserHasAlreadyTurnedDownAndDontAsk(unauthorizedMorePermissions);
            else       // 用户之前已拒绝并勾选了不在询问、用户第一次申请权限。
                callBack.onUserHasAlreadyTurnedDown(unauthorizedMorePermissions);

        }
    }


    /**
     * 检测并申请权限
     * check and request Permission
     */
    public static void checkAndRequestPermission(Context context, String permission, int requestCode, PermissionRequestSuccessCallBack callBack) {
        if (checkPermission(context, permission)) {// 用户已授予权限
            callBack.onHasPermission();
        } else {
            requestPermission(context, permission, requestCode);
        }
    }

    /**
     * 检测并申请多个权限
     * check and request more Permissions
     */
    public static void checkAndRequestMorePermissions(Context context, String[] permissions, int requestCode, PermissionRequestSuccessCallBack callBack) {
        List<String> permissionList = checkMorePermissions(context, permissions);
        if (permissionList.size() == 0) {  // 用户已授予权限
            callBack.onHasPermission();
        } else {
            requestMorePermissions(context, permissionList, requestCode);
        }
    }

    /**
     * 判断权限是否申请成功
     * the permission is request success
     */
    public static boolean isPermissionRequestSuccess(int[] grantResults) {
        if (grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED)
            return true;
        else
            return false;
    }

    /**
     * 用户申请权限返回
     * result of request permission
     */
    public static void onRequestPermissionResult(Context context, String permission, int[] grantResults, PermissionCheckCallBack callback) {
        if (PermissionUtils.isPermissionRequestSuccess(grantResults)) {
            callback.onHasPermission();
        } else {
            if (PermissionUtils.judgePermission(context, permission)) {
                callback.onUserHasAlreadyTurnedDown(permission);
            } else {
                callback.onUserHasAlreadyTurnedDownAndDontAsk(permission);
            }
        }
    }

    /**
     * 用户申请多个权限返回
     * result of request multy permission
     */
    public static void onRequestMorePermissionsResult(Context context, String[] permissions, PermissionCheckCallBack callback) {
        boolean isBannedPermission = false;
        List<String> permissionList = checkMorePermissions(context, permissions);
        if (permissionList.size() == 0)
            callback.onHasPermission();
        else {
            for (int i = 0; i < permissionList.size(); i++) {
                if (!judgePermission(context, permissionList.get(i))) {
                    isBannedPermission = true;
                    break;
                }
            }
            //　已禁止再次询问权限
            if (isBannedPermission)
                callback.onUserHasAlreadyTurnedDownAndDontAsk(permissions);
            else // 拒绝权限
                callback.onUserHasAlreadyTurnedDown(permissions);
        }

    }


    /**
     * 跳转到权限设置界面
     * go to setting
     */
    public static void toAppSetting(Context context) {
        Intent intent = new Intent();
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (Build.VERSION.SDK_INT >= 9) {
            intent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
            intent.setData(Uri.fromParts("package", context.getPackageName(), null));
        } else if (Build.VERSION.SDK_INT <= 8) {
            intent.setAction(Intent.ACTION_VIEW);
            intent.setClassName("com.android.settings", "com.android.settings.InstalledAppDetails");
            intent.putExtra("com.android.settings.ApplicationPkgName", context.getPackageName());
        }
        context.startActivity(intent);
    }

    public interface PermissionRequestSuccessCallBack {
        /**
         * 用户已授予权限
         * The user has been granted permissions
         */
        void onHasPermission();
    }


    public interface PermissionCheckCallBack {

        /**
         * 用户已授予权限
         * The user has been granted permissions
         */
        void onHasPermission();

        /**
         * 用户已拒绝过权限
         * The user has denied permission
         *
         * @param permission:被拒绝的权限 denied permission
         */
        void onUserHasAlreadyTurnedDown(String... permission);

        /**
         * 用户已拒绝过并且已勾选不再询问选项、用户第一次申请权限;
         * The user has rejected and checked the no longer ask option, and the user applied for permission for the first time;
         *
         * @param permission:被拒绝的权限 denied permission
         */
        void onUserHasAlreadyTurnedDownAndDontAsk(String... permission);
    }


}