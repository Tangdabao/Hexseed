/**
 * *****************************************************************************
 *
 * @file BleMEshSettingsFragement.java
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

import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.GenericLevelModelClient;
import com.msi.moble.mobleAddress;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.UserApplication;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.adapter.ElementModelRecyclerAdapter;
import com.st.bluenrgmesh.adapter.ProvisionedNodeSettingAdapter;
import com.st.bluenrgmesh.adapter.PublicationListAdapter;
import com.st.bluenrgmesh.adapter.group.PubGrpSettingAdapter;
import com.st.bluenrgmesh.adapter.SubListForGroupAdapter;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Model;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.models.meshdata.Publish;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by sharma01 on 9/11/2018.
 */

public class BleMeshSettingsFragment extends BaseFragment {

    private View view;
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
    private AppDialogLoader loader;
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
    static SharedPreferences pref_model_selection;
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
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_setting_changename, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        Utils.updateActionBarForFeatures(getActivity(), new ChangeNameFragment().getClass().getName());
        updateJsonData();
        initUi();

        return view;
    }

    private void updateJsonData() {

    }

    private void initUi() {


    }
}
