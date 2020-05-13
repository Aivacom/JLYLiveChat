package com.mediaroom.utils;

import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

public abstract class BaseAdapter<T> extends RecyclerView.Adapter<BaseAdapter.VH> {
    protected List<T> mDatas;
    protected OnItemClickListener onItemClickListener;
    protected OnItemChildClickListener onItemChildClickListener;

    public BaseAdapter(List<T> datas) {
        this.mDatas = datas;
    }

    public abstract int getLayoutId(int viewType);


    @Override
    public VH onCreateViewHolder(ViewGroup parent, int viewType) {
        return VH.get(parent, getLayoutId(viewType));
    }

    @Override
    public void onBindViewHolder(VH holder, int position) {
        //③ 对RecyclerView的每一个itemView设置点击事件
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
//                int pos = holder.getLayoutPosition();
                onItemClickListener.onItemClick(holder.itemView, position);
            }
        });
        convert(holder, mDatas.get(position), position);
    }

    @Override
    public int getItemCount() {
        return mDatas.size();
    }

    public abstract void convert(VH holder, T data, int position);

    public void addItemData(int postion, T data) {
        if (mDatas == null) {
            mDatas = new ArrayList<>();
        }
        mDatas.add(postion, data);
        //更新数据集不是用adapter.notifyDataSetChanged()而是notifyItemInserted(position)与notifyItemRemoved(position) 否则没有动画效果。
        notifyItemInserted(postion);
    }

    public void addNewData(T data) {
        if (mDatas == null) {
            mDatas = new ArrayList<>();
        }
        mDatas.add(data);
        //更新数据集不是用adapter.notifyDataSetChanged()而是notifyItemInserted(position)与notifyItemRemoved(position) 否则没有动画效果。
        notifyItemInserted(mDatas.size() - 1);
    }

    public List<T> getData() {
        return mDatas;
    }

    //这里用addAll也很重要，如果用this.list = mList，调用notifyDataSetChanged()无效
    //notifyDataSetChanged()数据源发生改变的时候调用的，this.list = mList，list并没有发生改变
    public void setData(List<T> datas) {
        if (mDatas != null) {
            mDatas.clear();
        }
        this.mDatas = datas;
        notifyDataSetChanged();
    }

    public void resetData(List<T> datas) {
        if (mDatas != null) {
            mDatas.clear();
        }
        mDatas.addAll(datas);
        notifyDataSetChanged();
    }

    public void deleteItem(int posion) {
        if (mDatas == null || mDatas.isEmpty()) {
            return;
        }
        mDatas.remove(posion);
        notifyItemRemoved(posion);
    }

    public void clear() {
        if (mDatas == null || mDatas.isEmpty()) {
            return;
        }
        mDatas.clear();
        notifyDataSetChanged();
    }

    // ① 定义点击回调接口
    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }

    // ② 定义一个设置点击监听器的方法
    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }


    public interface OnItemChildClickListener {
        void onItemChildClick(View view, int position);
    }

    public void setOnItemChildClickListener(OnItemChildClickListener listener) {
        this.onItemChildClickListener = listener;
    }


    public static class VH extends RecyclerView.ViewHolder {
        private SparseArray<View> mViews;
        private View mConvertView;

        private VH(View v) {
            super(v);
            mConvertView = v;
            mViews = new SparseArray<>();
        }

        public static VH get(ViewGroup parent, int layoutId) {
            View convertView = LayoutInflater.from(parent.getContext()).inflate(layoutId, parent, false);
            return new VH(convertView);
        }

        public <T extends View> T getView(int id) {
            View v = mViews.get(id);
            if (v == null) {
                v = mConvertView.findViewById(id);
                mViews.put(id, v);
            }
            return (T) v;
        }

        public void setText(int id, String value) {
            TextView view = getView(id);
            view.setText(value);
        }

        public void setImageDrawable(int id, Drawable drawable) {
            ImageView view = getView(id);
            view.setImageDrawable(drawable);
        }
    }
}