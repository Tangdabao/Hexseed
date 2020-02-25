/**
 ******************************************************************************
 * @file    AddGroupActivity.java
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

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.InputType;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.ConfigurationModelClient;
import com.msi.moble.GenericLevelModelClient;
import com.msi.moble.mobleAddress;
import com.st.bluenrgmesh.adapter.ElementModelRecyclerAdapter;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.ProvisionedNodeSettingAdapter;
import com.st.bluenrgmesh.adapter.PublicationListAdapter;
import com.st.bluenrgmesh.adapter.group.PubGrpSettingAdapter;
import com.st.bluenrgmesh.adapter.SubListForGroupAdapter;
import com.st.bluenrgmesh.datamap.Nucleo;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Model;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.models.meshdata.Publish;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

public class AddGroupActivity extends AppCompatActivity {

    private EditText edtName;
    private EditText edtAddress;
    private LinearLayout laySubscription;
    private LinearLayout layPublication;
    private TextView txtSubscriptionLabel;
    private RecyclerView subscriptionRecycler;
    private RecyclerView publishingRecycler;
    private TextView txtMsg;
    private Button butRemoveNode;
    private List<Map<String, Object>> mData;
    private UserApplication app;
    private static String type;
    private String deviceAddress;
    private mobleAddress peerAddress;

    private ArrayList<Publish> elePublicationList = new ArrayList<>();
    private ArrayList<Element> eleListPub = new ArrayList<>();
    private ArrayList<Element> eleSubscriptionList = new ArrayList<>();
    private List<String> publicationList = new ArrayList<>();
    private List<String> publicationListName = new ArrayList<>();
    private List<String> subscriptionList = new ArrayList<>();
    private boolean update = false;
    private int count = 0;
    private mobleAddress groupAddress;
    GenericLevelModelClient mGenericLevelModel;
    ApplicationParameters.Time transitionTime = new ApplicationParameters.Time(10, ApplicationParameters.Time.Unit.UNIT_1SEC);
    ApplicationParameters.TID tid = new ApplicationParameters.TID(2);
    static final ApplicationParameters.Address TEST_M_ADDRESS = new ApplicationParameters.Address(2);
    private int mDimming;
    ApplicationParameters.Delay delay = new ApplicationParameters.Delay(5);

    private mobleAddress addr;
    private SubListForGroupAdapter subListForGroupAdapter;
    private ProvisionedNodeSettingAdapter publicationRecyclerAdapter;
    private int grpCount = 0;
    private CardView cvSeekBar;
    private SeekBar seekBar;
    private TextView txtIntensityValue;
    private CardView modelCardView;
    private MeshRootClass meshRootClass;
    private RecyclerView modelRecycler;
    private String elementUnicastAddress;
    private EditText edtElementName;
    private ArrayList<Model> models = new ArrayList<>();
    private ElementModelRecyclerAdapter modelRecyclerAdapter;
    private Model modelSelected;
    private PublicationListAdapter publicationListAdapter;
    private int selectedPosition;
    AppDialogLoader loader;
    private String grpName;
    private ArrayList<Nodes> nodeSubscriptionList;
    private String deviceM_address;
    private String selectedNodeName;
    private LinearLayout lytName;
    private LinearLayout lytAddress;
    private String new_groupAddress = "c000";
    private PubGrpSettingAdapter publicationGroupAdapter;
    private LinearLayout node_nameLL;
    private LinearLayout device_typeLL;
    private TextView heading_elementTV;
    private static final int STEP_INTERVAL = 10;
    //static SharedPreferences pref_model_selection;
    private String element_Add;
    private LinearLayout uuid_nameLL;
    private EditText uuidET;
    private TextView edtTV;
    private CardView cardView;
    private Switch switchProxy;
    private Switch switchRelay;
    private Switch switchFriend;
    private  TextView tvProxy;
    private TextView tvRelay;
    private  TextView tvFriend;
    private TextView tvLowPower;
    private ImageButton refreshProxy;
    private ImageButton refreshRelay;
    private ImageButton refreshFriend;
    private int LEVEL_MAX_LIMIT=32767;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")) {
            setContentView(R.layout.group_setting_new_activity);
        } else {
            setContentView(R.layout.activity_addgroup);
        }


        loader = AppDialogLoader.getLoader(AddGroupActivity.this);
        updateJsonData();
        initUi();
        if ((UserApplication) getApplication() != null) {

            if (((UserApplication) getApplication()).mConfiguration.getNetwork() != null) {
                mGenericLevelModel = ((UserApplication) getApplication()).mConfiguration.getNetwork().getLevelModel();
            }
        }
    }

    private void updateJsonData() {

        try {
            meshRootClass = ParseManager.getInstance().fromJSON(new JSONObject(Utils.getBLEMeshDataFromLocal(this)), MeshRootClass.class);
            Utils.DEBUG(">> Json Data : " + Utils.getBLEMeshDataFromLocal(AddGroupActivity.this));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {

        Utils.closeKeyboard(AddGroupActivity.this, edtName);

        boolean isChecked = false;
        for (int i = 0; i < eleSubscriptionList.size(); i++) {

            if (eleSubscriptionList.get(i).isChecked()) {
                isChecked = true;
            }
        }

        if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")
                && !"Default".equalsIgnoreCase(edtName.getText().toString())) {
            if (!isChecked) {
                //Utils.removeGroupFromJson(AddGroupActivity.this, addr);
                //Utils.removeGroupFromConfiguration(AddGroupActivity.this, addr);
            } else {
                if (edtName != null && !edtName.getText().toString().equalsIgnoreCase("")
                        && edtName.getText().toString() != null) {
                    Utils.updateGroupNameInJson(AddGroupActivity.this, meshRootClass, new_groupAddress, edtName.getText().toString());
                } else {
                    Utils.showToast(AddGroupActivity.this, "Please enter a valid Group Name!");
                    return;

                }
            }

        } else if (type.equals(getResources().getString(R.string.str_add_group))
                && !"Default".equalsIgnoreCase(edtName.getText().toString())) {

            if (!isChecked) {
                //Utils.removeGroupFromJson(AddGroupActivity.this, addr);
                //Utils.removeGroupFromConfiguration(AddGroupActivity.this, addr);
            } else {
                if (edtName != null && !edtName.getText().toString().equalsIgnoreCase("")
                        && edtName.getText().toString() != null) {
                    Utils.updateGroupNameInJson(AddGroupActivity.this, meshRootClass, new_groupAddress, edtName.getText().toString());
                } else {
                    Utils.showToast(AddGroupActivity.this, "Please enter a valid Group Name!");
                    return;

                }
            }

        }else if (type.equalsIgnoreCase(getResources().getString(R.string.str_device_setting))) {

            Utils.updateDeviceNameInJson(AddGroupActivity.this, meshRootClass, deviceAddress, edtName.getText().toString(), getResources().getBoolean(R.bool.bool_isElementFunctionality));
        }else if (type.equals(getResources().getString(R.string.str_element_setting))) {

            if(!"".equalsIgnoreCase(edtElementName.getText().toString())){
                //Utils.updateElementNameInJson(AddGroupActivity.this, edtElementName.getText().toString(), meshRootClass, elementUnicastAddress,  mobleAddress.deviceAddress(Integer.parseInt(deviceM_address, 16)) );
            }else {
                Toast.makeText(this,"Please enter a valid Element Name.",Toast.LENGTH_SHORT).show();
            }

        }

        if (loader.CheckLoaderStatus()) {
            loader.hide();
        }


        setResult(Activity.RESULT_OK);

        finish();
    }


    private void initUi() {

        lytName = (LinearLayout) findViewById(R.id.lytName);
        lytAddress = (LinearLayout) findViewById(R.id.lytAddress);
        cvSeekBar = (CardView) findViewById(R.id.cvSeekBar);
        modelCardView = (CardView) findViewById(R.id.modelCardView);
        modelRecycler = (RecyclerView) findViewById(R.id.modelRecycler);
        seekBar = (SeekBar) findViewById(R.id.seekBar);
        txtIntensityValue = (TextView) findViewById(R.id.txtIntensityValue);
        edtName = (EditText) findViewById(R.id.edtName);
        edtAddress = (EditText) findViewById(R.id.edtAddress);
        laySubscription = (LinearLayout) findViewById(R.id.laySubscription);
        layPublication = (LinearLayout) findViewById(R.id.layPublication);
        txtSubscriptionLabel = (TextView) findViewById(R.id.txtSubscriptionLabel);
        subscriptionRecycler = (RecyclerView) findViewById(R.id.subscriptionRecycler);
        publishingRecycler = (RecyclerView) findViewById(R.id.publishingRecycler);
        txtMsg = (TextView) findViewById(R.id.txtMsg);
        edtElementName = (EditText) findViewById(R.id.edtElementName);
        butRemoveNode = (Button) findViewById(R.id.butRemoveNode);
        node_nameLL = (LinearLayout) findViewById(R.id.node_nameLL);
        device_typeLL = (LinearLayout) findViewById(R.id.device_typeLL);
        heading_elementTV = (TextView) findViewById(R.id.heading_elementTV);
        edtTV = (TextView) findViewById(R.id.edtTV);
        uuid_nameLL = (LinearLayout) findViewById(R.id.uuid_nameLL);
        uuidET = (EditText) findViewById(R.id.uuidET);
        cardView=(CardView)findViewById(R.id.cardview_1);
        tvProxy=(TextView)findViewById(R.id.tvProxy);
        tvRelay=(TextView)findViewById(R.id.tvRelay);
        tvFriend=(TextView)findViewById(R.id.tvFriend);
        tvLowPower=(TextView)findViewById(R.id.tvLowPower);
        refreshProxy=(ImageButton) findViewById(R.id.refreshProxy);
        refreshRelay=(ImageButton) findViewById(R.id.refreshRelay);
        refreshFriend=(ImageButton) findViewById(R.id.refreshFriend);


        if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")) {
        }else{
            switchProxy = (Switch) findViewById(R.id.switchProxy);
            switchRelay = (Switch) findViewById(R.id.switchRelay);
            switchFriend = (Switch) findViewById(R.id.switchFriend);
        }
        onClickEvents();

        getSupportActionBar().setDefaultDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        mData = MainActivity.mData;
        app = (UserApplication) getApplication();
        Intent intent = getIntent();

        if (intent.getBooleanExtra("isElementSettings", false)) {

            type = getResources().getString(R.string.str_element_setting);
            initUI_isElementSettings(intent);
            if (!models.isEmpty()) {
                models.clear();
            }
            //update publishers and subscription data w.r.t this model
            models = Utils.getModelsForCurrentElement3(this, meshRootClass, String.valueOf(peerAddress), elementUnicastAddress);
            updateRecyclerForModels();

        } else if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")) {

            //Group Settings //default group
            update = true;
            type = getResources().getString(R.string.str_lights_group_settings);
            initUI_isLightsGroupSetting(intent);
            createGroupNew(type);
            cvSeekBar.setVisibility(View.VISIBLE);
            setAdapterForPublicationList();

        } else if (getIntent().getStringExtra("isAddNewGroup").equals("true")) {

            //Add New Group

            update = false;
            type = getResources().getString(R.string.str_add_group);
            initUI_isAddNewGroup(intent);
            createGroupNew(type);

        } else if (intent.hasExtra("address") && intent.hasExtra("device")) {
            update = true;
            if (intent.getBooleanExtra("device", false)) {
                type = getResources().getString(R.string.str_device_setting);
                initUI_isDeviceSettings(intent);

                //models = Utils.getModelsForCurrentElement2(this, meshRootClass, String.valueOf(peerAddress), String.valueOf(peerAddress));
                //updateJsonData();
                //updateRecyclerForModels();

            } else {
                type = getResources().getString(R.string.str_group_setting);
                initUI_isGroupSettings(intent);
                createGroupNew(type);
            }
        }
        if (mData == null) {
            return;
        }

        if ("Lights".equalsIgnoreCase(edtName.getText().toString())) {
            edtName.setEnabled(false);
            edtName.setFocusable(false);
            edtName.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
        } else {

            edtName.setEnabled(true);
            edtName.setFocusable(true);
        }
        checkForPRFLP(intent);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (type.equals("isLightsGroupSetting")) {
            menu.add(0, 0, 0, "Save").setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
        }

        if (type.equals("Device Settings")) {
            menu.add(0, 0, 0, "Save").setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);

        }
        if (type.equals(getResources().getString(R.string.str_element_setting))) {
            menu.add(0, 0, 0, "Save").setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);

        }


        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        loader.hide();
        updateJsonData();
        int id = item.getItemId();
        switch (id) {
            case android.R.id.home:

                if (type.equals(getResources().getString(R.string.str_add_group))) {
                    checkGrpHasSubElements();

                } else if (type.equals(getResources().getString(R.string.str_group_setting))) {
                    checkGrpHasSubElements();

                } else if (type.equals(getResources().getString(R.string.str_element_setting))) {
                    if(!"".equalsIgnoreCase(edtElementName.getText().toString())){
                        //Utils.updateElementNameInJson(AddGroupActivity.this, edtElementName.getText().toString(), meshRootClass, elementUnicastAddress,  mobleAddress.deviceAddress(Integer.parseInt(deviceM_address, 16)) );
                    }else {
                       Toast.makeText(this,"Please enter a valid Element Name.",Toast.LENGTH_SHORT).show();
                    }

                }else if (type.equalsIgnoreCase(getResources().getString(R.string.str_device_setting))) {

                    Utils.updateDeviceNameInJson(AddGroupActivity.this, meshRootClass, deviceAddress, edtName.getText().toString(), getResources().getBoolean(R.bool.bool_isElementFunctionality));
                }
                updateJsonData();
                setResult(Activity.RESULT_OK);
                finish();
                break;
            case 0:
                // Create or Save Group

                if (type.equalsIgnoreCase(getResources().getString(R.string.str_group_setting))) {
                    //groupAddress
                    Utils.updateGroupNameInJson(AddGroupActivity.this, meshRootClass, new_groupAddress, edtName.getText().toString());

                } else if (type.equalsIgnoreCase(getResources().getString(R.string.str_lights_group_settings))) {
                    //groupAddress
                    Utils.updateGroupNameInJson(AddGroupActivity.this, meshRootClass, new_groupAddress, edtName.getText().toString());
                    setResult(Activity.RESULT_OK);
                }
                else if (type.equalsIgnoreCase(getResources().getString(R.string.str_device_setting)))
                {
                    Utils.updateDeviceNameInJson(AddGroupActivity.this, meshRootClass, deviceAddress, edtName.getText().toString(), getResources().getBoolean(R.bool.bool_isElementFunctionality));

                } else if (type.equals(getResources().getString(R.string.str_element_setting))) {
                    if(!"".equalsIgnoreCase(edtElementName.getText().toString())){
                        Utils.updateElementNameInJson(AddGroupActivity.this, edtElementName.getText().toString(), meshRootClass, elementUnicastAddress,  mobleAddress.deviceAddress(Integer.parseInt(deviceM_address, 16)) );
                    }else {
                        Toast.makeText(this,"Please enter a valid Element Name.",Toast.LENGTH_SHORT).show();
                    }
                }
                finish();

                break;
            default:
                return super.onOptionsItemSelected(item);
        }

        return true;
    }


    private void createGroupNew(String type) {

        //for group only subscription data is mendetary
        updateJsonData();

        if (type.equalsIgnoreCase(getResources().getString(R.string.str_lights_group_settings))) {
            if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                eleSubscriptionList = getElementsListData();
                updateElementSubRecyclerForSubList();

            } else {
                /*nodeSubscriptionList = getNodesData_SubListOfGroup(getResources().getString(R.string.str_lights_group_settings), "c000");
                updateNodesSubRecycler();*/
            }

        } else if (type.equalsIgnoreCase(getResources().getString(R.string.str_group_setting))) {
            //groupAddress

            if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                eleSubscriptionList = getElementsListData();
                edtName.setText(getGroupName());//
                edtName.setSelection(edtName.getText().length());
                updateElementSubRecyclerForSubList();

            } else {
                if (addr == null) {
                    //grp setting
                    addr = groupAddress;
                }
                nodeSubscriptionList = getNodesData_SubListOfGroup(getResources().getString(R.string.str_group_setting), String.valueOf(groupAddress));
                //nodeSubscriptionList = getNodesData_SubListOfGroup(getResources().getString(R.string.str_group_setting), String.valueOf(groupAddress));
                updateNodesSubRecycler();
            }

        } else if (type.equalsIgnoreCase(getResources().getString(R.string.str_add_group))) {
            if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                count = getNextGroupCount(meshRootClass);
                addr = mobleAddress.groupAddress(mobleAddress.GROUP_HEADER + count);
                //int nextGrpAddress = Integer.parseInt(Utils.getProvisionerGroupLowAddressRange(AddGroupActivity.this)) + count;
                //addr = mobleAddress.groupAddress(nextGrpAddress);
                Utils.DEBUG("New Group Address : " + String.valueOf(addr));
                if (count > 9) {
                    showAlertForCount(count);

                } else {
                    grpName = "Group " + count;
                    eleSubscriptionList = getElementsListData();
                    edtName.setText(grpName);
                    edtName.setSelection(edtName.getText().length());
                    Utils.addNewGroupToJson(AddGroupActivity.this, addr, grpName); //remove if no elements are checked
                    updateJsonData();
                    updateElementSubRecyclerForSubList();
                }


            } else {

                count = getNextGroupCount(meshRootClass);
                addr = mobleAddress.groupAddress(mobleAddress.SUB_GROUP + count);
                app.save();//
                showAlertForCount(count);
                grpName = "Group " + count;
                //nodeSubscriptionList = getNodesData_SubListOfGroup(getResources().getString(R.string.str_add_group), String.valueOf(addr));
                nodeSubscriptionList = getNodesData();
                edtName.setText(grpName);
                edtName.setSelection(edtName.getText().length());
                Utils.addNewGroupToJson(AddGroupActivity.this, addr, grpName);
                updateJsonData();
                //updateElementSubRecyclerForSubList();
                updateNodesSubRecycler();
            }
        }
    }

    private ArrayList<Nodes> getNodesData() {

        ArrayList<Nodes> nodes = new ArrayList<>();
        for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
            nodes.add(meshRootClass.getNodes().get(i));
        }

        return nodes;
    }

    private void updateNodesSubRecycler() {

        if (nodeSubscriptionList.isEmpty())
            return;

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
        subscriptionRecycler.setLayoutManager(gridLayoutManager);
        subListForGroupAdapter = new SubListForGroupAdapter(AddGroupActivity.this, nodeSubscriptionList, eleSubscriptionList, new_groupAddress, type, meshRootClass, new SubListForGroupAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void onClickRecyclerItem(View v, int position, Element item, String mAutoAddress, boolean isChecked) {

            }

            @Override
            public void onClickNodeRecyclerItem(View v, int position, Nodes node, String mAutoAddress, boolean isChecked) {

                if (isChecked) {
                    //on checked
                    //int count = getCheckedElement();
                    int count = getCheckedNodes();
                    //int count = groupsInfo(mAutoAddress);
                    UserApplication.trace("count " + count);
                    if (count <= 10) {
                        loader.show();
                        try {
                            selectedPosition = position;
                            Utils.contextU = AddGroupActivity.this;
                            if (nodeSubscriptionList.get(position).isChecked()) {

                                Utils.removeDeviceFromGroup(AddGroupActivity.this, addr, mAutoAddress, node.getM_address());
                            } else {

                                Utils.addDeviceToGroup(AddGroupActivity.this, addr, mAutoAddress, node.getM_address());
                            }

                        } catch (Exception e) {
                            loader.hide();
                        }

                    } else {
                        //show maximum count status
                        Toast.makeText(AddGroupActivity.this, "Maximum 10 elements limit for subscription.", Toast.LENGTH_SHORT).show();
                    }
                }


            }
        });
        subscriptionRecycler.setAdapter(subListForGroupAdapter);
        Utils.calculateHeight(nodeSubscriptionList.size(), subscriptionRecycler);

    }

    private int getCheckedNodes() {

        int count = 0;
        for (Nodes node : nodeSubscriptionList) {


            if (node.isChecked()) {
                count++;
            }
        }

        return count;
    }

    private ArrayList<Nodes> getNodesData_SubListOfGroup(String type, String grpAddres) {
        ArrayList<Nodes> nodes = new ArrayList<>();

        try {
            for (int i = 0; i < meshRootClass.getGroups().size(); i++) {

                if (meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase(grpAddres)) {
                    edtName.setText(String.valueOf(meshRootClass.getGroups().get(i).getName()) + "");
                    edtName.setSelection(edtName.getText().length());

                }
            }

        } catch (Exception e) {
        }
        return nodes;
    }

    private String getGroupName() {
        String name = "";

        for (int i = 0; i < meshRootClass.getGroups().size(); i++) {


            if (meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase(String.valueOf(groupAddress))) {
                name = meshRootClass.getGroups().get(i).getName();
            }

        }
        return name;
    }


    private void updateElementSubRecyclerForSubList() {

        if (eleSubscriptionList.isEmpty())
            return;

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
        subscriptionRecycler.setLayoutManager(gridLayoutManager);
        subListForGroupAdapter = new SubListForGroupAdapter(AddGroupActivity.this, nodeSubscriptionList, eleSubscriptionList, new_groupAddress, type, meshRootClass, new SubListForGroupAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void onClickRecyclerItem(View v, int position, Element item, String mAutoAddress, boolean isChecked) {

                Utils.DEBUG("DEBUG Clicked >> Subscription : " + " address : " + mAutoAddress + " subaddrss : " + item.getUnicastAddress());

                if (isChecked) {
                    //on checked
                    int count = getCheckedElement();
                    //int count = groupsInfo(mAutoAddress);
                    UserApplication.trace("count " + count);
                    if (count <= 10) {
                        loader.show();
                        try {
                            selectedPosition = position;
                            Utils.contextU = AddGroupActivity.this;
                            if (eleSubscriptionList.get(position).isChecked()) {
                                //Utils.removeElementFromGroup(AddGroupActivity.this, addr, mAutoAddress, item);
                                Utils.removeElementFromGroup(AddGroupActivity.this, addr, mAutoAddress, item);
                            } else {
                                //Utils.addElementToGroup(AddGroupActivity.this, addr, mAutoAddress, item);
                                Utils.addElementToGroup(AddGroupActivity.this, addr, mAutoAddress, item);
                            }

                        } catch (Exception e) {
                            loader.hide();
                        }

                    } else {
                        //show maximum count status
                        Toast.makeText(AddGroupActivity.this, "Maximum 10 elements limit for subscription.", Toast.LENGTH_SHORT).show();
                    }
                }
            }

            @Override
            public void onClickNodeRecyclerItem(View v, int position, Nodes node, String address, boolean b) {

            }
        });
        subscriptionRecycler.setAdapter(subListForGroupAdapter);
        Utils.calculateHeight(eleSubscriptionList.size(), subscriptionRecycler);

    }

    private void showAlertForCount(int count) {

        if (count > 9) {
            AlertDialog.Builder alert = new AlertDialog.Builder(this);
            alert.setCancelable(false);
            alert.setMessage("You can create maximum 10 groups");
            alert.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int whichButton) {
                    finish();
                }
            });
            alert.show();

        } else {
            return;
        }

    }

    private ArrayList<Element> getElementsListData() {

        eleSubscriptionList.clear();

        if (type.equalsIgnoreCase(getResources().getString(R.string.str_add_group))) {
            try {
                for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
                    boolean isNodeIsProvisioner = false;
                    for (int j = 0; j < meshRootClass.getProvisioners().size(); j++) {
                        if (meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(meshRootClass.getProvisioners().get(j).getUUID())) {
                            isNodeIsProvisioner = true;
                            break;
                        }
                    }

                    if (!isNodeIsProvisioner) {
                        for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                            Element element = meshRootClass.getNodes().get(i).getElements().get(j);
                            element.setChecked(false);
                            element.setParentNodeAddress(meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress());
                            element.setParentNodeName(meshRootClass.getNodes().get(i).getName());
                            eleSubscriptionList.add(element);
                        }
                    }
                }

            } catch (Exception e) {
                Utils.DEBUG(">> Method Error : getElementsListData()");
            }

        } /*else if (type.equalsIgnoreCase(getResources().getString(R.string.str_group_setting))) {
            //groupAddress
            try {
                for (int i = 0; i < meshRootClass.getGroups().size(); i++) {
                    if (meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase(String.valueOf(groupAddress))) {
                        if (!meshRootClass.getGroups().get(i).getElements().isEmpty()) {
                            for (int j = 0; j < meshRootClass.getGroups().get(i).getElements().size(); j++) {
                                eleSubscriptionList.add(meshRootClass.getGroups().get(i).getElements().get(j));
                            }
                        }
                    }
                }

            } catch (Exception e) {
                Utils.DEBUG(">> Method Error : getElementsListData()");
            }

        }*/ else if (type.equalsIgnoreCase(getResources().getString(R.string.str_lights_group_settings))) {
            try {
                if ("c000".equalsIgnoreCase(new_groupAddress)) {
                    for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                        boolean isNodeIsProvisioner = false;
                        for (int j = 0; j < meshRootClass.getProvisioners().size(); j++) {
                            if (meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(meshRootClass.getProvisioners().get(j).getUUID())) {
                                isNodeIsProvisioner = true;
                                break;
                            }
                        }

                        if (!isNodeIsProvisioner) {
                            for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                                Element element = meshRootClass.getNodes().get(i).getElements().get(j);
                                element.setChecked(true);
                                eleSubscriptionList.add(element);
                            }
                        }
                    }
                } else {
                    // According to note 1
                    for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                        boolean isNodeIsProvisioner = false;
                        for (int j = 0; j < meshRootClass.getProvisioners().size(); j++) {
                            if (meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(meshRootClass.getProvisioners().get(j).getUUID())) {
                                isNodeIsProvisioner = true;
                                break;
                            }
                        }

                        if (!isNodeIsProvisioner) {
                            for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {

                                Element element = meshRootClass.getNodes().get(i).getElements().get(j);
                                element.setParentNodeAddress(meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress());
                                boolean isGroupIsPresent_Element = Utils.isGroupIsPresentInElement(element, new_groupAddress);

                                if (isGroupIsPresent_Element) {
                                    element.setChecked(true);
                                } else {
                                    element.setChecked(false);
                                }
                                eleSubscriptionList.add(element);
                            }
                        }
                    }
                    /*for (int i = 0; i < meshRootClass.getGroups().size(); i++) {
                        if (meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase(String.valueOf(new_groupAddress))) {
                            if (!meshRootClass.getGroups().get(i).getElements().isEmpty()) {
                                for (int j = 0; j < meshRootClass.getGroups().get(i).getElements().size(); j++) {
                                    eleSubscriptionList.add(meshRootClass.getGroups().get(i).getElements().get(j));
                                }
                            }
                        }
                    }*/
                }

            } catch (Exception e) {
                Utils.DEBUG(">> Method Error : getElementsListData()");
            }
        }

        return eleSubscriptionList;
    }

    private int getNextGroupCount(MeshRootClass messRootClass) {

        int count = 0;

        try {

            for (int i = 0; i < messRootClass.getGroups().size(); i++) {
                count++;
            }

        } catch (Exception e) {

        }

        return count;
    }

    private int getCheckedElement() {
        count = 0;
        for (Element eleemnt : eleSubscriptionList) {

            if (eleemnt.isChecked()) {
                count++;
            }
        }

        return count;
    }
    public final ConfigurationModelClient.ConfigProxyStatusCallback mProxyStatusCallback = new ConfigurationModelClient.ConfigProxyStatusCallback() {


        @Override
        public void onProxyStatus(boolean Timeoutstatus , ApplicationParameters.Proxy state) {

            if (Timeoutstatus) {
                UserApplication.trace("Proxy Status : fail");

            } else {
              if(state== ApplicationParameters.Proxy.RUNNING)
              {
                  switchProxy.setChecked(true);
              }
              else{
                  switchProxy.setChecked(false);
              }


            }
        }
    };


    ConfigurationModelClient.ConfigRelayStatusCallback mConfigRelayStatusCallback = new ConfigurationModelClient.ConfigRelayStatusCallback() {
        @Override
        public void onRelayStatus(boolean timeout, ApplicationParameters.Relay relay, ApplicationParameters.RelayRetransmitCount relayRetransmitCount, ApplicationParameters.RelayRetransmitIntervalSteps relayRetransmitIntervalSteps) {
            if (timeout) {
                UserApplication.trace(" Relay Status :fail");

            } else {
                UserApplication.trace(" Relay Status :fail" + relayRetransmitCount + " " + relayRetransmitIntervalSteps);

                if(relay== ApplicationParameters.Relay.RELAYING){
                    switchRelay.setChecked(true);
                }
                else {
                    switchRelay.setChecked(false);
                }

            }
        }
    };

    ConfigurationModelClient.ConfigFriendStatusCallback mConfigFriendStatusCallback = new ConfigurationModelClient.ConfigFriendStatusCallback() {
        @Override
        public void onFriendStatus(boolean b, ApplicationParameters.Friend friend) {
            if (b) {
                UserApplication.trace(" Friend Status : fail");

            } else {
                if(friend== ApplicationParameters.Friend.RUNNING){
                    switchFriend.setChecked(true);
                }
                else{
                    switchFriend.setChecked(false);
                }

            }
        }
    };


    private final GenericLevelModelClient.GenericLevelStatusCallback mLevelCallback = new GenericLevelModelClient.GenericLevelStatusCallback() {
        @Override
        public void onLevelStatus(boolean timeout,
                                  ApplicationParameters.Level level,
                                  ApplicationParameters.Level targetLevel,
                                  ApplicationParameters.Time remainingTime) {
            if (timeout) {
                UserApplication.trace("Generic Level Timeout");
            } else {
                UserApplication.trace("Generic Level status = SUCCESS ");

                UserApplication.trace("Generic Level current Level = " + level);
                UserApplication.trace("Generic Level Target Level = " + targetLevel);
                mDimming = level.getValue();
                UserApplication.trace("Level is " + Integer.toString(level.getValue()));
            }
        }
    };

    private void onClickEvents() {

        butRemoveNode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                //button used for addition of group and removing of node and group
                doEventsFor_butRemoveNode();

            }
        });

      //  seekBar.setMax(5);

        if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")) {
        }else {
            switchProxy.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (switchProxy.isChecked()) {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setProxy(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Proxy.RUNNING, mProxyStatusCallback);
                    } else {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setProxy(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Proxy.NOT_RUNNING, mProxyStatusCallback);
                    }
                }

            });
            switchRelay.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (switchRelay.isChecked()) {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setRelay(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Relay.RELAYING, ApplicationParameters.RelayRetransmitCount.DEFAULT, ApplicationParameters.RelayRetransmitIntervalSteps.DEFAULT, mConfigRelayStatusCallback);
                    } else {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setRelay(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Relay.NOT_RELAYING, ApplicationParameters.RelayRetransmitCount.DEFAULT, ApplicationParameters.RelayRetransmitIntervalSteps.DEFAULT, mConfigRelayStatusCallback);
                    }
                }
            });
            switchFriend.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (switchFriend.isChecked()) {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setFriend(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Friend.RUNNING, mConfigFriendStatusCallback);

                    } else {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().setFriend(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), ApplicationParameters.Friend.STOPPED, mConfigFriendStatusCallback);

                    }
                }

            });

            refreshProxy.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().getProxy(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), mProxyStatusCallback);
                }
            });

            refreshRelay.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().getRelay(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), mConfigRelayStatusCallback);
                }
            });

            refreshFriend.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().getFriend(new ApplicationParameters.Address(Integer.parseInt(deviceM_address, 16)), mConfigFriendStatusCallback);
                }
            });
        }

        seekBar.setMax(LEVEL_MAX_LIMIT);
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

             /*   String seekbarValue = String.valueOf(progress);


                int intAddress = Integer.parseInt(edtAddress.getText().toString(), 16);

                Utils.contextU = AddGroupActivity.this;

                pref_model_selection = Utils.contextU.getSharedPreferences("Model_Selection", MODE_PRIVATE);

                if (pref_model_selection.getBoolean("Selected_Model", false)) {

                    mobleAddress address = null;
                    if (Utils.isUnicastAddress(intAddress)) {
                        address = mobleAddress.deviceAddress(intAddress);
                        UserApplication.trace("NavBar Vendor device SeekBar Value Vendor Model = " + (progress * 20));

                    } else {
                        UserApplication.trace("NavBar Vendor group SeekBar Value Vendor Model = " + (progress * 20));

                        address = mobleAddress.groupAddress(intAddress);

                    }
                    ((UserApplication) getApplication()).mConfiguration.getNetwork().getApplication().setRemoteData(address, Nucleo.APPLI_CMD_LED_TOGGLE, 1, new byte[]{}, false);
                    txtIntensityValue.setText(seekbarValue);

                } else {
                    ApplicationParameters.Address elementAddress = new ApplicationParameters.Address(Integer.parseInt(edtAddress.getText().toString(), 16));
                    UserApplication.trace("NavBar SeekBar Value Generic Model = " + (progress * 20));

                    ApplicationParameters.Level level = new ApplicationParameters.Level((progress * 20));
                    if (((UserApplication) getApplication()).mConfiguration.getNetwork() != null) {
                        mGenericLevelModel = ((UserApplication) getApplication()).mConfiguration.getNetwork().getLevelModel();
                    }
                    mGenericLevelModel.setGenericLevel(true,
                            elementAddress,
                            level,
                            tid,
                            null,
                            null,
                            mLevelCallback);

                    txtIntensityValue.setText(seekbarValue);

                }*/
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

                String seekbarValue = String.valueOf(seekBar.getProgress());
                int progress = seekBar.getProgress();
                int intAddress = Integer.parseInt(edtAddress.getText().toString(), 16);
                Utils.contextU = AddGroupActivity.this;

                //pref_model_selection = Utils.contextU.getSharedPreferences("Model_Selection", MODE_PRIVATE);

                if (Utils.isVendorModelCommand(AddGroupActivity.this)) {

                    mobleAddress address = null;
                    if (Utils.isUnicastAddress(intAddress)) {
                        address = mobleAddress.deviceAddress(intAddress);
                        UserApplication.trace("NavBar Vendor device SeekBar Value Vendor Model = " + (progress));

                    } else {
                        UserApplication.trace("NavBar Vendor group SeekBar Value Vendor Model = " + (progress));
                        address = mobleAddress.groupAddress(intAddress);
                    }

                    ((UserApplication) getApplication()).mConfiguration.getNetwork().getApplication().setRemoteData(address, Nucleo.APPLI_CMD_LED_TOGGLE, 1, new byte[]{(byte)Nucleo.APPLI_CMD_LED_INTENSITY,(byte) (progress & 0xFF),(byte) ((progress >> 8) & 0xFF)}, false);
                    txtIntensityValue.setText(((progress * 100) / LEVEL_MAX_LIMIT) + " %");

                } else {
                    ApplicationParameters.Address elementAddress = new ApplicationParameters.Address(Integer.parseInt(edtAddress.getText().toString(), 16));
                    UserApplication.trace("NavBar SeekBar Value Generic Model = " + (progress));
                    ApplicationParameters.Level level = new ApplicationParameters.Level((progress));
                    if (((UserApplication) getApplication()).mConfiguration.getNetwork() != null) {
                        mGenericLevelModel = ((UserApplication) getApplication()).mConfiguration.getNetwork().getLevelModel();
                    }
                    mGenericLevelModel.setGenericLevel(true,
                            elementAddress,
                            level,
                            tid,
                            null,
                            null,
                            mLevelCallback);

                    // txtIntensityValue.setText(seekbarValue);
                    txtIntensityValue.setText(((progress * 100) / LEVEL_MAX_LIMIT) + " %");
                }
            }
        });

    }

    public ConfigurationModelClient.NodeResetStatusCallback mNodeResetCallback = new ConfigurationModelClient.NodeResetStatusCallback() {


        @Override
        public void onNodeResetStatus(boolean Timeoutstatus) {

            if (Timeoutstatus == true) {
                loader.hide();
                UserApplication.trace("Node unprovisioned Failed");
                Toast.makeText(AddGroupActivity.this, "Unprovisioned Failed", Toast.LENGTH_LONG).show();


            } else {
                UserApplication.trace("Node unprovisioned Successfully");
                Toast.makeText(AddGroupActivity.this, "Unprovisioned Done", Toast.LENGTH_LONG).show();
                Utils.removeProvisionNodeFromJson(AddGroupActivity.this, deviceM_address);
                loader.hide();
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {

                        //refresh list of unprovision devices in main activity

                        setResult(Activity.RESULT_OK);
                        finish();
                    }
                }, 600);

            }
        }
    };

    private void doEventsFor_butRemoveNode() {
        if (type.equals(getResources().getString(R.string.str_add_group))) {
            checkGrpHasSubElements();
            setResult(Activity.RESULT_OK);
            finish();
        } else if (type.equals("Device Settings")) {
            AlertDialog.Builder builder1 = new AlertDialog.Builder(AddGroupActivity.this);
            builder1.setMessage("This action will unprovision the node from the network. Do you want to continue?");
            builder1.setCancelable(true);

            builder1.setPositiveButton("YES", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {



                    if (/*!g_model*/false) {
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getApplication().setRemoteData(peerAddress, Nucleo.UNCONFIGURE, 1, new byte[]{}, false);

                    } else {
                        UserApplication.trace("NODE unprovisioning from AddGroup _ 1 addr " + peerAddress);

                        loader.show();
                        ((UserApplication) getApplication()).mConfiguration.getNetwork().getConfigurationModelClient().resetNode(new ApplicationParameters.Address(peerAddress.mValue), mNodeResetCallback);
                    }

                    ((UserApplication) getApplication()).save();

                    dialog.cancel();
                }
            });

            builder1.setNegativeButton("NO", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {

                    dialog.cancel();

                }
            });

            AlertDialog alert11 = builder1.create();
            alert11.show();

            // createDialog();
        } else if (type.equals("Group Settings")) {

            checkGrpHasSubElements();


        } else if (getResources().getString(R.string.str_lights_group_settings).equalsIgnoreCase(type)) {

            //group settings
            checkGrpHasSubElements();
        }

    }

    private void checkGrpHasSubElements() {

        boolean isChecked = false;
        for (int i = 0; i < eleSubscriptionList.size(); i++) {

            if (eleSubscriptionList.get(i).isChecked()) {
                isChecked = true;
            }
        }


        AlertDialog.Builder builder1 = new AlertDialog.Builder(AddGroupActivity.this);
        if (isChecked) {

            builder1.setMessage("group can't be deleted with one or more than one publisher and subscriber configured.");
            builder1.setCancelable(true);
            builder1.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {

                    dialog.cancel();
                }
            });


        } else {

            builder1.setMessage("Please note that this action will remove this group permanently. Continue ?");
            builder1.setCancelable(true);
            builder1.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {

                    Utils.removeGroupFromJson(AddGroupActivity.this, addr);
                    dialog.cancel();
                    setResult(Activity.RESULT_OK);
                    finish();
                }
            });

            builder1.setNegativeButton("NO", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {

                    dialog.cancel();

                }
            });

        }

        if (type.equals(getResources().getString(R.string.str_add_group))) {
            if (!isChecked) {
                Utils.removeGroupFromJson(AddGroupActivity.this, addr);
            }

        } else {
            AlertDialog alert11 = builder1.create();
            alert11.show();
        }

    }

    private void initUI_isElementSettings(Intent intent) {

        deviceAddress = intent.getStringExtra("address");
        deviceM_address = intent.getStringExtra("m_address");
        elementUnicastAddress = intent.getStringExtra("elementUnicastAddress");
        setTitle(type);

        lytAddress.setVisibility(View.VISIBLE);
        lytName.setVisibility(View.VISIBLE);
        edtName.setText("");
        ;
        edtName.setVisibility(View.VISIBLE);
        edtName.setInputType(InputType.TYPE_NULL);
        edtAddress.setInputType(InputType.TYPE_NULL);
        laySubscription.setVisibility(View.VISIBLE);
        txtSubscriptionLabel.setText("Subscription Address");
        layPublication.setVisibility(View.VISIBLE);
        butRemoveNode.setVisibility(View.GONE);
        butRemoveNode.setText("Save Settings");
        txtMsg.setVisibility(View.GONE);
        cvSeekBar.setVisibility(View.GONE);
        modelCardView.setVisibility(View.GONE);
        node_nameLL.setVisibility(View.GONE);
        uuid_nameLL.setVisibility(View.GONE);
        device_typeLL.setVisibility(View.VISIBLE);
        heading_elementTV.setVisibility(View.VISIBLE);

        if (type.equalsIgnoreCase(getResources().getString(R.string.str_element_setting))) {
            peerAddress = mobleAddress.deviceAddress(Integer.parseInt(deviceM_address, 16));
            for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                if (meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress().equalsIgnoreCase(deviceM_address)) {
                    for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {

                        if (meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress().equalsIgnoreCase(elementUnicastAddress)) {
                            edtElementName.setText(meshRootClass.getNodes().get(i).getElements().get(j).getName());
                            edtElementName.setSelection(edtElementName.getText().length());
                        }
                    }

                    edtName.setText(meshRootClass.getNodes().get(i).getName());
                    edtName.setSelection(edtName.getText().length());
                    selectedNodeName = meshRootClass.getNodes().get(i).getName();
                }
            }

            edtAddress.setText(elementUnicastAddress);

        } else {
            for (int i = 0; i < mData.size(); i++) {
                if (mData.get(i).containsKey("address")) {
                    if (mData.get(i).get("address").equals(deviceAddress))
                        peerAddress = (mobleAddress) mData.get(i).get("m_address");
                }
            }
        }

        try {
            if (app.mConfiguration.getDevice(deviceAddress).getName() != null)
                edtName.setText(app.mConfiguration.getDevice(deviceAddress).getName());
            edtName.setSelection(edtName.getText().length());
        } catch (Exception e) {
        }
    }

    @Override
    protected void onDestroy() {

        if (type.equals("Add Group")) {

            try {
                Collection<String> devices = app.mConfiguration.getGroup(addr).getDevices();
                if (devices.size() == 0) {
                    count--;
                    app.mConfiguration.removeGroup(addr);
                    ((UserApplication) getApplication()).mConfiguration.setPublication(String.valueOf(peerAddress), "c000");
                    //((UserApplication) getApplication()).mConfiguration.getPublication()
                } else {
                    Utils.addGroupNameToConfiguration(AddGroupActivity.this, addr, edtName.getText().toString());
                    setResult(Activity.RESULT_OK);
                }
            } catch (Exception e) {
            }
        }

        super.onDestroy();
    }

    private void initUI_isGroupSettings(Intent intent) {


        setTitle(getResources().getString(R.string.str_group_setting));
        edtName.setText(getIntent().getStringExtra("group_name"));
        edtName.setSelection(edtName.getText().length());
        edtAddress.setInputType(InputType.TYPE_NULL);
        laySubscription.setVisibility(View.VISIBLE);
        layPublication.setVisibility(View.VISIBLE);
        txtMsg.setVisibility(View.GONE);
        butRemoveNode.setVisibility(View.VISIBLE);
        cvSeekBar.setVisibility(View.VISIBLE);
        modelCardView.setVisibility(View.GONE);
        edtElementName.setVisibility(View.GONE);
        edtAddress.setVisibility(View.VISIBLE);

        edtAddress.setText(getIntent().getStringExtra("group_address"));

    }

    private void initUI_isDeviceSettings(Intent intent) {
        setTitle("Node Settings");
        deviceAddress = intent.getStringExtra("address");
        deviceM_address = intent.getStringExtra("m_address");
        lytAddress.setVisibility(View.GONE);
        lytName.setVisibility(View.GONE);
        laySubscription.setVisibility(View.GONE);
        layPublication.setVisibility(View.GONE);
        butRemoveNode.setVisibility(View.VISIBLE);
        edtName.setVisibility(View.VISIBLE);
        cardView.setVisibility(View.VISIBLE);
        txtMsg.setVisibility(View.GONE);
        edtAddress.setVisibility(View.GONE);
        butRemoveNode.setText(getResources().getString(R.string.remove_node));
        cvSeekBar.setVisibility(View.GONE);
        modelCardView.setVisibility(View.GONE);
        edtElementName.setVisibility(View.GONE);
        node_nameLL.setVisibility(View.VISIBLE);
        uuid_nameLL.setVisibility(View.VISIBLE);
        device_typeLL.setVisibility(View.GONE);
        heading_elementTV.setVisibility(View.GONE);
        uuidET.setText(intent.getStringExtra("UUID"));
        peerAddress = mobleAddress.deviceAddress(Integer.parseInt(deviceM_address, 16));
        try {

            for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                if (meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress().equalsIgnoreCase(deviceM_address)) {
                    edtName.setText(meshRootClass.getNodes().get(i).getName());
                    edtName.setSelection(edtName.getText().length());
                }
            }


        } catch (Exception e) {
        }

    }

    private void checkForPRFLP(Intent intent) {
        if(switchProxy!=null&tvProxy!=null) {
            if (intent.getBooleanExtra("isProxy", false)) {
                switchProxy.setVisibility(View.VISIBLE);
                refreshProxy.setVisibility(View.VISIBLE);
            } else {
                tvProxy.setVisibility(View.VISIBLE);
            }
            if (intent.getBooleanExtra("isRelay", false)) {
                switchRelay.setVisibility(View.VISIBLE);
                refreshRelay.setVisibility(View.VISIBLE);
            } else {
                tvRelay.setVisibility(View.VISIBLE);
            }
            if (intent.getBooleanExtra("isFriend", false)) {
                switchFriend.setVisibility(View.VISIBLE);
                refreshFriend.setVisibility(View.VISIBLE);
            } else {
                tvFriend.setVisibility(View.VISIBLE);
            }
            if (intent.getBooleanExtra("isLowPower", false)) {
               tvLowPower.setText("Supported");
            } else {
                tvLowPower.setText("Not Supported");
            }
        }
    }

    private void initUI_isAddNewGroup(Intent intent) {

        laySubscription.setVisibility(View.VISIBLE);
        layPublication.setVisibility(View.GONE);
        butRemoveNode.setVisibility(View.VISIBLE);
        butRemoveNode.setText(getResources().getString(R.string.add_group));
        butRemoveNode.setTextColor(this.getResources().getColor(R.color.ST_BLUE_DARK));
        cvSeekBar.setVisibility(View.GONE);
        modelCardView.setVisibility(View.GONE);
        edtElementName.setVisibility(View.GONE);
        lytName.setVisibility(View.GONE);
        lytAddress.setVisibility(View.GONE);
        node_nameLL.setVisibility(View.VISIBLE);
        uuid_nameLL.setVisibility(View.GONE);
        device_typeLL.setVisibility(View.GONE);
        heading_elementTV.setVisibility(View.GONE);
        edtTV.setText("Name");
        setTitle(getResources().getString(R.string.add_group));


    }

    private void initUI_isLightsGroupSetting(Intent intent) {

        setTitle(getResources().getString(R.string.str_group_setting));
        edtName.setText(getIntent().getStringExtra("group_name"));
        edtName.setSelection(edtName.getText().length());
        // edtName.setInputType(InputType.TYPE_NULL);
        edtAddress.setInputType(InputType.TYPE_NULL);
        laySubscription.setVisibility(View.VISIBLE);
        // txtSubscriptionLabel.setText("Subscription Address");
        layPublication.setVisibility(View.VISIBLE);
        txtMsg.setVisibility(View.GONE);
        butRemoveNode.setText(getString(R.string.str_remove_group));
        butRemoveNode.setVisibility(View.VISIBLE);
        cvSeekBar.setVisibility(View.VISIBLE);
        modelCardView.setVisibility(View.GONE);
        edtElementName.setVisibility(View.GONE);
        edtAddress.setVisibility(View.VISIBLE);
        new_groupAddress = getIntent().getStringExtra("group_address");
        edtAddress.setText(new_groupAddress);

        groupAddress = mobleAddress.groupAddress((intent.getShortExtra("address", (short) 0)) & 0xFFFF);
        addr = groupAddress;


    }

    public int getNextGroupCount(mobleAddress addr, int count) {
        int countN = 0;
        if (isGroupAlreadyExist(addr, count)) {
            /*count++;*/
            count++;
            addr = mobleAddress.groupAddress(mobleAddress.SUB_GROUP + count);
            getNextGroupCount(addr, count);
        }

        if (this.grpCount == 0) {
            this.grpCount = count;
        }


        return count;

    }

    private boolean isGroupAlreadyExist(mobleAddress addr, int count) {

        int coun = count;

        if (addr == null)
            return false;

        for (int i = 0; i < mData.size(); i++) {
            try {

                if (mData.get(i).get("m_address").toString().equalsIgnoreCase(addr.toString())) {
                    if (mData.get(i).get("title").equals("Group " + count + addr) || mData.get(i).get("title").equals("Group " + count)) {
                        //Toast.makeText(AddGroupActivity.this, "Group is already exist with this name", Toast.LENGTH_SHORT).show();
                        return true;
                    }
                    return true;
                }
            } catch (Exception e) {
                return false;
            }

        }
        return false;
    }

    void setSubscription() {

        subscriptionList.clear();
        if (type.equalsIgnoreCase(getResources().getString(R.string.str_element_setting))) {

            try {

                List<String> subscriptionData = new ArrayList<>();

                for (int l = 0; l < modelSelected.getSubscribe().size(); l++) {

                    if ("Default".equalsIgnoreCase(String.valueOf(modelSelected.getSubscribe().get(l)))) {
                        subscriptionData.add("c000");
                    } else {
                        subscriptionData.add(String.valueOf(modelSelected.getSubscribe().get(l)));
                    }

                }

                HashSet<String> hs = new HashSet<>();    // Remove duplicate Items from the list
                hs.addAll(subscriptionData);
                subscriptionData.clear();
                subscriptionData.addAll(hs);

                for (int i = 0; i < meshRootClass.getGroups().size(); i++) {

                    for (int j = 0; j < subscriptionData.size(); j++) {
                        if (meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase(subscriptionData.get(j))) {
                            subscriptionList.add(meshRootClass.getGroups().get(i).getName() + " : " + meshRootClass.getGroups().get(i).getAddress());
                        }
                    }

                }

            } catch (Exception e) {
            }

        } else {
            /*for (int i = 0; i < subGroupsList.size(); i++) {
                if (Utils.searchDevice(AddGroupActivity.this, (mobleAddress) subGroupsList.get(i).get("m_address"), deviceAddress))
                    subscriptionList.add(String.valueOf(subGroupsList.get(i).get("title")));

            }*/

            try {
                for (int l = 0; l < modelSelected.getSubscribe().size(); l++) {
                    subscriptionList.add(String.valueOf(modelSelected.getSubscribe().get(l)));
                }
            } catch (Exception e) {
            }
        }

        if (subscriptionList.isEmpty()) {

            txtMsg.setVisibility(View.VISIBLE);
            txtMsg.setText("Device is not part of any group yet");
            if (getIntent().getStringExtra("isLightsGroupSetting").equals("true")) {
                txtMsg.setVisibility(View.GONE);
            }

        } else {
            initRecyclerAdapter(AddGroupActivity.this, subscriptionList, null, null, addr, type);
        }

    }

    public void updateRecyclerForPublishers() {
        if (elePublicationList.isEmpty()) {
            return;
        }
        //String pa = ((UserApplication) getApplication()).mConfiguration.getPublication(String.valueOf(peerAddress));
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
        publishingRecycler.setLayoutManager(gridLayoutManager);

        publicationListAdapter = new PublicationListAdapter(AddGroupActivity.this, elePublicationList, String.valueOf(peerAddress), type, meshRootClass, new PublicationListAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void onClickRecyclerItem(View view, Publish item, String mAutoAddress, boolean isSelected, int position) {
                if (isSelected) {
                    selectedPosition = position;

                    if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                        Utils.DEBUG("" + peerAddress + " elem" + elementUnicastAddress + " " + elePublicationList.get(selectedPosition).getAddress());
                        setPublicationForElement(peerAddress, elementUnicastAddress, selectedPosition, elePublicationList);

                    } else {
                        setPublicationForDevice(peerAddress, elementUnicastAddress, selectedPosition, elePublicationList);
                    }
                }
            }
        });
        publishingRecycler.setAdapter(publicationListAdapter);
        Utils.calculateHeight(elePublicationList.size(), publishingRecycler);
    }


    void setPublishingAddress() {
        publicationList.clear();
        publicationListName.clear();

        if (type.equals(getResources().getString(R.string.str_element_setting))) {

            elePublicationList.clear();

            if (modelSelected == null) {
                return;
            }

            try {

                for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                    for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {

                        boolean isProvisioner = false;

                        for (int k = 0; k < meshRootClass.getProvisioners().size(); k++) {

                            if (meshRootClass.getProvisioners().get(k).getUUID().equalsIgnoreCase(meshRootClass.getNodes().get(i).getUUID())) {
                                isProvisioner = true;
                                break;
                            }
                        }

                        if (!isProvisioner) {
                            Publish publish = new Publish();
                            publish.setAddress(meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress());
                            publish.setName(meshRootClass.getNodes().get(i).getElements().get(j).getName());
                            publish.setCurrentParentAddress(meshRootClass.getNodes().get(i).getElements().get(0).getParentNodeAddress());
                            publish.setCurrentParentNodeName(meshRootClass.getNodes().get(i).getName());
                            publish.setTypeNode(true);
                            elePublicationList.add(publish);
                        }

                    }
                }

                for (int i = 0; i < meshRootClass.getGroups().size(); i++) {

                    Publish publish = new Publish();
                    publish.setAddress(meshRootClass.getGroups().get(i).getAddress());
                    publish.setName(meshRootClass.getGroups().get(i).getName());
                    publish.setTypeNode(false);

                    elePublicationList.add(publish);
                }


                if (elePublicationList.size() > 0) {
                    for (int i = 0; i < elePublicationList.size(); i++) {

                        //Currently According to note 1 : as explained in utils
                        //In future here model will be looped according to note 2 becouse in future each model publish will be different.
                        if (modelSelected.getPublish().getAddress().equalsIgnoreCase(elePublicationList.get(i).getAddress())) {
                            elePublicationList.get(i).setChecked(true);
                        } else {
                            elePublicationList.get(i).setChecked(false);
                        }
                    }
                }





                /*for (int l = 0; l < modelSelected.getPublishingAddressList().size(); l++) {
                    Publish publish = new Publish();

                    
                    if (modelSelected.getPublishingAddressList().get(l).getAddress().contains("c")) {
                        publish.setTypeNode(false);
                    } else {
                        publish.setTypeNode(true);
                    }

                    publish.setCurrentParentNodeName(modelSelected.getPublishingAddressList().get(l).getCurrentParentNodeName());
                    publish.setChecked(modelSelected.getPublishingAddressList().get(l).isChecked());
                    publish.setName(String.valueOf(modelSelected.getPublishingAddressList().get(l).getName()));
                    publish.setAddress(String.valueOf(modelSelected.getPublishingAddressList().get(l).getAddress()));
                    elePublicationList.add(publish);

                }*/
            } catch (Exception e) {
            }

            updateRecyclerForPublishers();

        } else {

            elePublicationList.clear();

            if (modelSelected == null) {
                return;
            }

            try {
                for (int l = 0; l < modelSelected.getPublishingAddressList().size(); l++) {
                    Publish publish = new Publish();
                    publish.setChecked(modelSelected.getPublishingAddressList().get(l).isChecked());
                    publish.setName(String.valueOf(modelSelected.getPublishingAddressList().get(l).getName()));
                    publish.setAddress(String.valueOf(modelSelected.getPublishingAddressList().get(l).getAddress()));
                    elePublicationList.add(publish);
                    //publicationList.add(String.valueOf(modelSelected.getPublishingAddressList().get(l).getAddress()));
                    //publicationListName.add(String.valueOf(modelSelected.getPublishingAddressList().get(l).getName()));
                }
            } catch (Exception e) {
            }
            updateRecyclerForPublishers();
        }
    }

    private void updateRecyclerForModels() {

        if (models == null) {
            return;
        }

        //models.add(models.get(0));
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 2, LinearLayoutManager.VERTICAL, false);
        modelRecycler.setLayoutManager(gridLayoutManager);
        modelRecyclerAdapter = new ElementModelRecyclerAdapter(AddGroupActivity.this, models, new ElementModelRecyclerAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void onClickRecyclerItem(View v, Model model, boolean isChecked, int position) {

                if (isChecked) {

                    models.get(position).setChecked(true);
                    modelSelected = models.get(position);
                    uncheckedOtherModels(position);
                    //update model data in json
                    Utils.json_UpdateModelsForCurrentElement(AddGroupActivity.this, meshRootClass, String.valueOf(peerAddress), elementUnicastAddress, models);
                    updateJsonData();
                    updateUi_ForSelectedModel(model);
                    modelRecyclerAdapter.notifyDataSetChanged();
                }

            }
        });
        modelRecycler.setAdapter(modelRecyclerAdapter);
        Utils.calculateHeight1(models.size(), modelRecycler);

        //Publisher and Subscriber remain same for all models in current release
        //so any one model is selected by default
        models.get(0).setChecked(true);

        for (int i = 0; i < models.size(); i++) {
            if (models.get(i).isChecked()) {
                modelSelected = models.get(i);
                updateUi_ForSelectedModel(models.get(i));
            }
        }

    }

    private void uncheckedOtherModels(int position) {

        for (int i = 0; i < models.size(); i++) {
            if (!models.get(i).getModelId().equalsIgnoreCase(models.get(position).getModelId())) {
                models.get(i).setChecked(false);
            }
        }
    }

    private void uncheckedOtherPublishers(int position) {

        for (int i = 0; i < elePublicationList.size(); i++) {
            if (!elePublicationList.get(i).getAddress().equalsIgnoreCase(elePublicationList.get(position).getAddress())) {
                elePublicationList.get(i).setChecked(false);
            }
        }
    }

    private void updateUi_ForSelectedModel(Model model) {

        Utils.DEBUG("Selected Model : " + model.getModelId());
        //set publication and subscription recycler adapter

        modelSelected = model;
        setPublishingAddress();
        setSubscription();


    }

    public void initRecyclerAdapter(Context context, List<String> subscriptionList, List<String> groupListName, List<Map<String, Object>> configuredNodes, final mobleAddress peerAddr, final String type) {

        if (type.equals("Device Settings") || type.equals(getResources().getString(R.string.str_element_setting))) {
            String pa = "";
            if (groupListName == null) {
                //subscription case

                /*if(type.equals(getResources().getString(R.string.str_element_setting)))
                {
                    NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
                    modelRecycler.setLayoutManager(gridLayoutManager);
                    ProvisionedNodeSettingAdapter provisionListAdapterForElements = new ProvisionedNodeSettingAdapter(AddGroupActivity.this, subscriptionList, groupListName, "", type, new ProvisionedNodeSettingAdapter.IRecyclerViewHolderClicks() {
                        @Override
                        public void onClickRecyclerItem(CompoundButton v, int position, String item, String mAutoAddress, boolean isSelected) {

                        }
                    });
                    modelRecycler.setAdapter(provisionListAdapterForElements);
                    Utils.calculateHeight(subscriptionList.size(), modelRecycler);
                }
                else
                {

                }*/
                NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
                subscriptionRecycler.setLayoutManager(gridLayoutManager);
                ProvisionedNodeSettingAdapter provisionListAdapterForSubscription = new ProvisionedNodeSettingAdapter(AddGroupActivity.this, subscriptionList, groupListName, "", type, new ProvisionedNodeSettingAdapter.IRecyclerViewHolderClicks() {
                    @Override
                    public void onClickRecyclerItem(CompoundButton v, int position, String item, String mAutoAddress, boolean isSelected) {

                    }
                });
                subscriptionRecycler.setAdapter(provisionListAdapterForSubscription);
                Utils.calculateHeight(subscriptionList.size(), subscriptionRecycler);


            } else {
                //pulication case
                pa = ((UserApplication) getApplication()).mConfiguration.getPublication(String.valueOf(peerAddress));
                NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(AddGroupActivity.this, 1, LinearLayoutManager.VERTICAL, false);
                publishingRecycler.setLayoutManager(gridLayoutManager);
                publicationRecyclerAdapter = new ProvisionedNodeSettingAdapter(AddGroupActivity.this, subscriptionList, groupListName, pa, type, new ProvisionedNodeSettingAdapter.IRecyclerViewHolderClicks() {
                    @Override
                    public void onClickRecyclerItem(CompoundButton v, int selected_position, String item, String mAutoAddress, boolean isSelected) {

                        if (isSelected) {
                            if (type.equals(getResources().getString(R.string.str_element_setting))) {
                                //update list data and recycler...........................
                                //selectedPosition = selected_position;
                                //setPublicationForElement(peerAddress, elementUnicastAddress, selected_position, publicationList);
                            } else {
                                setPublicationForNode(peerAddress, selected_position, publicationList);
                            }
                        }
                    }
                });
                publishingRecycler.setAdapter(publicationRecyclerAdapter);
                Utils.calculateHeight(subscriptionList.size(), publishingRecycler);
            }

        }

    }

    private void setPublicationForElement(mobleAddress nodeAddress, String elementAddress, int selected_position, ArrayList<Publish> publicationList) {

        // Since subscription and publication are present inside model.
        // So from here it is needed to provide model object for this element.
        Utils.contextU = AddGroupActivity.this;
        Utils.isPublicationStart = true;


        Utils.setPublicationForElement(AddGroupActivity.this, nodeAddress, mobleAddress.deviceAddress(Integer.parseInt(elementUnicastAddress)), selected_position, publicationList);

    }

    private void setPublicationForDevice(mobleAddress nodeAddress, String elementAddress, int selected_position, ArrayList<Publish> publicationList) {

        // Since subscription and publication are present inside model.
        // So from here it is needed to provide model object for this element.
        Utils.contextU = AddGroupActivity.this;
        Utils.isPublicationStart = true;
        Utils.setPublicationForDevice(AddGroupActivity.this, nodeAddress, mobleAddress.deviceAddress(Integer.parseInt(elementUnicastAddress)), selected_position, publicationList);
    }

    public void updateUi_PublicationForCurrentModel(ApplicationParameters.Status status) {

        if (status == ApplicationParameters.Status.SUCCESS) {
            //update model data in json
            elePublicationList.get(selectedPosition).setChecked(true);
            uncheckedOtherPublishers(selectedPosition);

            Publish currentPublisherSelected = new Publish();
            currentPublisherSelected.setCurrentParentNodeName(elePublicationList.get(selectedPosition).getCurrentParentNodeName());
            currentPublisherSelected.setChecked(elePublicationList.get(selectedPosition).isChecked());
            currentPublisherSelected.setAddress(elePublicationList.get(selectedPosition).getAddress());
            currentPublisherSelected.setTypeNode(elePublicationList.get(selectedPosition).isTypeNode());
            currentPublisherSelected.setName(elePublicationList.get(selectedPosition).getName());
            currentPublisherSelected.setCredentials(elePublicationList.get(selectedPosition).getCredentials());
            currentPublisherSelected.setIndex(elePublicationList.get(selectedPosition).getIndex());
            currentPublisherSelected.setPeriod(elePublicationList.get(selectedPosition).getPeriod());
            currentPublisherSelected.setRetransmit(elePublicationList.get(selectedPosition).getRetransmit());
            currentPublisherSelected.setTtl(elePublicationList.get(selectedPosition).getTtl());

            modelSelected.setPublish(currentPublisherSelected);

            Utils.json_UpdatePublisherForCurrentModel(AddGroupActivity.this, meshRootClass, String.valueOf(peerAddress), elementUnicastAddress, elePublicationList, modelSelected);
            updateJsonData();
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    publicationListAdapter.notifyDataSetChanged();
                }
            }, 100);
        } else {
            //if publication failed then reset ui again
            publicationListAdapter.notifyDataSetChanged();
        }


    }

    private void setPublicationForNode(mobleAddress peerAddress, int selected_position, List<String> publicationList) {

        //Utils.disableOtherRadioButtons(v, isSelected, selected_position, null, publicationRecyclerAdapter, type);
        Utils.setPublicationToMoBleDevice(AddGroupActivity.this, peerAddress, selected_position, publicationList);
        for (int i = 0; i < mData.size(); i++) {
            if (mData.get(i).containsKey("m_address")) {
                if (mData.get(i).get("m_address") != null && mData.get(i).get("m_address").equals(peerAddress))
                    mData.get(i).put("publish_address", publicationList.get(selected_position));
            }
        }
        Utils.setPublicationToConfiguration(AddGroupActivity.this, peerAddress, selected_position, publicationList);

        //update data set and adapter
        setPublishingAddress();
        updateJsonData();
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                publicationRecyclerAdapter.notifyDataSetChanged();
            }
        }, 200);
    }

    public void updateUi_SubListElementsForGroup(ApplicationParameters.Status status) {

        updateJsonData();
        if (status == ApplicationParameters.Status.SUCCESS) {
            //update model data in json
            eleSubscriptionList.get(selectedPosition).setChecked(eleSubscriptionList.get(selectedPosition).isChecked() ? false : true);
            //MeshRootClass meshRootClass = Utils.json_updateElementsInGroup(AddGroupActivity.this, addr, eleSubscriptionList, this.meshRootClass);
            //update subscription list for device setting also
            Utils.json_updateSubscriptionGroupInModel(AddGroupActivity.this, String.valueOf(addr), eleSubscriptionList.get(selectedPosition), meshRootClass);

        } else {
            //if subscription failed then reset ui again
            updateSubscriptionData("Error");
            Utils.showToast(AddGroupActivity.this, "Subscription Failed");
        }

        //loader.hide();

    }


    public void updateSubscriptionData(String msg)
    {
        if(!((Activity) this).isFinishing())
        {
            loader.hide();
            loader.dismiss();
            //Utils.showPopUpForMessage(AddGroupActivity.this, msg, Utils.getDialogInstance(AddGroupActivity.this));
            Utils.showPopUpForMessage(AddGroupActivity.this, msg);
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    updateJsonData();
                    subListForGroupAdapter.notifyDataSetChanged();
                }
            }, 500);
        }
    }


    public void updateUi_SubListNodesForGroup(ApplicationParameters.Status status) {

        if (status == ApplicationParameters.Status.SUCCESS) {
            //Status True : If checked and Unchecked
            nodeSubscriptionList.get(selectedPosition).setChecked(nodeSubscriptionList.get(selectedPosition).isChecked() ? false : true);
            //Utils.json_updateNodesInGroup(AddGroupActivity.this, addr, nodeSubscriptionList, meshRootClass);
            updateJsonData();
            //update subscription list in Node->Element->Model->SubscriptionList for current subscribe address selected
            Utils.json_updateSubList_ofModel_Element(AddGroupActivity.this, addr, nodeSubscriptionList.get(selectedPosition), meshRootClass, nodeSubscriptionList.get(selectedPosition).isChecked());
            updateJsonData();
        }

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                subListForGroupAdapter.notifyDataSetChanged();
                loader.hide();
            }
        }, 50);

    }

    private void setAdapterForPublicationList() {
        //ArrayList<Publish> final_publicationNameList = new ArrayList<>();

        String parentNodeName = "";
        if (meshRootClass != null) {

            /**/
            eleListPub.clear();
            if (meshRootClass.getNodes() != null && meshRootClass.getNodes().size() > 0) {
                for (int i = 0; i < meshRootClass.getNodes().size(); i++) {

                    boolean isNodeIsProvisioner = false;
                    for (int j = 0; j < meshRootClass.getProvisioners().size(); j++) {
                        if (meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(meshRootClass.getProvisioners().get(j).getUUID())) {
                            isNodeIsProvisioner = true;
                            break;
                        }
                    }

                    if (!isNodeIsProvisioner) {
                        parentNodeName = meshRootClass.getNodes().get(i).getName();
                        for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                            meshRootClass.getNodes().get(i).getElements().get(j).setParentNodeName(meshRootClass.getNodes().get(i).getName());
                            eleListPub.add(meshRootClass.getNodes().get(i).getElements().get(j));
                        }
                    }
                }
            }

        }

        if(eleListPub.isEmpty())
            return;

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(this, 1, LinearLayoutManager.VERTICAL, false);
        publishingRecycler.setLayoutManager(gridLayoutManager);
        //publicationGroupAdapter = new PublicationListForGroupSettingsAdapter(this, type,  elePublicationList, new PublicationListForGroupSettingsAdapter.IRecyclerViewHolderClicks() {
        publicationGroupAdapter = new PubGrpSettingAdapter(this, parentNodeName, new_groupAddress, type, eleListPub, new PubGrpSettingAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void notifyAdapter(final int position, final List<Element> final_publication_list, boolean isSelected) {
                if (isSelected) {
                    selectedPosition = position;
                    if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                        Utils.DEBUG("Node Add" + eleListPub.get(position).getParentNodeName() +
                                " Elem Add" + eleListPub.get(position).getUnicastAddress());
                        //peerAddress = mobleAddress.deviceAddress(Integer.parseInt(eleListPub.get(position).getParentNodeAddress(),16));
                        //setPublicationForElement(peerAddress, eleListPub.get(position).getUnicastAddress(), selectedPosition, eleListPub);
                        //setPublicationForGroup(peerAddress, eleListPub.get(position).getUnicastAddress(), selectedPosition, eleListPub);
                        Utils.addPublishToGroup(AddGroupActivity.this, eleListPub.get(position).getParentNodeAddress(), eleListPub.get(position).getUnicastAddress(),  groupAddress.toString());


                    }
                }

            }
        });
        publishingRecycler.setAdapter(publicationGroupAdapter);
    }

    public void updateUi_PublicationForGroup(ApplicationParameters.Status status, final ApplicationParameters.Address address) {
        loader.dismiss();

        if (status == ApplicationParameters.Status.SUCCESS) {

            //new position - > currentgrp
            //oldposition != grp remove

            // according to note 1 : given in utils
            for (int i = 0; i < eleListPub.get(selectedPosition).getModels().size(); i++) {

                eleListPub.get(selectedPosition).getModels().get(i).getPublish().setAddress(new_groupAddress);
            }
            //updateJsonData();
            //publicationGroupAdapter.notifyDataSetChanged();

            for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
                for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                    if (meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress().equalsIgnoreCase(eleListPub.get(selectedPosition).getUnicastAddress())) {
                        meshRootClass.getNodes().get(i).getElements().set(j, eleListPub.get(selectedPosition));
                    }
                }
            }

            Utils.setBLEMeshDataToLocal(AddGroupActivity.this, ParseManager.getInstance().toJSON(meshRootClass));

            updateJsonData();

            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    publicationGroupAdapter.setPubList(address);
                    publicationGroupAdapter.notifyDataSetChanged();
                }
            }, 100);
        } else {
            //if publication failed then reset ui again
            publicationGroupAdapter.notifyDataSetChanged();
        }
    }




}



