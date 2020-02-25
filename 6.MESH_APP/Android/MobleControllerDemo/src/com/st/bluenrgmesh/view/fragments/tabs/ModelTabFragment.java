/**
 * *****************************************************************************
 *
 * @file ModelTabFragment.java
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

package com.st.bluenrgmesh.view.fragments.tabs;

import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.ProvisionedRecyclerAdapter;
import com.st.bluenrgmesh.callbacks.SensorModelCallbacks;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;


public class ModelTabFragment extends BaseFragment {

    private static ModelTabFragment fragment;
    private View view;
    private RecyclerView recyclerView;
    private AppDialogLoader loader;
    private ProvisionedRecyclerAdapter provisionedRecyclerAdapter;
    private SwipeRefreshLayout swiperefresh;
    public static ArrayList<Nodes> nodes = new ArrayList<>();
    private ImageView slideLay;
    private ImageView imgArrow;
    public static String modelTypeSelected;
    private FrameLayout lytMainProfile;
    public int nodePosition = 0;
    public int elementPosition = 0;
    public Nodes sensorNode = null;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_model, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        initUi();

        return view;
    }

    private void initUi() {

        lytMainProfile = (FrameLayout) view.findViewById(R.id.lytMainProfile);
        recyclerView = (RecyclerView) view.findViewById(R.id.recyclerView);
        updateRecyclerView();
    }


    private void updateRecyclerView() {

        try {
            Collections.sort(nodes);
        } catch (Exception e) {
        }

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(gridLayoutManager);
        provisionedRecyclerAdapter = new ProvisionedRecyclerAdapter(getActivity(), new ModelTabFragment().getClass().getName(), nodes, null, false, new ProvisionedRecyclerAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void onClickRecyclerItem(View v, int position, String item, String mAutoAddress, boolean isSelected) {

            }

            @Override
            public void notifyAdapter(String selected_element_address, boolean is_command_error) {

            }

            @Override
            public void notifyPosition(int elementPos, Nodes node) {
                elementPosition = elementPos;
                sensorNode = node;
                enableProgressBar(node);
            }
        });
        recyclerView.setAdapter(provisionedRecyclerAdapter);
    }

    private void enableProgressBar(Nodes node) {
        for (int i = 0; i < nodes.size(); i++) {
            if(nodes.get(i).getElements().get(0).getUnicastAddress().equalsIgnoreCase(node.getElements().get(0).getUnicastAddress()))
            {
                nodes.get(i).setShowProgress(true);
            }
        }
    }

    public void cleanModelUi()
    {
        try {
            nodes.clear();
            if(provisionedRecyclerAdapter != null)
            {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        provisionedRecyclerAdapter.notifyDataSetChanged();
                    }
                });
            }
        }catch (Exception e){}
    }

    public void updateModelRecycler(String modelType) {

        recyclerView.setVisibility(View.GONE);
        loader.show();

        modelTypeSelected = modelType;
        Utils.DEBUG(">> Model type selected : " + modelTypeSelected);

        if (modelTypeSelected == null) {
            Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_vendormodel_label));
        } else {
            if (modelTypeSelected.equals(getString(R.string.str_genericmodel_label))) {
                Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_genericmodel_label));
            } else if (modelTypeSelected.equalsIgnoreCase(getString(R.string.str_lighting_model_label))) {
                Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_lighting_model_label));
            } else if (modelTypeSelected.equalsIgnoreCase(getString(R.string.str_vendormodel_label))) {
                Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_vendormodel_label));
            } else if (modelTypeSelected.equalsIgnoreCase(getString(R.string.str_sensormodel_label))) {
                Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_sensormodel_label));
            }

        }

        ((MainActivity)getActivity()).updateJsonData();

        nodes = Utils.getModelData(getActivity(), ((MainActivity)getActivity()).meshRootClass, modelTypeSelected);

        if(provisionedRecyclerAdapter != null)
        {
            //provisionedRecyclerAdapter.notifyDataSetChanged();
            updateRecyclerView();
        }
        else
        {
            updateRecyclerView();
        }


        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                recyclerView.setVisibility(View.VISIBLE);
                loader.hide();
                lytMainProfile.setVisibility(View.GONE);
            }
        }, 1000);

    }

    public static Fragment newInstance() {

        if( fragment == null ) {
            fragment = new ModelTabFragment();
        }
        return fragment;
    }

    /**
     *
     * @param sensorValue : Sensor Data
     * @param propertyId : sensorPropertyId
     */
    public void updateSensorValues(String sensorValue, int propertyId) {

        if(sensorValue != null)
        {
            String separatorStr = "New";
            String temperature = null;
            String pressure = null;
            String[] splited = sensorValue.split(separatorStr);

            //set this node to main list and update adapter
            try {
                for (int i = 0; i < nodes.size(); i++) {
                    if (nodes.get(i).getElements().get(0).getUnicastAddress().equalsIgnoreCase(sensorNode.getElements().get(0).getUnicastAddress())) {
                        if (propertyId == getResources().getInteger(R.integer.SENSOR_MODEL_TEMP_PROPERTYID)) {
                            temperature = splited[1];
                            temperature = temperature.substring(0, temperature.length() - 4);
                            nodes.get(i).getElements().get(elementPosition).setTempSensorValue(temperature);
                            nodes.get(i).setShowProgress(false);
                        } else if (propertyId == getResources().getInteger(R.integer.SENSOR_MODEL_PRESSURE_PROPERTYID)) {
                            pressure = splited[1];
                            pressure = pressure.substring(0, pressure.length() - 3);
                            nodes.get(i).getElements().get(elementPosition).setPressureSensorValue(pressure);
                            nodes.get(i).setShowProgress(false);
                        } else {
                            temperature = splited[1];
                            temperature = temperature.substring(0, temperature.length() - 4);
                            pressure = splited[2];
                            pressure = pressure.substring(0, pressure.length() - 3);
                            nodes.get(i).getElements().get(elementPosition).setTempSensorValue(temperature);
                            nodes.get(i).getElements().get(elementPosition).setPressureSensorValue(pressure);
                            nodes.get(i).setShowProgress(false);
                        }
                    }
                }
            }catch (Exception e){}

            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(provisionedRecyclerAdapter != null)
                    {
                        provisionedRecyclerAdapter.notifyDataSetChanged();
                    }
                }
            });
        }
        else
        {
            for (int i = 0; i < nodes.size(); i++) {
                if(nodes.get(i).getElements().get(0).getUnicastAddress().equalsIgnoreCase(sensorNode.getElements().get(0).getUnicastAddress()))
                {
                    nodes.get(i).setShowProgress(false);
                }
            }

            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(provisionedRecyclerAdapter != null)
                    {
                        provisionedRecyclerAdapter.notifyDataSetChanged();
                    }
                }
            });

        }


    }
}
