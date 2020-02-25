/**
 * *****************************************************************************
 *
 * @file UnprovisionedFragment.java
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
import android.os.Looper;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.UserApplication;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.NpaGridLayoutManager;
import com.st.bluenrgmesh.adapter.UnprovisionedRecyclerAdapter;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import java.util.ArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import pl.bclogic.pulsator4droid.library.PulsatorLayout;


public class UnprovisionedFragment extends BaseFragment {


    private static UnprovisionedFragment fragment;
    private View view;
    private RecyclerView layRecycler;
    private AppDialogLoader loader;
    public UnprovisionedRecyclerAdapter unprovisionedRecyclerAdapter;
    public UserApplication app;
    public ArrayList<Nodes> mUnprovisionedData = new ArrayList<>();
    public ArrayList<Nodes> mNewRSSIList = new ArrayList<>();
    private LinearLayout lytWarningDeviceDiscovery;
    private ScheduledFuture updateFuture;
    private boolean runRSSITask = false;
    private boolean isThreadScheduled = false;
    private PulsatorLayout pulsator;
    private int itemPosition;
    private SwipeRefreshLayout swiperefresh;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_unprovisioned, container, false);

        Utils.contextU = getActivity();
        loader = AppDialogLoader.getLoader(getActivity());
        initUi();

        return view;
    }

    private void initUi() {

        pulsator = (PulsatorLayout) view.findViewById(R.id.pulsator);
        pulsator.start();

        swiperefresh = (SwipeRefreshLayout) view.findViewById(R.id.swiperefresh);
        swiperefresh.setColorSchemeColors(getResources().getColor(R.color.ST_primary_blue), getResources().getColor(R.color.ST_primary_blue), getResources().getColor(R.color.ST_primary_blue));
        swiperefresh.setOnRefreshListener(
                new SwipeRefreshLayout.OnRefreshListener() {
                    @Override
                    public void onRefresh() {
                        updateUnprovisionedList(null, false);
                        ((MainActivity)getActivity()).adviseCallbacks();
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                swiperefresh.setRefreshing(false);
                            }
                        }, 2000);
                    }
                }
        );

        lytWarningDeviceDiscovery = (LinearLayout) view.findViewById(R.id.lytWarningDeviceDiscovery);
        layRecycler = (RecyclerView) view.findViewById(R.id.layRecycler);
        NpaGridLayoutManager gridLayoutManager = new NpaGridLayoutManager(getActivity(), 1, LinearLayoutManager.VERTICAL, false);
        layRecycler.setLayoutManager(gridLayoutManager);
        unprovisionedRecyclerAdapter = new UnprovisionedRecyclerAdapter(getActivity(), mUnprovisionedData/*((MainActivity)getActivity()).mUnprovisionedList*/, "",
                new UnprovisionedRecyclerAdapter.IRecyclerViewHolderClicks() {

            @Override
            public void onClickRecyclerItemNode(View v, int position, final Nodes nodeSelected) {
                Utils.DEBUG(">> Unprovision Address Selected : " + nodeSelected.getAddress());
                itemPosition = position;
                updateUnprovisionedList(nodeSelected, true);
                ((MainActivity) getActivity()).startProvisioning(nodeSelected);
            }
        });
        layRecycler.setAdapter(unprovisionedRecyclerAdapter);

        initDeviceScanner();

    }

    private void initDeviceScanner() {

        /*final Handler mainHandler = new Handler(Looper.getMainLooper());
        updateFuture = Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {

                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {

                        // THis code runs again and again after some time laps.
                        // Remove device incase of outof range.
                        //each thread scheduled for 2 cycle
                        try {
                            if (!isThreadScheduled) {
                                isThreadScheduled = true;
                                ((MainActivity) getActivity()).isTabUpdating = true;
                                mNewRSSIList.clear();
                                if (mNewRSSIList.size() == 0) {
                                    mNewRSSIList = new ArrayList<>(Utils.readRssiDataInRecycler(getActivity(), unprovisionedRecyclerAdapter, layRecycler));
                                    ((MainActivity) getActivity()).isTabUpdating = false;
                                }
                            } else {

                                isThreadScheduled = false;
                                ((MainActivity) getActivity()).isTabUpdating = true;
                                ArrayList<Nodes> nodes = Utils.removeDeviceIfRssiUnchanged(getActivity(), unprovisionedRecyclerAdapter, layRecycler, mNewRSSIList);

                                if (nodes.size() > 0) {
                                    for (int j = 0; j < nodes.size(); j++) {
                                        for (int i = 0; i < mUnprovisionedData.size(); i++) {
                                            if (mUnprovisionedData.get(i).getAddress().equalsIgnoreCase(nodes.get(j).getAddress())) {
                                                final Nodes removeNode = nodes.get(j);
                                                mUnprovisionedData.remove(i);
                                                getActivity().runOnUiThread(new Runnable() {
                                                    @Override
                                                    public void run() {
                                                        //unprovisionedRecyclerAdapter.notifyItemRemoved(removeNode.getNodeNumber());
                                                        if (unprovisionedRecyclerAdapter.getItemCount() == 0) {
                                                            lytWarningDeviceDiscovery.setVisibility(View.VISIBLE);
                                                            pulsator.start();
                                                        }
                                                    }
                                                });
                                            }
                                        }
                                    }
                                }

                                ((MainActivity) getActivity()).isTabUpdating = false;
                            }
                        } catch (Exception e) {
                        }
                    }
                });
            }
        }, 1000, 2500, TimeUnit.MILLISECONDS);*/

    }

    public void startScanAnimation() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                pulsator.start();
            }
        });
    }

    public void updateUnprovisionedList(Nodes deviceDiscovered, boolean isRemove) {

        if(deviceDiscovered != null)
        {
            boolean isAddedInList = false;
            boolean isAddedInAdapter = false;
            int position = -1;
            for (int i = 0; i < mUnprovisionedData.size(); i++) {
                if (mUnprovisionedData.get(i).getAddress().equals(deviceDiscovered.getAddress())) {
                    position = i;
                    isAddedInList = true;
                    break;
                }
            }

            if(unprovisionedRecyclerAdapter.getItemCount() > 0)
            {
                isAddedInAdapter = Utils.isDeviceAlreadyAdded(getActivity(),unprovisionedRecyclerAdapter, layRecycler, deviceDiscovered.getAddress());
            }

            if(!isRemove)
            {
                //add
                if (!isAddedInList && !isAddedInAdapter) {
                    Utils.DEBUG(">>>>>>>>>>>>>>>>>>>>> DEVICE APPEARED : >>>>>>>>> " + deviceDiscovered.getAddress());
                    mUnprovisionedData.add(deviceDiscovered);
                    final int positionX = mUnprovisionedData.size() - 1;
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            lytWarningDeviceDiscovery.setVisibility(View.GONE);
                            unprovisionedRecyclerAdapter.notifyItemInserted(unprovisionedRecyclerAdapter.getItemCount());
                        }
                    });

                }
            }
            else
            {
                //remove
                if (isAddedInList && isAddedInAdapter) {
                    Utils.DEBUG(">>>>>>>>>>>>>>>>>>>>> DEVICE Removed : >>>>>>>>> " + deviceDiscovered.getAddress());
                    mUnprovisionedData.remove(position);
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            unprovisionedRecyclerAdapter.notifyItemRemoved(itemPosition);
                            if(unprovisionedRecyclerAdapter.getItemCount() == 0)
                            {
                                lytWarningDeviceDiscovery.setVisibility(View.VISIBLE);
                            }
                        }
                    });

                }
            }
        }
        else
        {
            mUnprovisionedData.clear();
            unprovisionedRecyclerAdapter.notifyDataSetChanged();
        }

    }

    public void updateRssiUI(final String bt_addr, final int mRssi) {

        boolean isDevicePresent = false;

        if (mUnprovisionedData.size() > 0) {
            for (int i = 0; i < mUnprovisionedData.size(); i++) {

                if (mUnprovisionedData.get(i).getAddress().equalsIgnoreCase(bt_addr)) {
                    isDevicePresent = true;
                    //mUnprovisionedData.get(i).setRssi(String.valueOf(mRssi));
                    break;
                }
            }

            if (isDevicePresent) {
                new Handler().post(new Runnable() {
                    @Override
                    public void run() {
                        final int position = Utils.getRowAdapterPosition(getActivity(), unprovisionedRecyclerAdapter, layRecycler, bt_addr, mRssi);
                        getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                unprovisionedRecyclerAdapter.notifyItemChanged(position, String.valueOf(mRssi));
                            }
                        });

                    }
                });
            }
        }

    }

    public static UnprovisionedFragment newInstance() {

        if( fragment == null ) {
            fragment = new UnprovisionedFragment();
        }
        return fragment;
    }

}
