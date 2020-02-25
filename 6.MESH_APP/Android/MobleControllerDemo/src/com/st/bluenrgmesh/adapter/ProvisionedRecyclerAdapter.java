/**
 * *****************************************************************************
 *
 * @file ProvisionedRecyclerAdapter.java
 * @author BLE Mesh Team
 * @version V1.08.000
 * @date 15-October-2018
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
import android.graphics.Typeface;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.SensorModelClient;
import com.msi.moble.mobleAddress;
import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.callbacks.SensorModelCallbacks;
import com.st.bluenrgmesh.logger.LoggerConstants;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.models.meshdata.settings.NodeSettings;
import com.st.bluenrgmesh.view.fragments.other.meshmodels.heartbeat.HeartBeatInfoFragment;
import com.st.bluenrgmesh.view.fragments.setting.NodeSettingFragment;
import com.st.bluenrgmesh.view.fragments.tabs.ModelTabFragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;


public class ProvisionedRecyclerAdapter extends RecyclerView.Adapter<ProvisionedRecyclerAdapter.ViewHolder>  {

    private String className;
    private  boolean is_command_error=false;
    private  String selected_element_address=null;
    ArrayList<Nodes> provisionedNodes;
    private Context context;
    private IRecyclerViewHolderClicks listener;
    private ElementsRecyclerAdapter elementsRecyclerAdapter;
    private int TEMPERATURE_SENSOR_PROP_ID = 0X2A1F;
    private int PRESSURE_SENSOR_PROP_ID = 0X2A6D;


    public ProvisionedRecyclerAdapter(Context context, String className,  ArrayList<Nodes> provisionedNodes, String selected_element_address, boolean is_command_error, IRecyclerViewHolderClicks l) {

        this.context = context;
        this.className = className;
        this.provisionedNodes = provisionedNodes;
        this.listener = l;
        this.selected_element_address=selected_element_address;
        this.is_command_error=is_command_error;
    }

    public void sortData() {
        if(provisionedNodes!=null && provisionedNodes.size()>0)
            Collections.sort(provisionedNodes);
    }


    public interface IRecyclerViewHolderClicks {
        /**
         * On click recycler item.
         *
         * @param v          the v
         * @param position   the position
         * @param item       the item
         * @param isSelected the str selected
         */
        public void onClickRecyclerItem(View v, int position, String item, String mAutoAddress, boolean isSelected);
        void notifyAdapter(String selected_element_address,boolean is_command_error);
        void notifyPosition(int elementPosition, Nodes node);
    }

    @Override
    public ProvisionedRecyclerAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.child_row_nodes, parent, false);

        ProvisionedRecyclerAdapter.ViewHolder vh = new ProvisionedRecyclerAdapter.ViewHolder(v);

        return vh;
    }

    @Override
    public void onBindViewHolder(final ProvisionedRecyclerAdapter.ViewHolder holder, final int position) {

        holder.imgHeartBeatInfo.setVisibility(View.GONE);
        if(!provisionedNodes.get(position).isShowProgress())
        {
            holder.black_viewFL.setVisibility(View.GONE);
        }
        if (context.getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
            holder.elementsRecyclerView.setVisibility(View.VISIBLE);
            holder.imageDelete.setVisibility(View.GONE);
            holder.imageButtonGroupOn.setVisibility(View.GONE);
            holder.imageButtonGroupOff.setVisibility(View.GONE);
            holder.lay_imageAddBut.setVisibility(View.GONE);
            holder.seekBar.setVisibility(View.GONE);
        } else {
            // device list
            holder.elementsRecyclerView.setVisibility(View.GONE);
            holder.imageDelete.setVisibility(View.GONE);
            holder.imageButtonGroupOn.setVisibility(View.GONE);
            holder.imageButtonGroupOff.setVisibility(View.GONE);
            holder.lay_imageAddBut.setVisibility(View.GONE);
            holder.seekBar.setVisibility(View.GONE);

        }


        if (provisionedNodes != null) {
            if (provisionedNodes.get(position).getFeatures() != null) {
                holder.nodetype_3TV.setEnabled(false);
                holder.nodetype_4TV.setEnabled(false);
                holder.nodetype_2TV.setEnabled(false);
                holder.nodetype_1TV.setEnabled(false);

                if (provisionedNodes.get(position).getFeatures().getProxy() == 1) {
                    holder.nodetype_1TV.setVisibility(View.VISIBLE);
                } else {
                    holder.nodetype_1TV.setVisibility(View.GONE);

                }
                if (provisionedNodes.get(position).getFeatures().getRelay() == 1) {
                    holder.nodetype_2TV.setVisibility(View.VISIBLE);

                } else {
                    holder.nodetype_2TV.setVisibility(View.GONE);

                }
                if (provisionedNodes.get(position).getFeatures().getFriend() == 1) {
                    holder.nodetype_4TV.setVisibility(View.VISIBLE);
                } else {
                    holder.nodetype_4TV.setVisibility(View.GONE);

                }
                if (provisionedNodes.get(position).getFeatures().getLowPower() == 1) {
                    holder.nodetype_3TV.setVisibility(View.VISIBLE);
                } else {
                    holder.nodetype_3TV.setVisibility(View.GONE);

                }
            } else {
                GoneAllFeature(holder);
            }
        } else {
            GoneAllFeature(holder);
        }


        try {
            if (Utils.getProxyNode(context) != null && Utils.getProxyNode(context).equalsIgnoreCase(provisionedNodes.get(position).getAddress()))
            {
                holder.proxy_nodeTV.setVisibility(View.GONE);
                holder.textViewTitle.setTextColor(context.getResources().getColor(R.color.st_brown));
                holder.textViewTitle.setTypeface(null, Typeface.BOLD);
            }
            else
            {
                holder.textViewTitle.setTextColor(context.getResources().getColor(R.color.st_black));
                holder.textViewTitle.setTypeface(null, Typeface.NORMAL);
                holder.proxy_nodeTV.setVisibility(View.GONE);
            }
        } catch (Exception e) {
        }

        holder.textViewTitle.setText(provisionedNodes.get(position).getName());
        holder.textViewSubtitle.setText(Utils.insertDashUUID(provisionedNodes.get(position).getUUID()));
        //holder.textViewSubtitle.setText(provisionedNodes.get(position).getAddress());
        
        holder.imgHeartBeatInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Utils.moveToFragment((MainActivity)context, new HeartBeatInfoFragment(), null, 0);
            }
        });

        holder.imageSettings.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                switchToSettingsPage(v, event, provisionedNodes.get(position).getElements().get(0).getUnicastAddress(), position);
                return true;
            }
        });

        /*holder.imageItemDevice.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                Utils.toggleDevice(context, v, event, provisionedNodes.get(position).getElements().get(0).getUnicastAddress(), null, -1, null);
                return true;
            }
        });*/

        if (context.getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
            try {

                createElementsView(holder, position, null, provisionedNodes.get(position),is_command_error,selected_element_address);
            } catch (Exception e) {
            }
        }


        if(className.equalsIgnoreCase(new ModelTabFragment().getClass().getName()))
        {
            holder.imageButtons.setVisibility(View.GONE);
        }
        else
        {
            holder.imageButtons.setVisibility(View.VISIBLE);
        }

        int height = holder.lytDevice.getHeight();
        holder.black_viewFL.getLayoutParams().height = height;
        holder.black_viewFL.requestLayout();

    }




    private void GoneAllFeature(ProvisionedRecyclerAdapter.ViewHolder holder) {

        /*holder.nodetype_3TV.setBackground(R.drawable.round_background_gray);
        holder.nodetype_4TV.setEnabled(false);
        holder.nodetype_2TV.setEnabled(false);
        holder.nodetype_1TV.setEnabled(false);*/

        holder.nodetype_1TV.setVisibility(View.GONE);
        holder.nodetype_2TV.setVisibility(View.GONE);
        holder.nodetype_4TV.setVisibility(View.GONE);
        holder.nodetype_3TV.setVisibility(View.GONE);


    }

    private void createElementsView(final ProvisionedRecyclerAdapter.ViewHolder holder, int position, Map<String, Object> map, final Nodes node,boolean is_command_error,final String element_Address) {

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(context, 1, LinearLayoutManager.VERTICAL, false);
        holder.elementsRecyclerView.setLayoutManager(gridLayoutManager);
        elementsRecyclerAdapter = new ElementsRecyclerAdapter(context, className,  node, map,is_command_error,position, element_Address, new ElementsRecyclerAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void onClickRecyclerItem(final String element_Address, final int element_pos) {
                ((MainActivity)context).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        holder.black_viewFL.setVisibility(View.GONE);
                        holder.elementsRecyclerView.stopScroll();
                        // createElementsView(holder,element_pos,null,node,true,element_Address);
                        listener.notifyAdapter(element_Address, true);
                    }
                });

            }

            @Override
            public void onElementToggle(final String address, final int ele_position,final byte status) {
                ((MainActivity)context).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        holder.black_viewFL.setVisibility(View.GONE);
                        if(status==0){ //success
                        }else {
                            //failure
                            holder.elementsRecyclerView.stopScroll();
                            elementsRecyclerAdapter.showErrorCommand(ele_position,address);
                        }
                    }
                });


                //     Toast.makeText(context, "Click" + address, Toast.LENGTH_SHORT).show();


            }

            @Override
            public void showFrameOverNode(String addres, final int ele_position) {
                ((MainActivity)context).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        holder.black_viewFL.setVisibility(View.VISIBLE);
                    }
                });

                //  Toast.makeText(context, "showframe", Toast.LENGTH_SHORT).show();

            }

            @Override
            public void onSensorRefresh(Nodes node, int ele_pos, ApplicationParameters.PropertyID propertyID) {

                holder.black_viewFL.setVisibility(View.VISIBLE);
                listener.notifyPosition(ele_pos, node);
                Element element = node.getElements().get(ele_pos);
                SensorModelClient mSensorModelClient = ((MainActivity)context).network.getSensorModel();
                ApplicationParameters.Address elementAddress = new ApplicationParameters.Address(Integer.parseInt(element.getUnicastAddress()));
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("GetSensor command sent for==>"+elementAddress, LoggerConstants.TYPE_SEND);

                mSensorModelClient.getSensor(elementAddress,propertyID, SensorModelCallbacks.mGetSensorStatusCallback);
            }
        });

        holder.elementsRecyclerView.setAdapter(elementsRecyclerAdapter);
        //Utils.calculateHeight1(node.getNumberOfElements(), holder.elementsRecyclerView);

    }

    private void switchToSettingsPage(View v, MotionEvent event, String address, int position) {
        try {
            mobleAddress address1 = mobleAddress.deviceAddress(Integer.parseInt(address, 16));

            if (MotionEvent.ACTION_DOWN == event.getAction()) {
                if (Utils.getVibrator(context) != null) {
                    Utils.getVibrator(context).vibrate(50);
                }
            } else if (MotionEvent.ACTION_UP == event.getAction()) {

                NodeSettings nodeSettings = new NodeSettings();
                nodeSettings.setmCid(provisionedNodes.get(position).getCid());
                nodeSettings.setmPid(provisionedNodes.get(position).getPid());
                nodeSettings.setmVid(provisionedNodes.get(position).getVid());
                nodeSettings.setmCrpl(provisionedNodes.get(position).getCrpl());
                nodeSettings.setNodesName(provisionedNodes.get(position).getName());
                nodeSettings.setNodesUnicastAddress(address);
                nodeSettings.setNodesMacAddress(provisionedNodes.get(position).getAddress());
                nodeSettings.setUuid(Utils.insertDashUUID(provisionedNodes.get(position).getUUID()));
                if (provisionedNodes != null && provisionedNodes.get(position).getFeatures() != null) {
                    if (provisionedNodes.get(position).getFeatures().getProxy() == 1) {
                        nodeSettings.setProxy(true);
                    } else {
                        nodeSettings.setProxy(false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getRelay() == 1) {
                        nodeSettings.setRelay(true);
                    } else {
                        nodeSettings.setRelay(false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getFriend() == 1) {
                        nodeSettings.setFriend(true);
                    } else {
                        nodeSettings.setFriend(false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getLowPower() == 1) {
                        nodeSettings.setLowPower(true);
                    } else {
                        nodeSettings.setLowPower(false);
                    }
                }

                Utils.moveToFragment((MainActivity)context, new NodeSettingFragment(), nodeSettings, 0);

                /*Intent setting = new Intent(context, AddGroupActivity.class);
                if ((address1.mValue & 0xFFFF) < 49155) {
                    //device settings

                    setting.putExtra("device", true);
                    setting.putExtra("m_address", address);
                    setting.putExtra("address", provisionedNodes.get(position).getAddress());
                    setting.putExtra("isAddNewGroup", "false");

                }

                setting.putExtra("isLightsGroupSetting", "false");
                setting.putExtra("UUID", Utils.insertDashUUID(provisionedNodes.get(position).getUUID()));

                if (provisionedNodes != null && provisionedNodes.get(position).getFeatures() != null) {
                    if (provisionedNodes.get(position).getFeatures().getProxy() == 1) {
                        setting.putExtra("isProxy", true);
                    } else {
                        setting.putExtra("isProxy", false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getRelay() == 1) {
                        setting.putExtra("isRelay", true);
                    } else {
                        setting.putExtra("isRelay", false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getFriend() == 1) {
                        setting.putExtra("isFriend", true);
                    } else {
                        setting.putExtra("isFriend", false);
                    }
                    if (provisionedNodes.get(position).getFeatures().getLowPower() == 1) {
                        setting.putExtra("isLowPower", true);
                    } else {
                        setting.putExtra("isLowPower", false);
                    }
                }
                ((MainActivity) context).startActivityForResult(setting, ((MainActivity) context).UNPROVISION_SUCCESS_RESULT_CODE);*/
            }
        } catch (Exception e) {

        }

    }

    @Override
    public int getItemCount() {
        return provisionedNodes.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private RelativeLayout lytDevice;
        private ImageView imgHeartBeatInfo;
                private RelativeLayout imageButtons;
        private TextView textViewTitle, showelementsTV, nodetype_1TV, nodetype_2TV, nodetype_3TV, nodetype_4TV;
        private TextView textViewSubtitle,proxy_nodeTV;
        private ImageView imageSettings;
        private RelativeLayout lay_imageAddBut;
        private RecyclerView elementsRecyclerView;
        private ImageView imageDelete;
        private ImageView imageButtonGroupOn;
        private ImageView imageButtonGroupOff;
        private ImageView imgShowElements;
        private SeekBar seekBar;
        private LinearLayout black_viewFL;

        public ViewHolder(View itemView) {
            super(itemView);

            textViewTitle = (TextView) itemView.findViewById(R.id.textViewTitle);
            textViewSubtitle = (TextView) itemView.findViewById(R.id.textViewSubtitle);
            lay_imageAddBut = (RelativeLayout) itemView.findViewById(R.id.lay_imageAddBut);
            elementsRecyclerView = (RecyclerView) itemView.findViewById(R.id.elementsRecyclerView);
            imageSettings = (ImageView) itemView.findViewById(R.id.imageSettings);
            imageDelete = (ImageView) itemView.findViewById(R.id.imageDelete);
            imageButtonGroupOn = (ImageView) itemView.findViewById(R.id.imageButtonGroupOn);
            imageButtonGroupOff = (ImageView) itemView.findViewById(R.id.imageButtonGroupOff);
            seekBar = (SeekBar) itemView.findViewById(R.id.seekBar);
            nodetype_1TV = (TextView) itemView.findViewById(R.id.nodetype_1TV);
            nodetype_2TV = (TextView) itemView.findViewById(R.id.nodetype_2TV);
            nodetype_3TV = (TextView) itemView.findViewById(R.id.nodetype_3TV);
            nodetype_4TV = (TextView) itemView.findViewById(R.id.nodetype_4TV);
            black_viewFL = (LinearLayout)itemView.findViewById(R.id.black_viewFL);

            imageButtons = (RelativeLayout) itemView.findViewById(R.id.imageButtons);
            proxy_nodeTV = (TextView)itemView.findViewById(R.id.proxy_nodeTV);
            imgHeartBeatInfo = (ImageView)itemView.findViewById(R.id.imgHeartBeatInfo);
            lytDevice = (RelativeLayout) itemView.findViewById(R.id.lytDevice);
        }
    }
}
