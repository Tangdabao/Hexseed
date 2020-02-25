/**
 * *****************************************************************************
 *
 * @file ProvisionedTabFragment.java
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
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.ProvisionedRecyclerAdapter;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import java.util.ArrayList;
import java.util.Collections;


public class ProvisionedTabFragment extends BaseFragment {

    private static ProvisionedTabFragment fragment;
    private View view;
    private RecyclerView recyclerView;
    //private MeshRootClass meshRootClass;
    private AppDialogLoader loader;
    private ProvisionedRecyclerAdapter provisionedRecyclerAdapter;
    private SwipeRefreshLayout swiperefresh;
    private static ArrayList<Nodes> nodes = new ArrayList<>();

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
                        updateProvisioneRecycler(0, null);
                    }
                }
        );

       setProvisionAdapter(null,false);

    }

    private void setProvisionAdapter(String selected_element_address,boolean is_command_error) {

        updateJsonData();

        try {
            if (nodes != null) {
                Collections.sort(nodes);
            }
        } catch (Exception e) {

        }

        recyclerView = (RecyclerView) view.findViewById(R.id.recyclerView);
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(gridLayoutManager);

        provisionedRecyclerAdapter = new ProvisionedRecyclerAdapter(getActivity(), new ProvisionedTabFragment().getClass().getName(), nodes,selected_element_address,is_command_error, new ProvisionedRecyclerAdapter.IRecyclerViewHolderClicks() {
            @Override
            public void onClickRecyclerItem(View v, int position, String item, String mAutoAddress, boolean isSelected) {
                recyclerView.stopScroll();
                provisionedRecyclerAdapter.sortData();
                provisionedRecyclerAdapter.notifyDataSetChanged();
            }

            @Override
            public void notifyAdapter(String selected_element_address, boolean is_command_error) {
                updateJsonData();
                setProvisionAdapter(selected_element_address,is_command_error);
            }

            @Override
            public void notifyPosition(int elementPosition, Nodes node) {
                // get element position w.r.t any touch event
            }
        });
        recyclerView.setAdapter(provisionedRecyclerAdapter);

    }

    private void updateJsonData() {

        //meshRootClass = Utils.getBLEMeshDataInstance(getActivity());

      if(nodes!=null)  nodes.clear();
        try {

            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                  if(provisionedRecyclerAdapter!=null)  provisionedRecyclerAdapter.notifyDataSetChanged();
                }
            });

            try {
                if(((MainActivity)getActivity()).meshRootClass.getNodes() != null && ((MainActivity)getActivity()).meshRootClass.getNodes().size() > 0)
                {
                    for (int i = 0; i < ((MainActivity)getActivity()).meshRootClass.getNodes().size(); i++) {
                        boolean isNodeIsProvisioner = false;
                        for (int j = 0; j < ((MainActivity)getActivity()).meshRootClass.getProvisioners().size(); j++) {
                            if (((MainActivity)getActivity()).meshRootClass.getNodes().get(i).getUUID().equalsIgnoreCase(((MainActivity)getActivity()).meshRootClass.getProvisioners().get(j).getUUID())) {
                                isNodeIsProvisioner = true;
                                break;
                            }
                        }

                        if (!isNodeIsProvisioner) {
                            nodes.add(((MainActivity)getActivity()).meshRootClass.getNodes().get(i));
                        }
                    }
                }
            } catch (Exception e) {
            }
        }catch (Exception e){}
    }

    public void updateProvisioneRecycler(int someInt, Nodes deviceDiscovered) {

        updateJsonData();
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                provisionedRecyclerAdapter.notifyDataSetChanged();
                //recyclerView.smoothScrollToPosition(provisionedRecyclerAdapter.getItemCount());
            }
        });

        if(swiperefresh != null)
        {
            swiperefresh.setRefreshing(false);
        }

    }

    public static ProvisionedTabFragment newInstance() {

        if( fragment == null ) {
            fragment = new ProvisionedTabFragment();
        }
        return fragment;
    }

}
