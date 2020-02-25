/**
 * *****************************************************************************
 *
 * @file ElementsRecylerAdapter.java
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

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.support.v7.widget.RecyclerView;
import android.transition.TransitionManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.GenericLevelModelClient;
import com.msi.moble.LightCTLModelClient;
import com.msi.moble.LightHSLModelClient;
import com.msi.moble.LightLightnessModelClient;
import com.msi.moble.SensorModelClient;
import com.msi.moble.mobleAddress;
import com.msi.moble.mobleNetwork;
import com.st.bluenrgmesh.AddGroupActivity;
import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.UserApplication;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.datamap.Nucleo;
import com.st.bluenrgmesh.logger.LoggerConstants;
import com.st.bluenrgmesh.models.ModelsData;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Model;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.NegativeSeekBar;
import com.st.bluenrgmesh.view.fragments.tabs.ModelTabFragment;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Map;


public class ElementsRecyclerAdapter extends RecyclerView.Adapter<ElementsRecyclerAdapter.ViewHolder> {

    private static final int LIGHTING_LIGHTNESS_MAX =65535 ;
    private ModelsData modelsData;
    //private final ArrayList<String> models_list = new ArrayList<String>();
    private String classname;
    private String element_Address = null;
    private int command_position = -1;
    private boolean is_command_error = false;
    private mobleAddress address;
    private Nodes node;
    private ArrayList<Element> elements;
    private Context context;
    private Map<String, Object> map;
    private IRecyclerViewHolderClicks listener;
    private boolean is_lyt_warning = false;
    private MeshRootClass meshRootClass;
    private int GENERIC_LEVEL_MAX = 32767;
    GenericLevelModelClient mGenericLevelModel;

    SharedPreferences pref_model_selection;
    private LightCTLModelClient lightCTLModelClient;
    private boolean is_ctl_selected = true;
    private LightLightnessModelClient lightLightnessModelClient;
    private LightHSLModelClient lightHSLModelClient;
    private int which_hsl_tab_selected=1;
    private String selectedModel;
    
    private Boolean enableLogs = false;

    public ElementsRecyclerAdapter(Context context, String classname, Nodes node, Map<String, Object> map, boolean is_command_error, int command_position, String element_Address, IRecyclerViewHolderClicks iRecyclerViewHolderClicks) {

        this.classname = classname;
        this.context = context;
        this.node = node;
        this.map = map;
        this.listener = iRecyclerViewHolderClicks;
        this.elements = node.getElements();
        this.is_command_error = is_command_error;
        this.command_position = command_position;
        this.element_Address = element_Address;
        selectedModel = Utils.getSelectedModel(context);
        

    }


    public void showErrorCommand(int position, String address) {
        updateJsonData();
        is_lyt_warning = true;
        int position_notify = -1;

        if (meshRootClass != null && meshRootClass.getNodes().size() > 0) {
            for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
                for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                    if (address.equalsIgnoreCase(meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress())) {
                        position_notify = j;
                        break;
                    }
                }
            }
        }
        if (position_notify > -1) {
            listener.onClickRecyclerItem(address, position_notify);
            //notifyItemChanged(position_notify);
        } else {
            Utils.showToast(context, "Unable to Execute Command! Kindly refersh the Page.");
        }


    }


    private void updateJsonData() {


        try {
            meshRootClass = ParseManager.getInstance().fromJSON(
                    new JSONObject(Utils.getBLEMeshDataFromLocal(context)), MeshRootClass.class);
        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    public static interface IRecyclerViewHolderClicks {

        void onClickRecyclerItem(String element_address, int command_position);

        void onElementToggle(String addres, int ele_pos, byte status);

        void showFrameOverNode(String addres, int ele_pos);

        void onSensorRefresh(Nodes node, int ele_pos, ApplicationParameters.PropertyID propertyID);
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.element_recycler_row, parent, false);

        ViewHolder vh = new ViewHolder(v);

        return vh;
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, final int position) {


        holder.imageSettings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(context, AddGroupActivity.class);
                intent.putExtra("device", true);
                intent.putExtra("address", node.getAddress());
                intent.putExtra("m_address", node.getElements().get(0).getUnicastAddress());
                intent.putExtra("elementUnicastAddress", node.getElements().get(position).getUnicastAddress());
                intent.putExtra("isAddNewGroup", "false");
                intent.putExtra("isLightsGroupSetting", "false");
                intent.putExtra("isElementSettings", true);
                context.startActivity(intent);
            }
        });

        holder.textViewTitle.setText(elements.get(position).getName());

        holder.lytWarning.setOnClickListener(new View.OnClickListener() {
            boolean visible;

            @Override
            public void onClick(View v) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    TransitionManager.beginDelayedTransition(holder.transitionsContainer);
                    visible = !visible;
                    holder.lytWarningMsg.setVisibility(visible ? View.VISIBLE : View.GONE);
                } else {
                    holder.lytWarningMsg.setVisibility(holder.lytWarningMsg.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                }
            }
        });


        if (is_command_error && element_Address != null && element_Address.equalsIgnoreCase(elements.get(position).getUnicastAddress())) {
            holder.lytWarning.setVisibility(View.VISIBLE);
            holder.lytWarningMsg.setVisibility(View.VISIBLE);
            is_lyt_warning = false;
            is_command_error = false;
            holder.butSwitch.setChecked(false);
        } else {
            holder.lytWarning.setVisibility(View.GONE);
            holder.lytWarningMsg.setVisibility(View.GONE);
            is_lyt_warning = false;
            is_command_error = false;
        }

        if (classname.equalsIgnoreCase(new ModelTabFragment().getClass().getName())) {

            //for model tab
            holder.imageButtons.setVisibility(View.GONE);
            holder.lytModelSupport.setVisibility(View.VISIBLE);
            updateUiForModels(holder, elements.get(position));
        } else {

            //for provisioned tab
            holder.imageItemDevice.setVisibility(View.GONE);
            holder.imageButtons.setVisibility(View.VISIBLE);
            holder.lytModelSupport.setVisibility(View.GONE);
            Utils.layLoopForModels(context, holder.lytAllModels, elements.get(position));
        }



        if(((MainActivity) context).tabSelected == ((MainActivity)context).PROVISIONED_TAB)
        {
            holder.imageItemDevice.setVisibility(View.GONE);
            holder.butSwitch.setVisibility(View.VISIBLE);
        }

        holder.lytTemperature.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                ApplicationParameters.PropertyID propertyID = new ApplicationParameters.PropertyID(0x004f);
                Utils.sensorModelEvents(context, v, event, elements.get(position).getUnicastAddress(), listener, position, node, propertyID);
                return true;
            }
        });

        holder.lytPressure.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                ApplicationParameters.PropertyID propertyID = new ApplicationParameters.PropertyID(0x2a6d);
                Utils.sensorModelEvents(context, v, event, elements.get(position).getUnicastAddress(), listener, position, node, propertyID);
                return true;
            }
        });

        holder.imageItemDevice.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                ApplicationParameters.PropertyID propertyID = null;
                Utils.sensorModelEvents(context, v, event, elements.get(position).getUnicastAddress(), listener, position, node, propertyID);
                return true;
            }
        });

        holder.butSwitch.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                holder.lytWarning.setVisibility(View.GONE);
                holder.lytWarningMsg.setVisibility(View.GONE);
                Utils.toggleDevice(context, v, event, elements.get(position).getUnicastAddress(), listener, position, node);
                return false;
            }
        });


        holder.linear_Toggle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                int addr = Integer.parseInt(node.getElements().get(position).getUnicastAddress().toString(), 16);

                ((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork().unadvise(Utils.mLibraryVersionCallback);
                mobleNetwork network = ((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork();
                network.getApplication().setRemoteData(mobleAddress.deviceAddress(addr), Nucleo.APPLI_CMD_LED_CONTROL, 1, new byte[]{Nucleo.APPLI_CMD_LED_TOGGLE}, true);

            }
        });

        holder.linear_Version.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                int addr = Integer.parseInt(node.getElements().get(position).getUnicastAddress().toString(), 16);
                Utils.contextU = context;
                ((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork().advise(Utils.mLibraryVersionCallback);
                mobleNetwork network = ((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork();
                network.getApplication().readRemoteData(mobleAddress.deviceAddress(addr), Nucleo.APPLI_CMD_DEVICE, 1, new byte[]{Nucleo.APPLI_CMD_DEVICE_BMESH_LIBVER}, true);

            }
        });

        holder.linear_Level.setOnClickListener(new View.OnClickListener() {


            @Override
            public void onClick(View v) {

                final Dialog dialog = new Dialog(context);
                dialog.setContentView(R.layout.seekbar_res_file);
                Window window = dialog.getWindow();
                window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                dialog.show();
                SeekBar seekBar = (SeekBar) dialog.findViewById(R.id.seekBar);
                final TextView txtIntensityValue1 = (TextView) dialog.findViewById(R.id.txtIntensityValue1);
                seekBar.setMax(GENERIC_LEVEL_MAX);
                Button closeBT = (Button) dialog.findViewById(R.id.closeBT);
                closeBT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dialog.dismiss();
                    }
                });
                seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                        //    String seekbarValue = String.valueOf(((seekBar.getProgress())*20);
                        txtIntensityValue1.setText(String.valueOf(seekBar.getProgress()));
                        int seekbar_val = (seekBar.getProgress() * 100) / GENERIC_LEVEL_MAX;
                        int intAddress = Integer.parseInt(node.getElements().get(position).getUnicastAddress().toString(), 16);

                        Utils.contextU = context;

                        ApplicationParameters.Address elementAddress = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress().toString(), 16));
                        UserApplication.trace("NavBar SeekBar Value Generic Model = " + txtIntensityValue1.getText().toString());

                        ApplicationParameters.Level level = new ApplicationParameters.Level(Integer.parseInt(txtIntensityValue1.getText().toString()));

                        if (((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork() != null) {
                            mGenericLevelModel = ((UserApplication) ((MainActivity) context).getApplication()).mConfiguration.getNetwork().getLevelModel();
                        }
                        ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("GenericLevelModel data send==>"+elementAddress, LoggerConstants.TYPE_SEND);
                        mGenericLevelModel.setGenericLevel(true,
                                elementAddress,
                                level,
                                new ApplicationParameters.TID(2),
                                null,
                                null,
                                mLevelCallback);

                        TextView txtIntensityValue = (TextView) dialog.findViewById(R.id.txtIntensityValue);
                        txtIntensityValue.setText(seekbar_val + " %");

                    }
                });
            }
        });

        holder.imgBattery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });

        holder.imgRightArrow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });


        holder.light_ctl_LL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLightingPopup(position, "CTL");
            }
        });


        holder.lightessLL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLightingPopup(position, "Lightness");

            }
        });

        holder.light_hsl_LL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLightingPopup(position, "HSL");
            }
        });
    }

    private void updateUiForModels(ViewHolder holder, Element element) {

        if(selectedModel.equalsIgnoreCase(context.getString(R.string.str_genericmodel_label)))
        {
            holder.txtLevelIntensity.setText("Level");
            holder.linear_Toggle.setVisibility(View.GONE);
            holder.linear_Version.setVisibility(View.GONE);
            holder.linear_Level.setVisibility(View.VISIBLE);
            holder.light_ctl_LL.setVisibility(View.GONE);
            holder.lightessLL.setVisibility(View.GONE);
            holder.light_hsl_LL.setVisibility(View.GONE);
            holder.lytAccelerometer.setVisibility(View.GONE);
            holder.lytPressure.setVisibility(View.GONE);
            holder.lytTemperature.setVisibility(View.GONE);
            holder.imageItemDevice.setVisibility(View.GONE);
            holder.butSwitch.setVisibility(View.VISIBLE);
        }
        else if(selectedModel.equalsIgnoreCase(context.getString(R.string.str_lighting_model_label)))
        {
            for (int i = 0; i < element.getModels().size(); i++) {
                String modelId = element.getModels().get(i).getModelId();
                if(modelId.equalsIgnoreCase(context.getString(R.string.MODEL_ID_1303_LIGHT_CTL_SERVER))
                        || modelId.equalsIgnoreCase(context.getString(R.string.MODEL_ID_1304_LIGHT_CTL_SETUP_SERVER))
                        || modelId.equalsIgnoreCase(context.getString(R.string.MODEL_ID_1306_LIGHT_CTL_TEMPERATURE_SERVER)))
                {
                    //CTL UI
                    holder.light_ctl_LL.setVisibility(View.VISIBLE);
                }

                if(modelId.equalsIgnoreCase(context.getString(R.string.MODEL_ID_1307_LIGHT_HSL_SERVER))
                        || modelId.equalsIgnoreCase(context.getString(R.string.MODEL_ID_1308_LIGHT_HSL_SETUP_SERVER)))
                {
                    //HSL UI
                    holder.light_hsl_LL.setVisibility(View.VISIBLE);
                }

            }

            holder.lightessLL.setVisibility(View.VISIBLE);
            holder.butSwitch.setVisibility(View.VISIBLE);
            holder.lytAccelerometer.setVisibility(View.GONE);
            holder.lytPressure.setVisibility(View.GONE);
            holder.lytTemperature.setVisibility(View.GONE);
            holder.imageItemDevice.setVisibility(View.GONE);
            holder.linear_Toggle.setVisibility(View.GONE);
            holder.linear_Version.setVisibility(View.GONE);
            holder.linear_Level.setVisibility(View.GONE);
        }
        else if(selectedModel.equalsIgnoreCase(context.getString(R.string.str_vendormodel_label)))
        {
            holder.txtLevelIntensity.setText("Intensity");
            holder.linear_Toggle.setVisibility(View.VISIBLE);
            holder.linear_Version.setVisibility(View.VISIBLE);
            holder.linear_Level.setVisibility(View.VISIBLE);
            holder.light_ctl_LL.setVisibility(View.GONE);
            holder.lightessLL.setVisibility(View.GONE);
            holder.light_hsl_LL.setVisibility(View.GONE);
            holder.lytAccelerometer.setVisibility(View.GONE);
            holder.lytPressure.setVisibility(View.GONE);
            holder.lytTemperature.setVisibility(View.GONE);
            holder.imageItemDevice.setVisibility(View.GONE);
            holder.butSwitch.setVisibility(View.VISIBLE);
        }
        else if(selectedModel.equalsIgnoreCase(context.getString(R.string.str_sensormodel_label)))
        {
            holder.linear_Toggle.setVisibility(View.GONE);
            holder.linear_Version.setVisibility(View.GONE);
            holder.linear_Level.setVisibility(View.GONE);
            holder.light_ctl_LL.setVisibility(View.GONE);
            holder.lightessLL.setVisibility(View.GONE);
            holder.light_hsl_LL.setVisibility(View.GONE);
            holder.lytAccelerometer.setVisibility(View.GONE);
            holder.lytPressure.setVisibility(View.VISIBLE);
            holder.lytTemperature.setVisibility(View.VISIBLE);
            holder.imageItemDevice.setVisibility(View.VISIBLE);
            holder.butSwitch.setVisibility(View.GONE);

            Utils.DEBUG("Sensor Value Updated");
            holder.txtTemperatureValue.setText((element.getTempSensorValue() == null || element.getTempSensorValue().isEmpty()) ? context.getString(R.string.str_temperature_label) : (element.getTempSensorValue()+" c"));
            holder.txtPressureValue.setText((element.getPressureSensorValue()== null || element.getPressureSensorValue().isEmpty()) ? context.getString(R.string.str_pressure_label) : element.getPressureSensorValue());
        }
    }


    @Override
    public int getItemCount() {
        return elements.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private TextView txtAccelerometerValue;
        private TextView txtTemperatureValue;
        private TextView txtPressureValue;
        private LinearLayout lytAccelerometer;
        private LinearLayout lytTemperature;
        private LinearLayout lytPressure;
        private LinearLayout lytAllModels;
        private ImageView imgToggle;
        private ImageView imgVersion;
        private ImageView imgLevel;
        private ImageView imgBattery;
        private ImageView imgRightArrow;
        private LinearLayout linear_Toggle;
        private LinearLayout linear_Version;
        private LinearLayout linear_Level;
        private LinearLayout lytModelSupport;
        private LinearLayout imageButtons;
        private Switch butSwitch;
        private TextView txtLevelIntensity;
        private TextView textViewTitle;
        private ImageView imageItemDevice;
        private ImageView imageSettings;
        private LinearLayout lytWarning, light_ctl_LL, lightessLL, light_hsl_LL;
        private RelativeLayout lytWarningMsg;
        private ViewGroup transitionsContainer;
        private HorizontalScrollView textScrollTitle;

        public ViewHolder(View itemView) {
            super(itemView);

            linear_Toggle = (LinearLayout) itemView.findViewById(R.id.linear_Toggle);
            linear_Version = (LinearLayout) itemView.findViewById(R.id.linear_Version);
            linear_Level = (LinearLayout) itemView.findViewById(R.id.linear_Level);
            imageSettings = (ImageView) itemView.findViewById(R.id.imageSettings);
            imageItemDevice = (ImageView) itemView.findViewById(R.id.imageItemDevice);
            textViewTitle = (TextView) itemView.findViewById(R.id.textViewTitle);
            butSwitch = (Switch) itemView.findViewById(R.id.butSwitch);
            lytWarning = (LinearLayout) itemView.findViewById(R.id.lytWarning);
            //lytWarningMsg = (RelativeLayout) itemView.findViewById(R.id.lytWarningMsg);
            transitionsContainer = (ViewGroup) itemView.findViewById(R.id.lyt_Title);
            textScrollTitle = (HorizontalScrollView) transitionsContainer.findViewById(R.id.textScrollTitle);
            lytWarningMsg = (RelativeLayout) transitionsContainer.findViewById(R.id.lytWarningMsg);
            imageButtons = (LinearLayout) itemView.findViewById(R.id.imageButtons);
            lytModelSupport = (LinearLayout) itemView.findViewById(R.id.lytModelSupport);
            imgToggle = (ImageView) itemView.findViewById(R.id.imgToggle);
            imgVersion = (ImageView) itemView.findViewById(R.id.imgVersion);
            imgLevel = (ImageView) itemView.findViewById(R.id.imgLevel);
            imgBattery = (ImageView) itemView.findViewById(R.id.imgBattery);
            imgRightArrow = (ImageView) itemView.findViewById(R.id.imgRightArrow);

            lytAllModels = (LinearLayout) itemView.findViewById(R.id.lytAllModels);
            light_ctl_LL = (LinearLayout) itemView.findViewById(R.id.light_ctl_LL);
            lightessLL = (LinearLayout) itemView.findViewById(R.id.lightessLL);
            light_hsl_LL = (LinearLayout) itemView.findViewById(R.id.light_hsl_LL);
            lytAccelerometer = (LinearLayout) itemView.findViewById(R.id.lytAccelerometer);
            lytTemperature = (LinearLayout) itemView.findViewById(R.id.lytTemperature);
            lytPressure = (LinearLayout) itemView.findViewById(R.id.lytPressure);
            txtAccelerometerValue = (TextView) itemView.findViewById(R.id.txtAccelerometerValue);
            txtTemperatureValue = (TextView) itemView.findViewById(R.id.txtTemperatureValue);
            txtPressureValue = (TextView) itemView.findViewById(R.id.txtPressureValue);
            txtLevelIntensity = (TextView) itemView.findViewById(R.id.txtLevelIntensity);


        }
    }

    private final GenericLevelModelClient.GenericLevelStatusCallback mLevelCallback = new GenericLevelModelClient.GenericLevelStatusCallback() {
        @Override
        public void onLevelStatus(boolean timeout,
                                  ApplicationParameters.Level level,
                                  ApplicationParameters.Level targetLevel,
                                  ApplicationParameters.Time remainingTime) {
            if (timeout) {
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("Level Status Callback==>"+"timeout", LoggerConstants.TYPE_RECEIVE);
                UserApplication.trace("Generic Level Timeout");
            } else {
                UserApplication.trace("Generic Level status = SUCCESS ");

                UserApplication.trace("Generic Level current Level = " + level);
                UserApplication.trace("Generic Level Target Level = " + targetLevel);
                int mDimming = level.getValue();
                UserApplication.trace("Level is " + Integer.toString(level.getValue()));
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("Level Status Callback==>"+"Success", LoggerConstants.TYPE_RECEIVE);
            }
        }
    };


    void showLightingPopup(final int position, String from) {

        final Dialog dialog = new Dialog(context);
        if ("CTL".equalsIgnoreCase(from)) {
            lightCTLModelClient = ((MainActivity) context).app.mConfiguration.getNetwork().getLightnessCTLModel();

            dialog.setContentView(R.layout.activity_color_picker_view_example);
            Window window = dialog.getWindow();
            window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            dialog.show();
            final NegativeSeekBar cseekBar1, LseekBar3, only_TseekBar2, only_deltaseekBar2;
            final NegativeSeekBar TseekBar2;
            final EditText cTV, TTV, LTV, only_TTV, only_deltaTV, cTV1, TTV1, LTV1, only_TTV1, only_deltaTV1;
            cseekBar1 = (NegativeSeekBar) dialog.findViewById(R.id.cseekBar1);
            TseekBar2 = (NegativeSeekBar) dialog.findViewById(R.id.TseekBar2);
            LseekBar3 = (NegativeSeekBar) dialog.findViewById(R.id.LseekBar3);
            only_TseekBar2 = (NegativeSeekBar) dialog.findViewById(R.id.only_TseekBar2);
            only_deltaseekBar2 = (NegativeSeekBar) dialog.findViewById(R.id.only_deltaseekBar2);
            cseekBar1.setMin(-32768);
            cseekBar1.setMax(32768);
            only_deltaseekBar2.setMin(-32768);
            only_deltaseekBar2.setMax(32768);
            TseekBar2.setMax(20000);
            TseekBar2.setMin(800);
            LseekBar3.setMax(65535);
            LseekBar3.setMin(1);
            only_TseekBar2.setMin(800);
            only_TseekBar2.setMax(20000);
            cTV = (EditText) dialog.findViewById(R.id.cTV);
            TTV = (EditText) dialog.findViewById(R.id.TTV);
            LTV = (EditText) dialog.findViewById(R.id.LTV);

            cTV1 = (EditText) dialog.findViewById(R.id.cTV1);
            TTV1 = (EditText) dialog.findViewById(R.id.TTV1);
            LTV1 = (EditText) dialog.findViewById(R.id.LTV1);


            only_deltaTV = (EditText) dialog.findViewById(R.id.only_deltaTV);

            only_TTV = (EditText) dialog.findViewById(R.id.only_TTV);


            only_deltaTV1 = (EditText) dialog.findViewById(R.id.only_deltaTV1);

            only_TTV1 = (EditText) dialog.findViewById(R.id.only_TTV1);
            Button sendcommandBTCTL = (Button) dialog.findViewById(R.id.sendcommandBTCTL);
            Button close_BT = (Button) dialog.findViewById(R.id.closeBT);

            final Button ctl_tab_BT = (Button) dialog.findViewById(R.id.ctl_tab_BT);
            final Button temp_tab_BT = (Button) dialog.findViewById(R.id.temp_tab_BT);
            final LinearLayout ctl_LL = (LinearLayout) dialog.findViewById(R.id.ctl_LL);
            final LinearLayout only_temp_LL = (LinearLayout) dialog.findViewById(R.id.only_temp_LL);
            final LinearLayout only_delta_LL = (LinearLayout) dialog.findViewById(R.id.only_delta_LL);
            cTV.setText("1");
            TTV.setText("800");
            LTV.setText("1");
            cTV1.setText("1");
            TTV1.setText("800");
            LTV1.setText("1");
            only_TTV.setText("800");
            only_deltaTV.setText("1");
            only_TTV1.setText("800");
            only_deltaTV1.setText("1");
            cseekBar1.setProgress(1);
            TseekBar2.setProgress(800);
            LseekBar3.setProgress(1);
            dialog.setCancelable(false);
            ctl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
            temp_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
            close_BT.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    dialog.dismiss();
                    is_ctl_selected = true;
                }
            });
            ctl_tab_BT.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ctl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                    temp_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                    is_ctl_selected = true;
                    only_temp_LL.setVisibility(View.GONE);
                    ctl_LL.setVisibility(View.VISIBLE);
                    only_delta_LL.setVisibility(View.GONE);
                }
            });

            temp_tab_BT.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    is_ctl_selected = false;
                    temp_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                    ctl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                    only_temp_LL.setVisibility(View.VISIBLE);
                    ctl_LL.setVisibility(View.GONE);
                    only_delta_LL.setVisibility(View.VISIBLE);
                }
            });
            sendcommandBTCTL.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    // dialog.dismiss();
                    try {
                        if (is_ctl_selected) {

                            ApplicationParameters.Address Address = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress()));

                            ApplicationParameters.Temperature temperature = new ApplicationParameters.Temperature((int) ((Double.parseDouble(TTV1.getText().toString())))
                                   /* TseekBar2.getProgress()*/);
                            ApplicationParameters.TemperatureDeltaUV temperatureDeltaUV = new ApplicationParameters.TemperatureDeltaUV((int) ((Double.parseDouble(cTV1.getText().toString()))));
                            ApplicationParameters.Lightness lightness1 = new ApplicationParameters.Lightness((int) ((Double.parseDouble(LTV1.getText().toString())))/*LseekBar3.getProgress()*/);
                            ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
                            ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);
                            ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL set Light CTL Command Send==>"+Address, LoggerConstants.TYPE_SEND);
                            lightCTLModelClient.setLightCTL(true, Address, lightness1, temperature, temperatureDeltaUV, tid, delay, Utils.isReliableEnabled(context)?mLightCTLStatusCallback:null);
                        } else {
                            ApplicationParameters.Address Address = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress()));

                            ApplicationParameters.Temperature temperature = new ApplicationParameters.Temperature((int) ((Double.parseDouble(only_TTV1.getText().toString())))/*only_TseekBar2.getProgress()*/);
                            ApplicationParameters.TemperatureDeltaUV temperatureDeltaUV = new ApplicationParameters.TemperatureDeltaUV((int) ((Double.parseDouble(only_deltaTV1.getText().toString())))/*only_deltaseekBar2.getProgress()*/);
                            ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
                            ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);
                            UserApplication.trace("temperatureDeltaUV_1 = "+ temperatureDeltaUV);
                            ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL set Light CTL Temperature Command Send==>"+Address, LoggerConstants.TYPE_SEND);
                            lightCTLModelClient.setLightCTLTemperature(true, Address, temperature, temperatureDeltaUV, tid, delay, Utils.isReliableEnabled(context)? mLightCTLTemperatureStatusCallback:null);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
            });
            cseekBar1.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //deltauv
                    cTV1.setText("" + progress);

                    if (progress > 0) {
                        double pos = Math.abs(progress);
                        double v = pos / 32768;
                        cTV.setText("" + String.format("%.2f", v));
                    } else {
                        double pos = Math.abs(progress);
                        double val = pos / 32768;
                        cTV.setText("-" + String.format("%.2f", Math.abs(val)));
                    }


                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });

            TseekBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //temp ctl
                    TTV1.setText("" + progress);

                    TTV.setText("" + progress + " k");

                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });

            LseekBar3.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //light ctl
                    LTV1.setText("" + progress);

                    LTV.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");
                    // int seekbar_val = (seekBar.getProgress()*100)/65535;

                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });


            only_TseekBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //temp
                    only_TTV.setText("" + progress + " k");
                    only_TTV1.setText("" + progress);


                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });
            only_deltaseekBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //delta temp
                    // only_deltaTV.setText("" + progress);
                    only_deltaTV1.setText("" + progress);
                    if (progress > 0) {
                        double pos = Math.abs(progress);
                        double v = pos / 32768;
                        only_deltaTV.setText("" + String.format("%.2f", v));
                    } else {
                        double pos = Math.abs(progress);
                        double val = pos / 32768;
                        only_deltaTV.setText("-" + String.format("%.2f", Math.abs(val)));
                    }


                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                }
            });


        }
        else if("HSL".equalsIgnoreCase(from))
        {
            {
                lightHSLModelClient = ((MainActivity) context).app.mConfiguration.getNetwork().getLightnessHSLModel();

                dialog.setContentView(R.layout.popup_hsl);
                Window window = dialog.getWindow();
                window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                dialog.show();
                final NegativeSeekBar hsl_seekBar_Hue,
                        hsl_seekBar_lightness,hsl_seekBar_saturation,
                        hsl_only_saturation_seekBar, hsl_only_hue_seekBar;
                final EditText hsl_hue_ET, hsl_saturation_ET,hsl_only_hue_ET, hsl_lightness_ET,hsl_hue_ET1, hsl_saturation_ET1, hsl_lightness_ET1,hsl_only_saturation_ET,hsl_only_saturation_ET1,hsl_only_hue_ET1;


                hsl_seekBar_Hue = (NegativeSeekBar) dialog.findViewById(R.id.hsl_seekBar_Hue);
                hsl_seekBar_saturation = (NegativeSeekBar) dialog.findViewById(R.id.hsl_seekBar_saturation);
                hsl_seekBar_lightness = (NegativeSeekBar) dialog.findViewById(R.id.hsl_seekBar_lightness);
                hsl_only_hue_seekBar = (NegativeSeekBar) dialog.findViewById(R.id.hsl_only_hue_seekBar);
                hsl_only_saturation_seekBar = (NegativeSeekBar) dialog.findViewById(R.id.hsl_only_saturation_seekBar);
                hsl_seekBar_Hue.setMin(0);
                hsl_seekBar_Hue.setMax(65535);
                hsl_seekBar_saturation.setMin(0);
                hsl_seekBar_saturation.setMax(65535);
                hsl_seekBar_lightness.setMax(65535);
                hsl_seekBar_lightness.setMin(0);
                hsl_only_saturation_seekBar.setMax(65535);
                hsl_only_saturation_seekBar.setMin(0);
                hsl_only_hue_seekBar.setMin(0);
                hsl_only_hue_seekBar.setMax(65535);


                hsl_hue_ET = (EditText) dialog.findViewById(R.id.hsl_hue_ET);
                hsl_saturation_ET = (EditText) dialog.findViewById(R.id.hsl_saturation_ET);
                hsl_lightness_ET = (EditText) dialog.findViewById(R.id.hsl_lightness_ET);

                hsl_hue_ET1 = (EditText) dialog.findViewById(R.id.hsl_hue_ET1);
                hsl_saturation_ET1 = (EditText) dialog.findViewById(R.id.hsl_saturation_ET1);
                hsl_lightness_ET1 = (EditText) dialog.findViewById(R.id.hsl_lightness_ET1);


                hsl_only_saturation_ET = (EditText) dialog.findViewById(R.id.hsl_only_saturation_ET);
                hsl_only_saturation_ET1 = (EditText) dialog.findViewById(R.id.hsl_only_saturation_ET1);
                hsl_only_hue_ET = (EditText) dialog.findViewById(R.id.hsl_only_hue_ET);
                hsl_only_hue_ET1 = (EditText) dialog.findViewById(R.id.hsl_only_hue_ET1);

                Button hsl_sendcommandBT = (Button) dialog.findViewById(R.id.hsl_sendcommandBT);
                Button hsl_closeBT = (Button) dialog.findViewById(R.id.hsl_closeBT);
                final Button hsl_tab_BT = (Button) dialog.findViewById(R.id.hsl_tab_BT);
                final Button hsl_hue_BT = (Button) dialog.findViewById(R.id.hsl_hue_BT);
                final Button hsl_saturation_BT = (Button) dialog.findViewById(R.id.hsl_saturation_BT);
                final LinearLayout hsl_LL = (LinearLayout) dialog.findViewById(R.id.hsl_LL);
                final LinearLayout hsl_only_saturation_LL = (LinearLayout) dialog.findViewById(R.id.hsl_only_saturation_LL);
                final LinearLayout hsl_only_hue_LL = (LinearLayout) dialog.findViewById(R.id.hsl_only_hue_LL);


                dialog.setCancelable(false);
                hsl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                hsl_hue_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                hsl_saturation_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));


                hsl_closeBT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dialog.dismiss();
                        which_hsl_tab_selected = 1;
                    }
                });

                hsl_tab_BT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        hsl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                        hsl_hue_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                        hsl_saturation_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                        which_hsl_tab_selected = 1;
                        hsl_only_saturation_LL.setVisibility(View.GONE);
                        hsl_LL.setVisibility(View.VISIBLE);
                        hsl_only_hue_LL.setVisibility(View.GONE);
                    }
                });


                hsl_hue_BT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        hsl_hue_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                        hsl_saturation_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                        hsl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                        which_hsl_tab_selected = 2;

                        hsl_only_saturation_LL.setVisibility(View.GONE);
                        hsl_LL.setVisibility(View.GONE);
                        hsl_only_hue_LL.setVisibility(View.VISIBLE);
                    }
                });

                hsl_saturation_BT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        which_hsl_tab_selected = 3;
                        hsl_saturation_BT.setBackgroundColor(context.getResources().getColor(R.color.ST_primary_blue));
                        hsl_hue_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));
                        hsl_tab_BT.setBackgroundColor(context.getResources().getColor(R.color.white1));


                        hsl_only_saturation_LL.setVisibility(View.VISIBLE);
                        hsl_LL.setVisibility(View.GONE);
                        hsl_only_hue_LL.setVisibility(View.GONE);
                    }
                });
                hsl_sendcommandBT.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        // dialog.dismiss();
                        try {
                            if (which_hsl_tab_selected == 1) {

                                ApplicationParameters.Address Address = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress()));
                                ApplicationParameters.Saturation saturation = new ApplicationParameters.Saturation((int) ((Double.parseDouble(hsl_saturation_ET1.getText().toString()))));
                                ApplicationParameters.Hue hue = new ApplicationParameters.Hue((int) ((Double.parseDouble(hsl_hue_ET1.getText().toString()))));
                                ApplicationParameters.Lightness lightness = new ApplicationParameters.Lightness((int) ((Double.parseDouble(hsl_lightness_ET1.getText().toString())))/*LseekBar3.getProgress()*/);
                                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL set Light HSL Default Command Send==>"+Address, LoggerConstants.TYPE_SEND);
                                lightHSLModelClient.setLightHSLDefault(true,Address,lightness,hue,saturation,(Utils.isReliableEnabled(context))?mLightHSLDefaultStatusCallback:null);
                                //un-reliable
                               // lightHSLModelClient.setLightHSLDefault(false,Address,lightness,hue,saturation,null);
                            } else if (which_hsl_tab_selected == 2) {

                                ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
                                ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);
                                ApplicationParameters.Address Address = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress()));
                                ApplicationParameters.Hue hue = new ApplicationParameters.Hue((int) ((Double.parseDouble(hsl_only_hue_ET1.getText().toString()))));
                                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL set Light HSL Hue Command Send==>"+Address, LoggerConstants.TYPE_SEND);
                                lightHSLModelClient.setLightHSLHue(true,Address,hue,tid,delay,(Utils.isReliableEnabled(context))?mLightHSLHueStatusCallback:null);
                                //un-reliable
                               // lightHSLModelClient.setLightHSLHue(false,Address,hue,tid,delay,null);
                            } else {
                                ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
                                ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);
                                ApplicationParameters.Address Address = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress()));
                                ApplicationParameters.Saturation saturation = new ApplicationParameters.Saturation((int) ((Double.parseDouble(hsl_only_saturation_ET1.getText().toString()))));
                                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL set Light HSL Saturation Command Send ==>"+Address, LoggerConstants.TYPE_SEND);
                                lightHSLModelClient.setLightHSLSaturation(true,Address,saturation,tid,delay,(Utils.isReliableEnabled(context))?mLightHSLSaturationStatusCallback:null);
                                //unreliable
                              //  lightHSLModelClient.setLightHSLSaturation(false,Address,saturation,tid,delay,null);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                    }
                });
                hsl_seekBar_Hue.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                        hsl_hue_ET1.setText("" + progress);
                        hsl_hue_ET.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");


                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                    }
                });

                hsl_seekBar_saturation.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                        hsl_saturation_ET1.setText("" + progress);
                        hsl_saturation_ET.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");


                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                    }
                });

                hsl_seekBar_lightness.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                        hsl_lightness_ET1.setText("" + progress);

                        hsl_lightness_ET.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");

                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                    }
                });


                hsl_only_hue_seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                        hsl_only_hue_ET1.setText("" + progress);
                        hsl_only_hue_ET.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");


                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                    }
                });
                hsl_only_saturation_seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                    @Override
                    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                        hsl_only_saturation_ET1.setText("" + progress);
                        hsl_only_saturation_ET.setText("" + (progress * 100) / LIGHTING_LIGHTNESS_MAX + " %");



                    }

                    @Override
                    public void onStartTrackingTouch(SeekBar seekBar) {

                    }

                    @Override
                    public void onStopTrackingTouch(SeekBar seekBar) {

                    }
                });


            }
        }


        else {
            lightLightnessModelClient = ((MainActivity) context).app.mConfiguration.getNetwork().getLightnessModel();

            dialog.setContentView(R.layout.seekbar_res_file);
            Window window = dialog.getWindow();
            window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

            dialog.show();

            TextView headingTV = (TextView) dialog.findViewById(R.id.headingTV);
            Button closeBT = (Button) dialog.findViewById(R.id.closeBT);
            headingTV.setText("Lighting");
            SeekBar seekBar = (SeekBar) dialog.findViewById(R.id.seekBar);
            seekBar.setMax(LIGHTING_LIGHTNESS_MAX);
            closeBT.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    dialog.dismiss();
                }
            });
            seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {

                    // String seekbarValue = String.valueOf((seekBar.getProgress()) * 20);
                    int seekbar_val = (seekBar.getProgress() * 100) / LIGHTING_LIGHTNESS_MAX;

                    Utils.contextU = context;
                    ApplicationParameters.Address elementAddress = new ApplicationParameters.Address(Integer.parseInt(node.getElements().get(position).getUnicastAddress().toString(), 16));
                  /*  ApplicationParameters.Lightness lightness = new ApplicationParameters.Lightness(Integer.parseInt(seekbarValue));
                    ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
                    ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);

                    mLightingLightnessModel. setLightnessLevel(true, elementAddress, lightness, tid, delay, mLightnessStatusCallback);

*/

                    sendLightnessCommand(elementAddress, seekBar.getProgress());
                    TextView txtIntensityValue = (TextView) dialog.findViewById(R.id.txtIntensityValue);
                    txtIntensityValue.setText(seekbar_val + " %");

                }
            });
        }

    }

    public LightCTLModelClient.LightCTLStatusCallback mLightCTLStatusCallback = new LightCTLModelClient.LightCTLStatusCallback() {

        @Override
        
        public void onLightCTLStatus(boolean timeout, ApplicationParameters.Lightness presentCTLLightness, ApplicationParameters.Temperature presentCTLtemperature,
                                     ApplicationParameters.Lightness targetCTLLightness, ApplicationParameters.Temperature targetCTLtemperature, ApplicationParameters.Time remainingTime) {
            if(timeout){
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
                if(enableLogs)
                {
                    UserApplication.trace("CTL LightCTLStatusCallback ==> timeout");

                }

            }else
            {
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"presentCTLLightness :" + presentCTLLightness, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"presentCTLtemperature :" + presentCTLtemperature, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"targetCTLLightness :" + targetCTLLightness, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"targetCTLtemperature :" + targetCTLtemperature, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLStatusCallback ==>"+"remainingTime :" + remainingTime, LoggerConstants.TYPE_RECEIVE);


                if(enableLogs)
                {
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"Success");
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"presentCTLLightness :" + presentCTLLightness);
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"presentCTLtemperature :" + presentCTLtemperature);
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"targetCTLLightness :" + targetCTLLightness);
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"targetCTLtemperature :" + targetCTLtemperature);
                    UserApplication.trace("CTL LightCTLStatusCallback ==>"+"remainingTime :" + remainingTime);

                }
            }

        }

    };

    public LightCTLModelClient.LightCTLTemperatureStatusCallback mLightCTLTemperatureStatusCallback = new LightCTLModelClient.LightCTLTemperatureStatusCallback() {
        @Override
       
        public void onLightCTLTemperatureStatus(boolean timeout, ApplicationParameters.Temperature presentCTLtemperature, ApplicationParameters.TemperatureDeltaUV presentCTLDeltaUV,
                                                ApplicationParameters.Temperature targetCTLtemperature, ApplicationParameters.TemperatureDeltaUV targetCTLDeltaUV, ApplicationParameters.Time remainingTime) {
            if(timeout){
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
                if(enableLogs)
                {
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==> timeout");

                }
            }else
            {
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"presentCTLtemperature :" + presentCTLtemperature, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"presentCTLDeltaUV :" + presentCTLDeltaUV, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"targetCTLtemperature :" + targetCTLtemperature, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"targetCTLDeltaUV :" + targetCTLDeltaUV, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("CTL LightCTLTemperatureStatusCallback ==>"+"remainingTime :" + remainingTime, LoggerConstants.TYPE_RECEIVE);
                if(enableLogs)
                {
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"Success");
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"presentCTLtemperature :" + presentCTLtemperature);
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"presentCTLDeltaUV :" + presentCTLDeltaUV);
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"targetCTLtemperature :" + targetCTLtemperature);
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"targetCTLDeltaUV :" + targetCTLDeltaUV);
                    UserApplication.trace("CTL LightCTLTemperatureStatusCallback ==>"+"remainingTime :" + remainingTime);

                }
            }

        }
    };

   public  LightHSLModelClient.LightHSLDefaultStatusCallback mLightHSLDefaultStatusCallback = new LightHSLModelClient.LightHSLDefaultStatusCallback() {
       @Override
       
       public void onLightHSLDefaultStatus(boolean b, ApplicationParameters.Lightness lightness, ApplicationParameters.Hue hue,
                                           ApplicationParameters.Saturation saturation) {
          if(b){
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLDefaultStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
              if(enableLogs)
              {
                  UserApplication.trace("HSL LightHSLDefaultStatusCallback ==> timeout");

              }
          }else
          {
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLDefaultStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLDefaultStatusCallback ==>"+"lightness :" + lightness, LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLDefaultStatusCallback ==>"+"hue :" + hue, LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLDefaultStatusCallback ==>"+"saturation :" + saturation, LoggerConstants.TYPE_RECEIVE);
              if(enableLogs)
              {
                  UserApplication.trace("HSL LightHSLDefaultStatusCallback ==>"+"Success");
                  UserApplication.trace("HSL LightHSLDefaultStatusCallback ==>"+"lightness :" + lightness);
                  UserApplication.trace("HSL LightHSLDefaultStatusCallback ==>"+"hue :" + hue);
                  UserApplication.trace("HSL LightHSLDefaultStatusCallback ==>"+"saturation :" + saturation);

              }
          }

       }
   };


  public  LightHSLModelClient.LightHSLSaturationStatusCallback mLightHSLSaturationStatusCallback = new LightHSLModelClient.LightHSLSaturationStatusCallback() {
      @Override
     
      public void onLightHSLStaurationStatus(boolean timeout, ApplicationParameters.Saturation hslPresentSaturation,
                                             ApplicationParameters.Saturation hslTargetSaturation, ApplicationParameters.Time remainingTime) {
          if(timeout){
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLSaturationStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
              if(enableLogs)
              {
                  UserApplication.trace("HSL LightHSLSaturationStatusCallback ==> timeout");

              }
          }else
          {
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLSaturationStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLSaturationStatusCallback ==>"+"hslPresentSaturation :" + hslPresentSaturation, LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLSaturationStatusCallback ==>"+"hslTargetSaturation : "  + hslTargetSaturation, LoggerConstants.TYPE_RECEIVE);
              ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLSaturationStatusCallback ==>"+"remainingTime :  " + remainingTime, LoggerConstants.TYPE_RECEIVE);
              if(enableLogs)
              {
                  UserApplication.trace("HSL LightHSLSaturationStatusCallback ==>"+"Success");
                  UserApplication.trace("HSL LightHSLSaturationStatusCallback ==>"+"hslPresentSaturation :" + hslPresentSaturation);
                  UserApplication.trace("HSL LightHSLSaturationStatusCallback ==>"+"hslTargetSaturation :" + hslTargetSaturation);
                  UserApplication.trace("HSL LightHSLSaturationStatusCallback ==>"+"remainingTime :" + remainingTime);

              }

          }

      }
  };

   public LightHSLModelClient.LightHSLHueStatusCallback mLightHSLHueStatusCallback= new LightHSLModelClient.LightHSLHueStatusCallback() {
       @Override
       
       public void onLightHSLHueStatus(boolean timeout, ApplicationParameters.Hue hslPresentHue, ApplicationParameters.Hue hslTargetHue, ApplicationParameters.Time remainingTime) {
           if(timeout){
               ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLHueStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
               if(enableLogs)
               {
                   UserApplication.trace("HSL LightHSLHueStatusCallback ==> timeout");

               }
           }else
           {
               ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLHueStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
               ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLHueStatusCallback ==>"+"hslPresentHue :" + hslPresentHue, LoggerConstants.TYPE_RECEIVE);
               ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLHueStatusCallback ==>"+"hslTargetHue :" + hslTargetHue, LoggerConstants.TYPE_RECEIVE);
               ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("HSL LightHSLHueStatusCallback ==>"+"remainingTime :  " + remainingTime, LoggerConstants.TYPE_RECEIVE);
               if(enableLogs)
               {
                   UserApplication.trace("HSL LightHSLHueStatusCallback ==>"+"Success");
                   UserApplication.trace("HSL LightHSLHueStatusCallback ==>"+"hslPresentHue :" + hslPresentHue);
                   UserApplication.trace("HSL LightHSLHueStatusCallback ==>"+"hslTargetHue :" + hslTargetHue);
                   UserApplication.trace("HSL LightCTLTemperatureStatusCallback ==>"+"remainingTime :" + remainingTime);

               }
           }

       }
   };

    public final LightLightnessModelClient.LightingLightnessStatusCallback mLightnessStatusCallback = new LightLightnessModelClient.LightingLightnessStatusCallback() {
        @Override
        
        public void onLightnessStatus(boolean timeout, ApplicationParameters.Lightness currentLightness, ApplicationParameters.Lightness targetLightness, ApplicationParameters.Time remainingTime) {

            if (timeout) {
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("LightnessStatusCallback timeout==>", LoggerConstants.TYPE_RECEIVE);
                if(enableLogs)
                {
                    UserApplication.trace("LightnessStatusCallback ==> timeout");

                }
            } else {
                UserApplication.trace("Lighting Lightness status = SUCCESS ");
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("LightnessStatusCallback ==>"+"Success", LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("LightnessStatusCallback ==>"+"currentLightness :" + currentLightness, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("LightnessStatusCallback ==>"+"targetLightness :" + targetLightness, LoggerConstants.TYPE_RECEIVE);
                ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("LightnessStatusCallback ==>"+"remainingTime :  " + remainingTime, LoggerConstants.TYPE_RECEIVE);
                if(enableLogs)
                {
                    UserApplication.trace("LightnessStatusCallback ==>"+"Success");
                    UserApplication.trace("LightnessStatusCallback ==>"+"currentLightness :" + currentLightness);
                    UserApplication.trace("LightnessStatusCallback ==>"+"targetLightness :" + targetLightness);
                    UserApplication.trace("LightCTLTemperatureStatusCallback ==>"+"remainingTime :" + remainingTime);

                }
            }
        }
    };


    public void sendLightnessCommand(ApplicationParameters.Address address, int value) {

        ApplicationParameters.Lightness lightness = new ApplicationParameters.Lightness(value);
        ApplicationParameters.TID tid = new ApplicationParameters.TID(1);
        ApplicationParameters.Delay delay = new ApplicationParameters.Delay(1);

        ((MainActivity)context).mUserDataRepository.getNewDataFromRemote("Lightness data send==>"+address, LoggerConstants.TYPE_SEND);

        lightLightnessModelClient.setLightnessLevel(true, address, lightness, tid, delay, mLightnessStatusCallback);


    }


}
