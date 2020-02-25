/**
 * *****************************************************************************
 *
 * @file ModelMenuFragment.java
 * @author BLE Mesh Team
 * @version V1.08.000
 * @date 10-October-2018
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

package com.st.bluenrgmesh.view.fragments.other.meshmodels;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Model;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;
import com.st.bluenrgmesh.view.fragments.tabs.GroupTabFragment;
import com.st.bluenrgmesh.view.fragments.tabs.ModelTabFragment;

import org.json.JSONObject;

import java.util.ArrayList;


public class ModelMenuFragment extends BaseFragment {

    private View view;
    private AppDialogLoader loader;
    private LinearLayout lytGenericModel;
    private LinearLayout lytVenderModel, lytlightlingModel;
    private MeshRootClass meshRootClass;
    SharedPreferences pref_model_selection;
    SharedPreferences.Editor editor_model_selection;
    private LinearLayout lytSensorModel;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_model_menu, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        Utils.updateActionBarForFeatures(getActivity(), new ModelMenuFragment().getClass().getName());
        updateJsonData();
        initUi();

        return view;
    }

    private void initUi() {

        lytGenericModel = (LinearLayout) view.findViewById(R.id.lytGenericModel);
        lytVenderModel = (LinearLayout) view.findViewById(R.id.lytVenderModel);
        lytlightlingModel = (LinearLayout) view.findViewById(R.id.lytlightlingModel);
        lytSensorModel = (LinearLayout) view.findViewById(R.id.lytSensorModel);
        updateUiPerModels();

        lytlightlingModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Utils.setSelectedModel(getActivity(), getString(R.string.str_lighting_model_label));
                /*pref_model_selection = getContext().getSharedPreferences("Model_Selection", Context.MODE_PRIVATE);
                editor_model_selection = pref_model_selection.edit();
                editor_model_selection.putBoolean("IsGeneric", false);
                editor_model_selection.putBoolean("IsLighting", true);
                editor_model_selection.putBoolean("IsSensor", false);
                editor_model_selection.commit();*/

                try {
                    if (meshRootClass.getNodes().size() > 0) {
                        String topFragmentInBackStack = Utils.getTopFragmentInBackStack(getActivity());
                        if (topFragmentInBackStack.equalsIgnoreCase(new ModelMenuFragment().getClass().getName())) {
                            ((MainActivity) getActivity()).onBackPressed();
                        }
                        Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_lighting_model_label));
                        ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), getString(R.string.str_lighting_model_label), 0, null, false, null);
                        ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), getString(R.string.str_lighting_model_label), 0, null, false, null);
                    }
                } catch (Exception e) {
                }

            }
        });
        lytGenericModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Utils.setSelectedModel(getActivity(), getString(R.string.str_genericmodel_label));

                /*pref_model_selection = getContext().getSharedPreferences("Model_Selection", Context.MODE_PRIVATE);
                editor_model_selection = pref_model_selection.edit();
                editor_model_selection.putBoolean("IsGeneric", true);
                editor_model_selection.putBoolean("IsLighting", false);
                editor_model_selection.putBoolean("IsSensor", false);
                editor_model_selection.commit();*/

                try {
                    if (meshRootClass.getNodes().size() > 0) {
                        String topFragmentInBackStack = Utils.getTopFragmentInBackStack(getActivity());
                        if (topFragmentInBackStack.equalsIgnoreCase(new ModelMenuFragment().getClass().getName())) {
                            ((MainActivity) getActivity()).onBackPressed();
                        }
                        Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_genericmodel_label));
                        ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), getString(R.string.str_genericmodel_label), 0, null, false, null);
                        ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), getString(R.string.str_genericmodel_label), 0, null, false, null);
                    }
                } catch (Exception e) {
                }


            }
        });

        lytVenderModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Utils.setSelectedModel(getActivity(), getString(R.string.str_vendormodel_label));
                /*pref_model_selection = getContext().getSharedPreferences("Model_Selection", Context.MODE_PRIVATE);
                editor_model_selection = pref_model_selection.edit();

                editor_model_selection.putBoolean("IsGeneric", false);
                editor_model_selection.putBoolean("IsLighting", false);
                editor_model_selection.putBoolean("IsSensor", false);

                editor_model_selection.commit();*/

                /*try {
                    if (meshRootClass.getNodes().size() > 0) {
                        String topFragmentInBackStack = Utils.getTopFragmentInBackStack(getActivity());
                        if (topFragmentInBackStack.equalsIgnoreCase(new ModelMenuFragment().getClass().getName())) {
                            ((MainActivity) getActivity()).onBackPressed();
                            Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), "Vendor Model");
                            ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), "Vendor", 0, null, false,null);
                            ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), "Vendor", 0, null, false, null);
                        } else {
                            Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), "Vendor Model");
                            ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), "Vendor", 0, null, false, null);
                            ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), "Vendor", 0, null, false, null);
                        }
                    }
                }catch (Exception e){}*/

                try {
                    if (meshRootClass.getNodes().size() > 0) {
                        String topFragmentInBackStack = Utils.getTopFragmentInBackStack(getActivity());
                        if (topFragmentInBackStack.equalsIgnoreCase(new ModelMenuFragment().getClass().getName())) {
                            ((MainActivity) getActivity()).onBackPressed();
                        }
                        Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_vendormodel_label));
                        ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), getString(R.string.str_vendormodel_label), 0, null, false, null);
                        ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), getString(R.string.str_vendormodel_label), 0, null, false, null);
                    }
                } catch (Exception e) {
                }


            }
        });


        lytSensorModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Utils.setSelectedModel(getActivity(), getString(R.string.str_sensormodel_label));

                /*pref_model_selection = getContext().getSharedPreferences("Model_Selection", Context.MODE_PRIVATE);
                editor_model_selection = pref_model_selection.edit();
                editor_model_selection.putBoolean("IsGeneric", false);
                editor_model_selection.putBoolean("IsLighting", false);
                editor_model_selection.putBoolean("IsSensor", true);
                editor_model_selection.commit();*/

                try {
                    if (meshRootClass.getNodes().size() > 0) {
                        String topFragmentInBackStack = Utils.getTopFragmentInBackStack(getActivity());
                        if (topFragmentInBackStack.equalsIgnoreCase(new ModelMenuFragment().getClass().getName())) {
                            ((MainActivity) getActivity()).onBackPressed();
                        }
                        Utils.updateActionBarForFeatures(getActivity(), new ModelTabFragment().getClass().getName(), getString(R.string.str_sensormodel_label));
                        ((MainActivity) getActivity()).fragmentCommunication(new GroupTabFragment().getClass().getName(), getString(R.string.str_sensormodel_label), 0, null, false, null);
                        ((MainActivity) getActivity()).fragmentCommunication(new ModelTabFragment().getClass().getName(), getString(R.string.str_sensormodel_label), 0, null, false, null);
                    }
                } catch (Exception e) {
                }


            }
        });

    }

    private void updateUiPerModels() {
        checkTypesOfModelsExist();
    }

    private void checkTypesOfModelsExist() {

        lytGenericModel.setVisibility(View.GONE);
        lytVenderModel.setVisibility(View.GONE);
        lytlightlingModel.setVisibility(View.GONE);
        lytSensorModel.setVisibility(View.GONE);


        if (meshRootClass.getNodes() == null) {
            return;
        }

        for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
            if (meshRootClass.getNodes().get(i).getElements() != null) {
                for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                    if (meshRootClass.getNodes().get(i).getElements().get(j).getModels() != null) {
                        for (int k = 0; k < meshRootClass.getNodes().get(i).getElements().get(j).getModels().size(); k++) {
                            String modelId = meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k).getModelId();
                            if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1300_LIGHT_LIGHTNESS_MODEL))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1301_LIGHT_LIGHTNESS_SETUP_MODEL))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1303_LIGHT_CTL_SERVER))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1304_LIGHT_CTL_SETUP_SERVER))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1306_LIGHT_CTL_TEMPERATURE_SERVER))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1307_LIGHT_HSL_SERVER))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1308_LIGHT_HSL_SETUP_SERVER))
                                    ) {
                                //Light Model
                                lytlightlingModel.setVisibility(View.VISIBLE);
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1002_GENERIC_LEVEL))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1000_GENERIC_STATUS))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_100c_GENERIC_BATTERY))
                                    || modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1000_GENERIC_ONOFF))) {
                                //Generic model
                                lytGenericModel.setVisibility(View.VISIBLE);
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_00010030_VENDOR_MODEL))) {
                                //vendor model
                                lytVenderModel.setVisibility(View.VISIBLE);
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_0000_CONFIGURATION_SERVER))) {
                                //configuration
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_0002_HEALTH_SERVER))) {
                                //health
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1100_SENSOR_MODEL))) {
                                //sensor
                                lytSensorModel.setVisibility(View.VISIBLE);
                            } else if (modelId.equalsIgnoreCase(getString(R.string.MODEL_ID_1200_TIME_MODEL))) {
                                //time
                            }
                        }
                    }
                }
            }
        }

    }

    private ArrayList<Model> getAllGenericModels(MeshRootClass meshRootClass) {

        ArrayList<Model> models = new ArrayList<>();

        for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
            for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                for (int k = 0; k < meshRootClass.getNodes().get(i).getElements().get(j).getModels().size(); k++) {
                    String modelID_json = meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k).getModelId();
                    if (modelID_json.equalsIgnoreCase(getString(R.string.MODEL_ID_1000_GENERIC_STATUS))
                            || modelID_json.equalsIgnoreCase(getString(R.string.MODEL_ID_1002_GENERIC_LEVEL))) {
                        models.add(meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k));
                    }
                }
            }
        }

        return models;

    }

    private void updateJsonData() {

        try {
            meshRootClass = ParseManager.getInstance().fromJSON(
                    new JSONObject(Utils.getBLEMeshDataFromLocal(getActivity())), MeshRootClass.class);
            //Utils.DEBUG(">> Json Data : " + Utils.getBLEMeshDataFromLocal(getActivity()));


        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

