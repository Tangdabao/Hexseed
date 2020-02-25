package com.st.bluenrgmesh.view.fragments.setting;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.mobleAddress;
import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.UserApplication;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.group.PubGrpSettingAdapter;
import com.st.bluenrgmesh.adapter.group.SubGrpSettingAdapter;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.Group;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by sharma01 on 10/17/2018.
 */

public class GroupSettingFragment extends BaseFragment {

    private View view;
    private EditText edtName;
    private EditText edtAddress;
    private RecyclerView subscriptionRecycler;
    private RecyclerView publishingRecycler;
    private Button butRemoveGroup;
    private ArrayList<Element> eleSubscriptionList = new ArrayList<>();
    private ArrayList<Element> elePublicationList = new ArrayList<>();
    private String new_groupAddress = "c000";
    private Group groupData = null;
    private mobleAddress groupAddress;
    private mobleAddress addr;
    private int count;
    private int selectedPosition;
    private SubGrpSettingAdapter subGrpSettingAdapter;
    private String parentNodeName = null;
    private PubGrpSettingAdapter pubGrpSettingAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_groupsettings, container, false);

        //loader = AppDialogLoader.getLoader(getActivity());
        Utils.updateActionBarForFeatures(getActivity(), new GroupSettingFragment().getClass().getName());
        initUi();

        return view;
    }

    private void initUi() {

        //((MainActivity)getActivity()).updateJsonData();
        Utils.setSettingType(getActivity(), getString(R.string.str_group_setting));
        groupData = (Group) getArguments().getSerializable(getString(R.string.key_serializable));
        edtName = (EditText) view.findViewById(R.id.edtName);
        edtAddress = (EditText) view.findViewById(R.id.edtAddress);
        subscriptionRecycler = (RecyclerView) view.findViewById(R.id.subscriptionRecycler);
        publishingRecycler = (RecyclerView) view.findViewById(R.id.publishingRecycler);
        butRemoveGroup = (Button) view.findViewById(R.id.butRemoveNode);
        edtAddress.setText(groupData.getAddress());
        int adr = Integer.parseInt(groupData.getAddress(), 16);
        mobleAddress addre = mobleAddress.groupAddress(adr);
        short adrs = addre.mValue;
        groupAddress = mobleAddress.groupAddress((adrs) & 0xFFFF);
        addr = groupAddress;
        edtName.setText(groupData.getName());

        butRemoveGroup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Utils.checkGrpHasSubElements(getActivity(), eleSubscriptionList, addr, getString(R.string.str_groupfailremove_label));
            }
        });

        setSubscriptionData();
        setPublicationData();
    }

    private void setSubscriptionData() {
        eleSubscriptionList = getSubscriptionList();
        updateSubscriptionRecycler();
    }

    private void setPublicationData() {
        elePublicationList = getPublicationData();
        updatePublicationRecycler();
    }

    private void updateSubscriptionRecycler() {

        if (eleSubscriptionList.isEmpty())
            return;

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        subscriptionRecycler.setLayoutManager(gridLayoutManager);
        subGrpSettingAdapter = new SubGrpSettingAdapter(getActivity(), eleSubscriptionList, groupData.getAddress(), ((MainActivity)getActivity()).meshRootClass,
                 false, new SubGrpSettingAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void onClickRecyclerItem(View v, int position, Element element, String mAutoAddress, boolean isChecked) {
                Utils.DEBUG("DEBUG Clicked >> Subscription : " +
                        " address : " + mAutoAddress + " subaddrss : " + element.getUnicastAddress());

                if (isChecked) {
                    //on checked
                    int count = getCheckedElement();
                    //int count = groupsInfo(mAutoAddress);
                    UserApplication.trace("count " + count);
                    if (count <= 10) {
                        ((MainActivity)getActivity()).loader.show();
                        try {
                            selectedPosition = position;
                            if (eleSubscriptionList.get(position).isChecked()) {
                                //Utils.removeElementFromGroup(AddGroupActivity.this, addr, mAutoAddress, item);
                                Utils.removeElementFromGroup(getActivity(), addr, mAutoAddress, element);
                            } else {
                                Utils.addElementToGroup(getActivity(), addr, mAutoAddress, element);
                            }

                        } catch (Exception e) {
                            ((MainActivity)getActivity()).loader.hide();
                        }

                    } else {
                        //show maximum count status
                        Utils.showToast(getActivity(), "Maximum 10 elements limit for subscription.");
                    }
                }
            }

            @Override
            public void onClickNodeRecyclerItem(View v, int position, Nodes node, String address, boolean b) {

            }
        });
        subscriptionRecycler.setAdapter(subGrpSettingAdapter);
        Utils.calculateHeight(eleSubscriptionList.size(), subscriptionRecycler);

    }

    private void updatePublicationRecycler() {

        if(elePublicationList.isEmpty())
            return;

        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        publishingRecycler.setLayoutManager(gridLayoutManager);
        //pubGrpSettingAdapter = new PublicationListForGroupSettingsAdapter(this, type,  elePublicationList, new PublicationListForGroupSettingsAdapter.IRecyclerViewHolderClicks() {
        pubGrpSettingAdapter = new PubGrpSettingAdapter(getActivity(), parentNodeName, groupData.getAddress(), null, elePublicationList, new PubGrpSettingAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void notifyAdapter(final int position, final List<Element> final_publication_list, boolean isSelected) {
                if (isSelected) {
                    selectedPosition = position;
                    if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                        Utils.DEBUG("Node Add" + elePublicationList.get(position).getParentNodeName() +
                                " Elem Add" + elePublicationList.get(position).getUnicastAddress());
                        Utils.addPublishToGroup(getActivity(), elePublicationList.get(position).getParentNodeAddress(), elePublicationList.get(position).getUnicastAddress(),  groupAddress.toString());
                    }
                }

            }
        });
        publishingRecycler.setAdapter(pubGrpSettingAdapter);
    }

    private ArrayList<Element> getPublicationData() {

        if (((MainActivity)getActivity()).meshRootClass != null) {
            elePublicationList.clear();
            if (((MainActivity)getActivity()).meshRootClass.getNodes() != null && ((MainActivity)getActivity()).meshRootClass.getNodes().size() > 0) {
                for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getNodes().size(); i++) {

                    boolean isNodeIsProvisioner = false;
                    for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getProvisioners().size(); j++) {
                        if (((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(((MainActivity)getActivity()).meshRootClass.getProvisioners().get(j).getUUID())) {
                            isNodeIsProvisioner = true;
                            break;
                        }
                    }

                    if (!isNodeIsProvisioner) {
                        parentNodeName = ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getName();
                        for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().size(); j++) {
                            ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().get(j).setParentNodeName(((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getName());
                            elePublicationList.add(((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().get(j));
                        }
                    }
                }
            }

        }
        return elePublicationList;
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

    private ArrayList<Element> getSubscriptionList() {

        //returmn all the elements
        eleSubscriptionList.clear();
        try{
            for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getNodes().size(); i++) {

                boolean isNodeIsProvisioner = false;
                for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getProvisioners().size(); j++) {
                    if (((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(((MainActivity)getActivity()).meshRootClass.getProvisioners().get(j).getUUID())) {
                        isNodeIsProvisioner = true;
                        break;
                    }
                }

                if (!isNodeIsProvisioner) {
                    for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().size(); j++) {

                        Element element = ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().get(j);
                        element.setParentNodeAddress(((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress());
                        boolean isGroupIsPresent_Element = Utils.isGroupIsPresentInElement(element, groupData.getAddress());

                        if (isGroupIsPresent_Element) {
                            element.setChecked(true);
                        } else {
                            element.setChecked(false);
                        }
                        eleSubscriptionList.add(element);
                    }
                }
            }
        }catch (Exception e){}

        return eleSubscriptionList;
    }

    public void updateUi_PublicationForGroup(ApplicationParameters.Status status, final String address) {
        ((MainActivity)getActivity()).loader.dismiss();
        if (status == ApplicationParameters.Status.SUCCESS) {
            for (int i = 0; i < elePublicationList.get(selectedPosition).getModels().size(); i++) {

                elePublicationList.get(selectedPosition).getModels().get(i).getPublish().setAddress(String.valueOf(addr));
            }

            for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getNodes().size(); i++) {
                for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().size(); j++) {
                    if (((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress().equalsIgnoreCase(elePublicationList.get(selectedPosition).getUnicastAddress())) {
                        ((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getElements().set(j, elePublicationList.get(selectedPosition));
                    }
                }
            }
            Utils.setBLEMeshDataToLocal(getActivity(), ParseManager.getInstance().toJSON(((MainActivity)getActivity()).meshRootClass));
        }
        updatePublicationData(getActivity().getString(R.string.str_published_success_label));
    }

    public void updateFragmentUi(String bt_addr, int i, ApplicationParameters.Status status) {

        if(i == ((MainActivity)getActivity()).SUBSCRIPTION_CASE)
        {
            ((MainActivity)getActivity()).updateJsonData();
            if (status == ApplicationParameters.Status.SUCCESS) {
                eleSubscriptionList.get(selectedPosition).setChecked(eleSubscriptionList.get(selectedPosition).isChecked() ? false : true);
                json_updateSubscriptionGroupInModel(getActivity(), String.valueOf(addr), eleSubscriptionList.get(selectedPosition), ((MainActivity)getActivity()).meshRootClass);

            } else {
                updateSubscriptionData(getActivity().getString(R.string.str_Subscription_Failed_label));
            }
        }
        else if(i == ((MainActivity)getActivity()).PUBLICATION_CASE)
        {
            ((MainActivity)getActivity()).updateJsonData();
            if (status == ApplicationParameters.Status.SUCCESS) {
                updateUi_PublicationForGroup(ApplicationParameters.Status.SUCCESS, bt_addr);

            } else {
                updatePublicationData(getActivity().getString(R.string.str_Publication_Failed_label));
            }

        }
    }

    /**
     * Method used to update group data whenever any element is added or removed in subscription list of model
     *
     * @param context
     * @param groupAddress
     * @param meshRootClass
     */
    public void json_updateSubscriptionGroupInModel(final Context context, final String groupAddress, final Element element, final MeshRootClass meshRootClass) {

        // According to note 1 : All models data will be same
        String strMsg = "";
        try {
            for (int i = 0; i < meshRootClass.getNodes().size(); i++) {
                int addrs = Integer.parseInt(element.getParentNodeAddress());
                if (String.valueOf(addrs).equalsIgnoreCase(meshRootClass.getNodes().get(i).getElements().get(0).getUnicastAddress())) {
                    for (int j = 0; j < meshRootClass.getNodes().get(i).getElements().size(); j++) {
                        if (meshRootClass.getNodes().get(i).getElements().get(j).getUnicastAddress().equalsIgnoreCase(element.getUnicastAddress())) {
                            for (int k = 0; k < meshRootClass.getNodes().get(i).getElements().get(j).getModels().size(); k++) {

                                if (element.isChecked()) {
                                    strMsg = context.getString(R.string.str_subscribed_success_label);
                                    meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k).getSubscribe().add(groupAddress);
                                } else {
                                    if (meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k).getSubscribe().contains(groupAddress)) {
                                        meshRootClass.getNodes().get(i).getElements().get(j).getModels().get(k).getSubscribe().remove(groupAddress);
                                        strMsg = context.getString(R.string.str_unsubscribed_label);
                                        // /Utils.showPopUpForMessage(context, "Unsubscribed Successfully",Utils.getDialogInstance(context));
                                    }
                                }

                            }
                            break;
                        }
                    }
                }
            }
            Utils.setBLEMeshDataToLocal(context, ParseManager.getInstance().toJSON(meshRootClass));
            Utils.DEBUG("Group Updated Successfully in Subscription List For Model: " + groupAddress);
        }catch (Exception e){Utils.DEBUG("Exception in method : json_updateSubscriptionGroupInModel");}

        updateSubscriptionData(strMsg.equals("") ? context.getString(R.string.str_subscribed_success_label) : strMsg);
    }

    public void updateSubscriptionData(String msg)
    {
        ((MainActivity)getActivity()).loader.hide();
        ((MainActivity)getActivity()).loader.dismiss();
        Utils.showPopUpForMessage(getActivity(), msg);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                ((MainActivity)getActivity()).updateJsonData();
                subGrpSettingAdapter.notifyDataSetChanged();
            }
        }, 500);
    }

    public void updatePublicationData(String msg)
    {
        ((MainActivity)getActivity()).loader.hide();
        ((MainActivity)getActivity()).loader.dismiss();
        Utils.showPopUpForMessage(getActivity(), msg);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                ((MainActivity)getActivity()).updateJsonData();
                pubGrpSettingAdapter.notifyDataSetChanged();
            }
        }, 500);
    }

    public Group getGroupData() {
        groupData.setName(edtName.getText().toString());
        return groupData;
    }
}
