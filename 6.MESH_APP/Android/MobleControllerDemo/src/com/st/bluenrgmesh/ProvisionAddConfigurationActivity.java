/**
 ******************************************************************************
 * @file    ProvisionAddConfigurationActivity.java
 * @author  BLE Mesh Team
 * @version V1.08.000
 * @date    15-October-2018
 * @brief   User Application file
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
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
 *
 * BlueNRG-Mesh is based on Motorola’s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 *
 ******************************************************************************
 */

package com.st.bluenrgmesh;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.ConfigurationModelClient;
import com.msi.moble.mobleAddress;
import com.msi.moble.mobleNetwork;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.PublicationListForProvisionAdapter;
import com.st.bluenrgmesh.adapter.SubscriptionListForProvisoningAdapter;
import com.st.bluenrgmesh.models.ModelInfo;
import com.st.bluenrgmesh.models.ModelsData;
import com.st.bluenrgmesh.models.meshdata.Group;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;

public class ProvisionAddConfigurationActivity extends AppCompatActivity {
    private static final int RESULT_CODE = 200;
    private MeshRootClass meshRootClass;
    private AppDialogLoader loader;
    private RecyclerView publishingRV, subscriptionRV;
    private Button addconfigBT;
    private SubscriptionListForProvisoningAdapter subListForGroupAdapter;
    private PublicationListForProvisionAdapter publicationRecyclerAdapter;
    private DeviceEntry mAutoDevice;
    static final String DEFAULT_NAME = "Device";
    private ProgressDialog mProgressDialog;
    private ConfigurationModelClient mConfigModel;
    private Boolean enableLogs = false;


    Boolean vendorModelPresent = false;
    ArrayList<String> vendor_models = new ArrayList<String>();

