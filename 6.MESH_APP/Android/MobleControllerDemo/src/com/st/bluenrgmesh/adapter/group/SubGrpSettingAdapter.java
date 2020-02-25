package com.st.bluenrgmesh.adapter.group;

import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.TextView;

import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.adapter.SubListForGroupAdapter;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Nodes;

import java.util.ArrayList;

/**
 * Created by sharma01 on 10/17/2018.
 */

public class SubGrpSettingAdapter extends RecyclerView.Adapter<SubGrpSettingAdapter.ViewHolder> {

    private final Context context;
    private final ArrayList<Element> eleSubList;
    private final String group_addr;
    private final SubGrpSettingAdapter.IRecyclerViewHolderClicks listener;
    private final MeshRootClass meshRootClass;
    private final boolean isAddGroup;


    public SubGrpSettingAdapter(Context context, ArrayList<Element> eleSelected, String group_addr, MeshRootClass meshRootClass, boolean isAddGroup,  IRecyclerViewHolderClicks iRecyclerViewHolderClicks) {

        this.context = context;
        this.eleSubList = eleSelected;
        this.group_addr = group_addr;
        this.isAddGroup = isAddGroup;
        this.listener = iRecyclerViewHolderClicks;
        this.meshRootClass = meshRootClass;
    }


    public static interface IRecyclerViewHolderClicks {
        public void onClickRecyclerItem(View v, int position, Element element, String address, boolean b);
        public void onClickNodeRecyclerItem(View v, int position, Nodes node, String address, boolean b);
    }


    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.subscription_list_row, parent, false);
        SubGrpSettingAdapter.ViewHolder vh = new SubGrpSettingAdapter.ViewHolder(v);
        return vh;
    }



    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {


        holder.txtView.setVisibility(View.GONE);
        if (("c000".equalsIgnoreCase(group_addr))) {
            holder.radioButton.setChecked(true);
        } else {
            if(!isAddGroup)
            {
                holder.radioButton.setChecked(eleSubList.get(position).isChecked() ? true : false);
            }
            else
            {
                holder.radioButton.setChecked(eleSubList.get(position).isChecked() ? true : false);
            }
        }

        holder.radioButton.setText(eleSubList.get(position).getParentNodeName() + "/" + eleSubList.get(position).getName());
        holder.radioButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!"c000".equalsIgnoreCase(group_addr)) {
                    listener.onClickRecyclerItem(v, position, eleSubList.get(position), eleSubList.get(position).getUnicastAddress(), true);
                }
            }
        });
    }



    @Override
    public int getItemCount() {
        return eleSubList.size();
    }



    public class ViewHolder extends RecyclerView.ViewHolder {
        private final RadioButton radioButton;
        private final TextView txtView;

        public ViewHolder(View itemView) {
            super(itemView);

            radioButton = (RadioButton) itemView.findViewById(R.id.radioButton);
            txtView = (TextView) itemView.findViewById(R.id.txtView);

        }
    }
}
