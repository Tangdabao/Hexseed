/**
 * *****************************************************************************
 *
 * @file AddressListRecyclerAdapter.java
 * @author BLE Mesh Team
 * @version V1.05.000
 * @date 10-April-2018
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
 * BlueNRG-Mesh is based on Motorola&rsquo;s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 * <p>
 * *****************************************************************************
 */
package com.st.bluenrgmesh.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.models.DataGroupProvisioned;
import com.st.bluenrgmesh.models.DataNodeProvisioned;
import com.st.bluenrgmesh.models.ProvisionedDataList;
import com.st.bluenrgmesh.Utils;
import com.msi.moble.mobleAddress;

import java.util.ArrayList;

public class AddressListRecyclerAdapter extends RecyclerView.Adapter<AddressListRecyclerAdapter.ViewHolder> {


    private ProvisionedDataList provisionedList;
    private ArrayList<DataGroupProvisioned> mDataGroupProvisioned;
    private ArrayList<DataNodeProvisioned> mDataNodeProvisioned;
    private ArrayList<DataNodeProvisioned> mDataNodeProvisionedLocal = new ArrayList<>();
    private ArrayList<DataGroupProvisioned> mDataGroupProvisionedLocal = new ArrayList<>();
    private Context context;
    private ArrayList<DataGroupProvisioned> listData;
    private IRecyclerViewHolderClicks listener;
    private String type;
    private static boolean checkFlag;

    /**
     * Instantiates a new Address list recycler adapter.
     *
     * @param context                   the context
     * @param type                      the type
     * @param provisionedList           the provisioned list
     * @param listData                  the list data
     * @param iRecyclerViewHolderClicks the recycler view holder clicks
     */
    public AddressListRecyclerAdapter(Context context, String type, ProvisionedDataList provisionedList, ArrayList<DataGroupProvisioned> listData, IRecyclerViewHolderClicks iRecyclerViewHolderClicks) {

        this.context = context;
        this.listData = listData;
        this.listener = iRecyclerViewHolderClicks;
        this.type = type;
        this.provisionedList = provisionedList;

        mDataGroupProvisioned = provisionedList.getmDataGroupProvisioned();
        mDataNodeProvisioned = provisionedList.getmDataNodeProvisioned();



    }

    /**
     * The interface Recycler view holder clicks.
     */
    public static interface IRecyclerViewHolderClicks {
        /**
         * On click recycler item.
         *
         * @param v           the v
         * @param position    the position
         * @param item        the item
         * @param strSelected the str selected
         */
        public void onClickRecyclerItem(View v, int position, DataGroupProvisioned item, String strSelected);
    }



    @Override
    public AddressListRecyclerAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.address_list_row, parent, false);

        ViewHolder vh = new ViewHolder(v);

        return vh;
    }

    @Override
    public void onBindViewHolder(final AddressListRecyclerAdapter.ViewHolder holder, final int position) {

        holder.switchBut.setTag(position);

        holder.txtRow.setText(type.equals("Subscription") ? listData.get(position).getM_address().toString() + " : " + listData.get(position).getTitle().toString()
                : listData.get(position).getM_address().toString() + " : " + listData.get(position).getTitle());

        if(type.equals("Publication"))
        {
            if(listData.get(position).isSelected())
            {
                holder.switchBut.setChecked(true);
                listData.get(position).setSelected(true);

            }else {
                holder.switchBut.setChecked(false);
                listData.get(position).setSelected(false);
            }


            try {
                mobleAddress a = (mobleAddress) listData.get(position).getM_address();

                mDataNodeProvisionedLocal.clear();
                for (int i = 0; i < mDataNodeProvisioned.size(); i++) {
                    boolean isDeviceInGroup = Utils.searchDevice((MainActivity) context, a, mDataNodeProvisioned.get(i).getAddress());
                    if (isDeviceInGroup) {
                        mDataNodeProvisionedLocal.add(mDataNodeProvisioned.get(i));
                    }
                }
                holder.lytParentList.setVisibility(View.VISIBLE);
                Utils.childRowCreater(context, holder.lytParentList, mDataNodeProvisionedLocal);
            }catch (Exception e){holder.lytParentList.setVisibility(View.GONE);}
        }
        else
        {

            if(listData.get(position).isSelected())
            {
                holder.switchBut.setChecked(true);
                listData.get(position).setSelected(true);

            }else {
                holder.switchBut.setChecked(false);
                listData.get(position).setSelected(false);
            }
            holder.lytParentList.setVisibility(View.GONE);
        }

        holder.switchBut.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {


                return event.getActionMasked() == event.ACTION_MOVE;
            }
        });

        holder.switchBut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                if (holder.switchBut.isChecked()) {

                    if (type.equals("Publication")) {

                        listener.onClickRecyclerItem(holder.switchBut, position, listData.get(position), "Publication");

                    } else {

                        listener.onClickRecyclerItem( holder.switchBut, position, listData.get(position), "Subscription");
                    }
                } else {

                    if (type.equals("Publication")) {
                    } else {


                    }

                }
            }
        });


        holder.switchBut.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {


                if(checkFlag) {


                }


            }

        });

    }




    @Override
    public int getItemCount() {


        return listData.size();


    }

    /**
     * The type View holder.
     */
    public class ViewHolder extends RecyclerView.ViewHolder {
        private final LinearLayout lytParentList;
        private Switch switchBut;
        private TextView txtRow;

        /**
         * Instantiates a new View holder.
         *
         * @param itemView the item view
         */
        public ViewHolder(View itemView) {
            super(itemView);

            this.lytParentList = (LinearLayout) itemView.findViewById(R.id.lytParentList);
            this.txtRow = (TextView) itemView.findViewById(R.id.txtRow);
            this.switchBut = (Switch)itemView.findViewById(R.id.switchBut);
        }
    }


}
