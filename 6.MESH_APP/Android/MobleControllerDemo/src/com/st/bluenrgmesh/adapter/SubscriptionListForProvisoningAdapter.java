/**
 * *****************************************************************************
 *
 * @file SubscriptionListForProvisoningAdapter.java
 * @author BLE Mesh Team
 * @version V1.07.000
 * @date 10-July-2018
 * @brief User Application file
 * *****************************************************************************
 * @attention <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
 * <p>
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of STMicroelectronics nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * <p>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p>
 * BlueNRG-Mesh is based on Motorola’s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 * <p>
 * *****************************************************************************
 */

package com.st.bluenrgmesh.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.RadioButton;
import android.widget.TextView;

import com.msi.moble.mobleAddress;
import com.st.bluenrgmesh.GroupEntry;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.Group;
import com.st.bluenrgmesh.models.meshdata.Nodes;

import java.util.ArrayList;



public class SubscriptionListForProvisoningAdapter extends RecyclerView.Adapter<SubscriptionListForProvisoningAdapter.ViewHolder> {


    private final ArrayList<Group> nodeSubscriptionList;
    private Context context;
    private SubscriptionListForProvisoningAdapter.IRecyclerViewHolderClicks listener;

    public interface IRecyclerViewHolderClicks {

         void notifyAdapter(int position);

    }

    public SubscriptionListForProvisoningAdapter(Context context, ArrayList<Group> nodeSubscriptionList, SubscriptionListForProvisoningAdapter.IRecyclerViewHolderClicks iRecyclerViewHolderClicks) {

        this.context = context;
        this.nodeSubscriptionList = nodeSubscriptionList;
        this.listener = iRecyclerViewHolderClicks;

    }

    @Override
    public SubscriptionListForProvisoningAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.subscription_list_row, parent, false);

        SubscriptionListForProvisoningAdapter.ViewHolder vh = new SubscriptionListForProvisoningAdapter.ViewHolder(v);
        Log.e("value","onncreateholder");
        return vh;
    }

    @Override
    public void onBindViewHolder(SubscriptionListForProvisoningAdapter.ViewHolder holder, final int position) {
        Log.e("value","onbindhder");

        if (nodeSubscriptionList != null) {
            if (nodeSubscriptionList.size() == 0) {
                holder.txtView.setText(context.getString(R.string.str_default_group_label));
                holder.radioButton.setChecked(true);
                Utils.setsubscriptiongroupAddressOnProvsioning(context, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP).toString());
            } else {

                holder.txtView.setText(nodeSubscriptionList.get(position).getName());

                if(nodeSubscriptionList.get(position).getAddress().equalsIgnoreCase(Utils.getsubscriptiongroupAddressOnProvsioning(context))){
                    holder.radioButton.setChecked(true);
                }else {

                    if ("".equalsIgnoreCase(Utils.getsubscriptiongroupAddressOnProvsioning(context))) {
                        if (nodeSubscriptionList.get(position).getName().equalsIgnoreCase(context.getString(R.string.str_default_group_label))) {
                            holder.radioButton.setChecked(true);
                            Utils.setsubscriptiongroupAddressOnProvsioning(context, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP).toString());

                        } else {
                            holder.radioButton.setChecked(false);
                        }
                    } else {
                        holder.radioButton.setChecked(false);
                    }
                }

            }
        }


        holder.radioButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(buttonView.isChecked()){
                    if(nodeSubscriptionList!=null &&nodeSubscriptionList.size()>0) {
                        Utils.setsubscriptiongroupAddressOnProvsioning(context, nodeSubscriptionList.get(position).getAddress());
                       // notifyDataSetChanged();
                        listener.notifyAdapter(position);
                    }
                }
            }
        });

    }

    @Override
    public int getItemCount() {
        if (nodeSubscriptionList != null ) {
            if (nodeSubscriptionList.size() == 0) {
                return 1;
            } else {
                return nodeSubscriptionList.size();
            }
        }
        return 0;
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