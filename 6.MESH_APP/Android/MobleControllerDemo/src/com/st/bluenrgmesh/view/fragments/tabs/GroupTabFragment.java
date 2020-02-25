/**
 * *****************************************************************************
 *
 * @file GroupTabFragment.java
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
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.GroupRecyclerAdapter;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.models.meshdata.Group;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import org.json.JSONObject;

import java.util.ArrayList;

public class GroupTabFragment extends BaseFragment {

    private static GroupTabFragment fragment;
    private View view;
    private RecyclerView recyclerView;
    //private MeshRootClass meshRootClass;
    private GroupRecyclerAdapter groupRecyclerAdapter;
    private SwipeRefreshLayout swiperefresh;
    private ArrayList<Group> groups = new ArrayList<>();
    private AppDialogLoader loader;
    private String typeModel;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_provisioned, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        updateJsonData();
        initUi();

        return view;
    }

    private void initUi() {

        swiperefresh = (SwipeRefreshLayout) view.findViewById(R.id.swiperefresh);
        swiperefresh.setColorSchemeColors(getResources().getColor(R.color.ST_primary_blue), getResources().getColor(R.color.ST_primary_blue), getResources().getColor(R.color.ST_primary_blue));
        swiperefresh.setOnRefreshListener(
                new SwipeRefreshLayout.OnRefreshListener() {
                    @Override
                    public void onRefresh() {
                        //loader.show();
                        updateGroupRecycler(typeModel);
                    }
                }
        );

        setGroupAdapter();
    }

    private void setGroupAdapter() {

        try {
            if (((MainActivity)getActivity()).meshRootClass.getGroups() == null || ((MainActivity)getActivity()).meshRootClass.getGroups().size() == 0) {
                swiperefresh.setRefreshing(false);
                groups.clear();
                return;
            }
            else
            {
                groups.clear();
                boolean isGroupPresent = false;
                if(((MainActivity)getActivity()).meshRootClass.getGroups().size() > 0)
                {
                    for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {

                        if(((MainActivity)getActivity()).meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase("FFFF"))
                        {
                            isGroupPresent = true;
                        }
                    }

                }

                if(!isGroupPresent)
                {
                    addAllNodesOptionToGroup();
                }

                for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {
                    groups.add(((MainActivity)getActivity()).meshRootClass.getGroups().get(i));
                }

            }
        } catch (Exception e) {
            //loader.hide();
            return;
        }


        recyclerView = (RecyclerView) view.findViewById(R.id.recyclerView);
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(gridLayoutManager);
        groupRecyclerAdapter = new GroupRecyclerAdapter(getActivity(), groups, new GroupRecyclerAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void onClickRecyclerItem(View v, int position, String item, String mAutoAddress, boolean isSelected) {

            }
        });
        recyclerView.setAdapter(groupRecyclerAdapter);
    }

    private void addAllNodesOptionToGroup() {
        Group group = new Group();
        group.setName("All Nodes");
        group.setAddress("FFFF");
        groups.add(group);
    }


    private void updateJsonData() {

        /*try {
            meshRootClass = ParseManager.getInstance().fromJSON(
                    new JSONObject(Utils.getBLEMeshDataFromLocal(getActivity())), MeshRootClass.class);
        } catch (Exception e) {
            e.printStackTrace();
        }*/
        ((MainActivity)getActivity()).updateJsonData();

        groups.clear();

        try {
            if(((MainActivity)getActivity()).meshRootClass.getGroups().size() > 0)
            {
                boolean isGroupPresent = false;
                if(((MainActivity)getActivity()).meshRootClass.getGroups().size() > 0)
                {
                    for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {

                        if(((MainActivity)getActivity()).meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase("FFFF"))
                        {
                            isGroupPresent = true;
                        }
                    }

                }

                if(!isGroupPresent)
                {
                    addAllNodesOptionToGroup();
                }
                for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {
                    groups.add(((MainActivity)getActivity()).meshRootClass.getGroups().get(i));
                }
            }

        }catch (Exception e){}
    }


    public static Fragment newInstance() {

        if( fragment == null ) {
            fragment = new GroupTabFragment();
        }
        return fragment;
    }

    public void cleanGroupUi()
    {
        try {
            groups.clear();
            if(groupRecyclerAdapter!= null)
            {
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        groupRecyclerAdapter.notifyDataSetChanged();
                    }
                });
            }
        }catch (Exception e){}
    }

    public void updateGroupRecycler(String typeModel) {

        this.typeModel = typeModel;
        updateJsonData();
        try {
            if (((MainActivity)getActivity()).meshRootClass.getGroups() == null || ((MainActivity)getActivity()).meshRootClass.getGroups().size() == 0) {
                swiperefresh.setRefreshing(false);
                groups.clear();
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        groupRecyclerAdapter.notifyDataSetChanged();
                    }
                });

                return;
            }else
            {
                groups.clear();

                if(groupRecyclerAdapter == null)
                {
                    setGroupAdapter();
                }
                else {

                    if(Utils.isNodesExistInMesh(getActivity(), ((MainActivity)getActivity()).meshRootClass))
                    {
                        boolean isGroupPresent = false;
                        if(((MainActivity)getActivity()).meshRootClass.getGroups().size() > 0)
                        {
                            for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {

                                if(((MainActivity)getActivity()).meshRootClass.getGroups().get(i).getAddress().equalsIgnoreCase("FFFF"))
                                {
                                    isGroupPresent = true;
                                }
                            }

                        }

                        if(!isGroupPresent)
                        {
                            addAllNodesOptionToGroup();
                        }

                        for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getGroups().size(); i++) {
                            groups.add(((MainActivity)getActivity()).meshRootClass.getGroups().get(i));
                        }

                        if(typeModel == null)
                        {
                            groupRecyclerAdapter.fromWhere(getString(R.string.str_vendormodel_label));
                        }
                        else
                        {
                            groupRecyclerAdapter.fromWhere(typeModel);
                        }
                    }

                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            groupRecyclerAdapter.notifyDataSetChanged();
                        }
                    });
                }

            }
        } catch (Exception e) {
            //loader.hide();
            return;
        }

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                swiperefresh.setRefreshing(false);
            }
        },1000);
    }
}
