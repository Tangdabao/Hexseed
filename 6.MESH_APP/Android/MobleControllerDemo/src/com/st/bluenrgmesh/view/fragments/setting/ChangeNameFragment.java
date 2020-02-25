/**
 * *****************************************************************************
 *
 * @file ChangeNameFragment.java
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

package com.st.bluenrgmesh.view.fragments.setting;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import org.json.JSONObject;


public class ChangeNameFragment extends BaseFragment {

    public AppDialogLoader loader;
    private EditText network_name;
    private EditText provisioner_name;
    public MeshRootClass meshRootClass;
    //SharedPreferences pref_model_selection;
    //SharedPreferences.Editor editor_model_selection;
    private View view;
    private Button butChangeName;
    private String net_name;
    private String name = android.os.Build.MODEL;
    private String prov_name;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_setting_changename, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        Utils.updateActionBarForFeatures(getActivity(), new ChangeNameFragment().getClass().getName());
        //updateJsonData();
        initUi();

        return view;
    }

    private void initUi() {

        net_name =  Utils.getNetworkName(getActivity());
        prov_name =  Utils.getProvisionerName(getActivity());
        if(meshRootClass != null){
            for (int i = 0; i < meshRootClass.getProvisioners().size(); i++) {
                if (meshRootClass.getProvisioners().get(i).getUUID().equals(Utils.getProvisionerUUID(getActivity()))) {
                    net_name = meshRootClass.getProvisioners().get(i).getProvisionerName();
                }
            }
        }

        network_name = (EditText) view.findViewById(R.id.network_name);



        /*pref_model_selection = getActivity().getApplicationContext().getSharedPreferences("Model_Selection", getActivity().MODE_PRIVATE);
        if(pref_model_selection != null){
            if(pref_model_selection.getString("Network_Name",null)!=null){
                net_name = pref_model_selection.getString("Network_Name",null);
            }
            if(pref_model_selection.getString("Provisioner_Name",null) != null){
                name = pref_model_selection.getString("Provisioner_Name",null);
            }
        }*/


        if(net_name != null){
            network_name.setText(net_name);
        }else{
            network_name.setText("Default_Mesh");
        }
        network_name.setSelection(network_name.getText().length());

        provisioner_name = (EditText) view.findViewById(R.id.provisioner_name);
        if(meshRootClass != null){
            provisioner_name.setText(meshRootClass.getMeshName());
        }else{
            provisioner_name.setText(name);
        }
        provisioner_name.setSelection(provisioner_name.getText().length());

        network_name = (EditText) view.findViewById(R.id.network_name);
        provisioner_name = (EditText) view.findViewById(R.id.provisioner_name);

        butChangeName = (Button) view.findViewById(R.id.butChangeName);
        butChangeName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                /*pref_model_selection = getActivity().getApplicationContext().getSharedPreferences("Model_Selection", getActivity().MODE_PRIVATE);
                editor_model_selection = pref_model_selection.edit();
                String nameee = String.valueOf(network_name.getText());
                editor_model_selection.putString("Network_Name",nameee);

                String prov_namee = String.valueOf(provisioner_name.getText());
                editor_model_selection.putString("Provisioner_Name",prov_namee);
                editor_model_selection.commit();*/
                try {
                    meshRootClass = ParseManager.getInstance().fromJSON(
                            new JSONObject(Utils.getBLEMeshDataFromLocal(getActivity())), MeshRootClass.class);
                    Utils.DEBUG(">> Json Data : " + Utils.getBLEMeshDataFromLocal(getActivity()));


                } catch (Exception e) {
                    e.printStackTrace();
                }
                if(meshRootClass != null) {
                    for (int i = 0; i < meshRootClass.getProvisioners().size(); i++) {
                        if (meshRootClass.getProvisioners().get(i).getUUID().equals(Utils.getProvisionerUUID(getActivity()))) {
                            meshRootClass.getProvisioners().get(i).setProvisionerName(net_name);
                        }
                    }
                    meshRootClass.setMeshName(name);
                }

                Utils.setBLEMeshDataToLocal(getActivity(), ParseManager.getInstance().toJSON(meshRootClass));

            }
        });
    }
}