    ArrayList<ModelInfo> modelInfos = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_provision_add_configuration);
        loader = AppDialogLoader.getLoader(this);
        updateJsonData();
        initUI();
        setAdapterForSubscriptionList();
        setAdapterForPublicationList();
        checkNodeFeaturesCommand();
    }


    private void initUI() {
        is_feature_available = false;
        mConfigModel = mobleNetwork.getConfigurationModelClient();
        loader.show();
        subscriptionRV = (RecyclerView) findViewById(R.id.subscriptionRV);
        publishingRV = (RecyclerView) findViewById(R.id.publishingRV);
        addconfigBT = (Button) findViewById(R.id.addconfigBT);
        subscriptionRV = (RecyclerView) findViewById(R.id.subscriptionRV);
        addconfigBT.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addConfiguration("click");
            }
        });
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar); // get the reference of Toolbar
        setSupportActionBar(toolbar);
        toolbar.setTitle("Configuration");// Setting/replace toolbar as the ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // showAlert(ProvisionAddConfigurationActivity.this,"Alert","");
                //addConfiguration("back");
                onBackPressed();
            }
        });
    }

    private void addConfiguration(String from) {
        try {


            //updateJsonData();
            Intent intent = new Intent();
            //  intent.putExtra("Device_Entry",mAutoDevice);
            setResult(RESULT_CODE, intent);
            finish();

         /*   int min = Utils.getNextElementNumber(ProvisionAddConfigurationActivity.this, meshRootClass.getNodes());
            if (min == 0) {
                Utils.showToast(ProvisionAddConfigurationActivity.this, getString(R.string.network_is_full));
                return;
            }
            String name = "Uninitialized";
            name = String.format("%s %02d", DEFAULT_NAME, Utils.getNextNodeCount(meshRootClass.getNodes()));
            mAutoDevice = new DeviceEntry(name, mobleAddress.deviceAddress(min));
            sendAddGroupCommand();
*/
        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    private void sendAddGroupCommand() {
        showProgressBar();
        ((UserApplication) getApplication()).mConfiguration.getNetwork().getSettings().addGroup
                (this, mAutoDevice.getAddress(), mAutoDevice.getAddress(),
                        mobleAddress.groupAddress
                                (Integer.parseInt(Utils.getsubscriptiongroupAddressOnProvsioning(this), 16))
                        , mSubscriptionListener);
    }

    private void showProgressBar() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(this);
            mProgressDialog.setMessage("Configuring device...");
            mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mProgressDialog.setCancelable(false);
        }
        if (mProgressDialog != null) mProgressDialog.show();
    }

    private void hideProgressBar() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
            mProgressDialog = null;
        }
    }


    private void updateJsonData() {

        try {
            meshRootClass = ParseManager.getInstance().fromJSON(new JSONObject(Utils.getBLEMeshDataFromLocal(this)), MeshRootClass.class);
            //Utils.DEBUG(">> Json Data : " + Utils.getBLEMeshDataFromLocal(this));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void setAdapterForSubscriptionList() {
        ArrayList<Group> final_subscriptionList = new ArrayList<>();
        if (meshRootClass != null && meshRootClass.getGroups() != null && meshRootClass.getGroups().size() > 0) {
            final_subscriptionList = meshRootClass.getGroups();
        }
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(this, 1, LinearLayoutManager.VERTICAL, false);
        subscriptionRV.setLayoutManager(gridLayoutManager);
        subListForGroupAdapter = new SubscriptionListForProvisoningAdapter(this, final_subscriptionList, new SubscriptionListForProvisoningAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void notifyAdapter(int position) {
                subscriptionRV.stopScroll();
                subListForGroupAdapter.notifyDataSetChanged();

            }
        });
        subscriptionRV.setAdapter(subListForGroupAdapter);
        //Utils.calculateHeight(meshRootClass.getGroups().size(), subscriptionRV);

    }

    private void setAdapterForPublicationList() {
        ArrayList<Group> final_publicationNameList = new ArrayList<>();
        if (meshRootClass != null) {


            if (meshRootClass.getGroups() != null && meshRootClass.getGroups().size() > 0) {
                for (int i = 0; i < meshRootClass.getGroups().size(); i++) {

                    Group grp = new Group();
                    grp.setAddress(meshRootClass.getGroups().get(i).getAddress());
                    grp.setName(meshRootClass.getGroups().get(i).getName());

                    final_publicationNameList.add(grp);

                }
            }

            if (meshRootClass.getNodes() != null && meshRootClass.getNodes().size() > 0) {
                for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                    for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {

                        //avoid provisioner data from listing
                        boolean isProvisioner = false;

                        for (int k = 0; k < meshRootClass.getProvisioners().size(); k++) {

                            if(meshRootClass.getProvisioners().get(k).getUUID().equalsIgnoreCase(meshRootClass.getNodes().get(i).getUUID()))
                            {
                                isProvisioner = true;
                                break;
                            }
                        }

                        if(!isProvisioner){
                        Group grp = new Group();
                        grp.setAddress(meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress());

                            grp.setName(meshRootClass.getNodes().get(i).getName() + " / " + meshRootClass.getNodes().get(i).getElements().get(j).getName());

                        final_publicationNameList.add(grp);
                    }

                }
            }
        }
        }


        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(this, 1, LinearLayoutManager.VERTICAL, false);
        publishingRV.setLayoutManager(gridLayoutManager);
        publicationRecyclerAdapter = new PublicationListForProvisionAdapter(this, final_publicationNameList, new PublicationListForProvisionAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void notifyAdapter(int position) {
                publishingRV.stopScroll();
                publicationRecyclerAdapter.notifyDataSetChanged();
            }
        });
        publishingRV.setAdapter(publicationRecyclerAdapter);
        //  Utils.calculateHeight(subscriptionList.size(), publishingRecycler);

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                addConfiguration("back");
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        if (is_feature_available) {
            addConfiguration("back");
        } else {
            loader.dismiss();
            super.onBackPressed();
        }
    }

    private void checkNodeFeaturesCommand() {
        new Handler().post(new Runnable() {
            @Override
            public void run() {
        int min = Utils.getNextElementNumber(ProvisionAddConfigurationActivity.this, meshRootClass.getNodes());
        if (min == 0) {
            Utils.showToast(ProvisionAddConfigurationActivity.this,getString(R.string.network_is_full));
            return;
        }
        String name = String.format("%s %02d", DEFAULT_NAME, Utils.getNextNodeCount(meshRootClass.getNodes()));
        mAutoDevice = new DeviceEntry(name, mobleAddress.deviceAddress(min));

        mConfigModel.getDeviceCompositionData(new ApplicationParameters.Address(mAutoDevice.getAddress().mValue), ApplicationParameters.Page.PAGE0, deviceCompositionDataStatus_callback);
            }
        });
    }

    private final ConfigurationModelClient.ConfigModelSubscriptionStatusCallback mSubscriptionListener = new ConfigurationModelClient.ConfigModelSubscriptionStatusCallback() {
        @Override
        public void onModelSubscriptionStatus(boolean timeout, ApplicationParameters.Status status, ApplicationParameters.Address address, ApplicationParameters.Address subAddress, ApplicationParameters.GenericModelID model) {
            UserApplication app = (UserApplication) getApplication();

            if (timeout) {
                hideProgressBar();
                UserApplication.trace("Retrying to subscribe group");
                Log.e("mSubscriptionListener", "subscription  timeout");
                switch (mAutoDevice.getDeviceType()) {
                    case 0:
                        sendAddGroupCommand();
                        break;
                    default:
                     /*   showAlert(ProvisionAddConfigurationActivity.this, "Connection Timeout!",
                                "Do you want to retry ?", "Retry", "Exit");*/
                        Log.i("log", "Incorrect Device Type");
                        break;

                }
            } else {
                if (status == ApplicationParameters.Status.SUCCESS) {
                    Log.e("mSubscriptionListener", "success subscription");
                    Log.i("MultiElement", " SUBSCRIPTION_SUCCESS_PROV for address " + address);

                    String address_str = Utils.getpublicationListAddressOnProvsioning(ProvisionAddConfigurationActivity.this);

                    if (address_str.startsWith("c") || address_str.startsWith("C")) {
                        app.mConfiguration.getNetwork().getSettings().setPublicationAddress(ProvisionAddConfigurationActivity.this, mAutoDevice.getAddress(), mAutoDevice.getAddress(), Integer.parseInt(Utils.getpublicationListAddressOnProvsioning(ProvisionAddConfigurationActivity.this), 16), mPublicationListener);

                    } else {
                        app.mConfiguration.getNetwork().getSettings().setPublicationAddress(ProvisionAddConfigurationActivity.this, mAutoDevice.getAddress(), mAutoDevice.getAddress(), Integer.parseInt(Utils.getpublicationListAddressOnProvsioning(ProvisionAddConfigurationActivity.this)), mPublicationListener);

                    }


                    app.mConfiguration.setPublication(String.valueOf(mAutoDevice.getAddress()), mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP).toString());
                    app.save();
                } else {
                    Utils.showToast(ProvisionAddConfigurationActivity.this,"Device has not been recognized");
                }


            }


        }
    };


    private final ConfigurationModelClient.ConfigModelPublicationStatusCallback mPublicationListener = new ConfigurationModelClient.ConfigModelPublicationStatusCallback() {

        @Override
        public void onModelPublicationStatus(boolean b, ApplicationParameters.Status status, ApplicationParameters.Address address,
                                             ApplicationParameters.Address address1, ApplicationParameters.KeyIndex keyIndex,
                                             ApplicationParameters.TTL ttl, ApplicationParameters.Time time,
                                             ApplicationParameters.GenericModelID genericModelID) {
            hideProgressBar();
            if (status == ApplicationParameters.Status.SUCCESS) {
                UserApplication app = (UserApplication) getApplication();
                Log.i("MultiElement", "PUBLISH_SUCCESS_PROV for address " + address);

                updateJsonData();
                Intent intent = new Intent();
                //  intent.putExtra("Device_Entry",mAutoDevice);
                setResult(RESULT_CODE, intent);
                finish();

            } else {
                Utils.showToast(ProvisionAddConfigurationActivity.this,"Unable to configure " + address + ". Please check if device powered and try again");
                sendMessage();
                UserApplication.trace("Unable to configure " + address);
                Log.i("publicationStatus", "PUBLISH_FAIL_PROV");
            }

        }
    };

    private boolean is_feature_available = false;
    ConfigurationModelClient.DeviceCompositionDataStatusCallback deviceCompositionDataStatus_callback =
            new ConfigurationModelClient.DeviceCompositionDataStatusCallback() {
                @Override
                public void onDeviceCompositionDataStatus(
                        boolean timeout,
                        ApplicationParameters.DeviceCompositionData block) {

                    if (timeout == true) {
                        Log.i("DeviceCompositionData", "Timeout");
                        is_feature_available = false;
                    } else {

                        loader.dismiss();
                        Collection<ApplicationParameters.DeviceCompositionDataElement> mElements;


                        Utils.DEBUG("mCID = " + block.getCompanyID());
                        Utils.DEBUG("mPID = " + block.getProductID());
                        Utils.DEBUG("mVID = " + block.getVersionID());
                        Utils.DEBUG("mCRPL = " + block.getReplayProtectionListSize());
                        Utils.DEBUG("Features = " + block.getFeatures());
                        MainActivity.mCid = block.getCompanyID()+"";
                        MainActivity.mPid = block.getProductID()+"";
                        MainActivity.mVid = block.getVersionID()+"";
                        MainActivity.mCrpl = block.getReplayProtectionListSize()+"";

                        int ff = block.getFeatures();


                        UserApplication.trace("deviceCompositionDataStatus_callback Features RELAY  = " + ((ff & 1) == 1)); // RELAY  = ((ff & 1) == 1
                        boolean is_node_relay = ((ff & 1) == 1);
                        ff >>= 1;
                        UserApplication.trace("deviceCompositionDataStatus_callback Features Proxy  = " + ((ff & 1) == 1)); // Proxy  = ((ff & 1) == 1
                        boolean is_node_proxy = ((ff & 1) == 1);
                        ff >>= 1;
                        boolean is_node_friend = ((ff & 1) == 1);
                        UserApplication.trace("deviceCompositionDataStatus_callback Features Friend  = " + ((ff & 1) == 1)); // Friend  = ((ff & 1) == 1
                        ff >>= 1;
                        boolean is_node_low_power = ((ff & 1) == 1);
                        UserApplication.trace("deviceCompositionDataStatus_callback Features Low Power  = " + ((ff & 1) == 1)); // Low Power  = ((ff & 1) == 1


                        Utils.setNodeFeatures(ProvisionAddConfigurationActivity.this, is_node_relay, is_node_proxy, is_node_friend, is_node_low_power);
                        is_feature_available = true;


                        mElements = block.getElements();

                        modelInfos.clear();

                        for (ApplicationParameters.DeviceCompositionDataElement e : mElements) {
                            int locaId = e.getLocationID();
                            Collection<ApplicationParameters.ModelID> sigMids = e.getModels();
                            for (ApplicationParameters.ModelID m : sigMids) {
                                UserApplication.trace("deviceCompositionDataStatus_callback SIG Model = " + m.toString());

                                ModelInfo modelInfo = new ModelInfo();
                                String[] split = m.toString().split(" ");
                                modelInfo.setModelName(split[0].replace("_"," "));
                                modelInfo.setModelID(split[1]);
                                modelInfos.add(modelInfo);

                            }

                            Collection<ApplicationParameters.VendorModelID> vMids = e.getVendorModels();
                            for (ApplicationParameters.VendorModelID v : vMids) {
                                UserApplication.trace("deviceCompositionDataStatus_callback Vendor Model = " + v.toString());
                                vendorModelPresent = true;
                                vendor_models.add(v.toString());

                                ModelInfo modelInfo = new ModelInfo();
                                String[] split = v.toString().split("[.]");
                                modelInfo.setModelName(getString(R.string.MODEL_SUB_NAME_VENDOR_MODEL));
                                modelInfo.setModelID(split[1]+split[0]);
                                modelInfos.add(modelInfo);

                                /*ModelInfo modelInfo = new ModelInfo();
                                modelInfo.setModelPresent(true);
                                modelInfo.setModelType(getString(R.string.MODEL_GROUP_NAME_VENDOR));
                                modelInfo.setModelData(vendor_models);
                                modelInfos.add(modelInfo);*/

                            }

                        }

                        ModelsData modelsData = new ModelsData();
                        modelsData.setModelInfos(modelInfos);
                        String str = ParseManager.getInstance().toJSON(modelsData);
                        Utils.saveModelInfo(ProvisionAddConfigurationActivity.this, str);
                        Utils.DEBUG("Model Info : " + Utils.getModelInfo(ProvisionAddConfigurationActivity.this));


                    }

                }
            };


    @Override
    protected void onDestroy() {
        super.onDestroy();
    }


    private void sendMessage() {
        Intent intent = new Intent(Utils.BROADCAST_MESSAGE);
        intent.putExtra("status", 500);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }


}
