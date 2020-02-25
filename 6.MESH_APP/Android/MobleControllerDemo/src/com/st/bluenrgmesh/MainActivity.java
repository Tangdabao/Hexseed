/**
 * *****************************************************************************
 *
 * @file MainActivity.java
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
 * BlueNRG-Mesh is based on MotorolaÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 * <p>
 * *****************************************************************************
 */

package com.st.bluenrgmesh;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.Vibrator;
import android.provider.Settings;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.NavigationView;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.msi.moble.ApplicationParameters;
import com.msi.moble.ConfigurationModelClient;
import com.msi.moble.CustomProvisioning;
import com.msi.moble.Device;
import com.msi.moble.DeviceCollection;
import com.msi.moble.mobleAddress;
import com.msi.moble.mobleNetwork;
import com.msi.moble.mobleProvisioningStatus;
import com.msi.moble.mobleSettings;
import com.msi.moble.mobleStatus;
import com.st.bluenrgmesh.logger.JsonUtil;
import com.st.bluenrgmesh.logger.LoggerConstants;
import com.st.bluenrgmesh.logger.RepositoryObserver;
import com.st.bluenrgmesh.logger.Subject;
import com.st.bluenrgmesh.logger.UserDataRepository;
import com.st.bluenrgmesh.models.clouddata.CloudResponseData;
import com.st.bluenrgmesh.models.clouddata.LoginData;
import com.st.bluenrgmesh.models.meshdata.Element;
import com.st.bluenrgmesh.models.meshdata.Features;
import com.st.bluenrgmesh.models.meshdata.Group;
import com.st.bluenrgmesh.models.meshdata.MeshRootClass;
import com.st.bluenrgmesh.models.meshdata.Nodes;
import com.st.bluenrgmesh.models.meshdata.NodesUUID;
import com.st.bluenrgmesh.models.meshdata.settings.NodeSettings;
import com.st.bluenrgmesh.parser.ParseManager;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.utils.MyDrawerLayout;
import com.st.bluenrgmesh.utils.MyJsonObjectRequest;
import com.st.bluenrgmesh.logger.LoggerFragment;
import com.st.bluenrgmesh.view.fragments.other.About;
import com.st.bluenrgmesh.view.fragments.other.SplashScreenFragment;
import com.st.bluenrgmesh.view.fragments.base.BFragment;
import com.st.bluenrgmesh.view.fragments.cloud.login.ChangePasswordFragment;
import com.st.bluenrgmesh.view.fragments.cloud.login.LoginDetailsFragment;
import com.st.bluenrgmesh.view.fragments.cloud.login.SignUpFragment;
import com.st.bluenrgmesh.view.fragments.setting.AddGroupFragment;
import com.st.bluenrgmesh.view.fragments.setting.ChangeNameFragment;
import com.st.bluenrgmesh.view.fragments.setting.ExchangeConfigFragment;
import com.st.bluenrgmesh.view.fragments.setting.GroupSettingFragment;
import com.st.bluenrgmesh.view.fragments.setting.NodeSettingFragment;
import com.st.bluenrgmesh.view.fragments.tabs.GroupTabFragment;
import com.st.bluenrgmesh.view.fragments.tabs.MainViewPagerFragment;
import com.st.bluenrgmesh.view.fragments.tabs.ModelTabFragment;
import com.st.bluenrgmesh.view.fragments.tabs.ProvisionedTabFragment;
import com.st.bluenrgmesh.view.fragments.tabs.UnprovisionedFragment;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import static android.Manifest.permission.ACCESS_FINE_LOCATION;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

/**
 * Provide the main activity of the Application.
 */
public class MainActivity extends AppCompatActivity implements RepositoryObserver {

    private static final int PERMISSION_SETTING = 3000;
    public static final int SUBSCRIPTION_CASE = 0;
    public static final int PUBLICATION_CASE = 1;
    public LostConnectionDialog mLostConnectionDialog = new LostConnectionDialog(this);
    public UnknownDeviceNotificationDialog mUnknownDeviceDialog = new UnknownDeviceNotificationDialog(this);
    public IdentifyDialog mIdentifyDialog = new IdentifyDialog(this);
    public MyHandler mHandler = new MyHandler(this);
    public static final int MSG_UPDATE_LIST = 0;
    public static final int MSG_TOAST = 1;
    public static final int MSG_CONFIG = 2;
    public static final int MSG_DEVICE_APPEARED = 3;
    public static final int MSG_EXCEPTION = 4;
    public static final int MSG_HIDE_PROGRESS = 5;
    public final static int MSG_ENABLE_BLUETOOTH = 7;
    public final static int MSG_UNKNOWN_DEVICE_NOTIFICATION = 8;
    public static final int MSG_UPDATE_RSSI = 9;
    public static final int FILE_SELECT_CODE = 10;
    public final static int MSG_UPDATE_NETWORK_STATUS = 11;
    public final static int MSG_OUT_OF_RANGE = 12;
    private static final int PROVSIONING_RESULT_CODE = 200;
    public static final int UPDATE_GROUP_DATA_RESULT_CODE = 101;
    public static final int UNPROVISION_SUCCESS_RESULT_CODE = 102;
    public static final String DEFAULT_NAME = "New Node";
    public BottomNavigationView navigation;
    public static final int PROVISIONING_IDENTIFY_DURATION = 10;
    public static final int COMPLETION_DELAY = 2000; //User Configurable as per Different Phones
    public static int mCustomGroupId = 0xC004; //This needs to be chenaged for every new group.Increment it.
    SharedPreferences pref;
    SharedPreferences.Editor editor;
    private mobleSettings mSettings;
    private String mAutoAddress;
    private String mAutoName;
    private DeviceEntry mAutoDevice;
    public static List<Map<String, Object>> mData = new ArrayList<>();
    private Collection<Device> mConfigured;
    private Collection<Device> mUnconfigured;
    DeviceCollection collectionD;
    int provisioningStep;
    private String mProxyAddress;
    private Object mCookies;
    private boolean isNear = false;
    public boolean rel_unrel = false;
    private static final int PERMISSION_REQUEST_CODE = 1;
    private static ArrayList<String> mSections = new ArrayList<String>();
    boolean mProvisioningInProgress = false;
    public int count = 0;
    boolean statusOfGPS;
    public List<Map<String, Object>> mDataUnprovisioned = new ArrayList<>();
    public static int tab = 1;
    final static int MSG_UPDATE_RELIABLE_NODE_ROW = 13;
    public MeshRootClass meshRootClass;
    private int elementsSize;
    private Nodes currentNode;
    private static boolean isElementSubscribing;
    private static boolean isElementPublishing;
    private int elementCount;
    private ArrayList<Element> newElements;
    private CustomProvisioning mcp;
    static boolean model_selected = true;
    ArrayList<NodesUUID> nodesUUIDS = new ArrayList<>();
    public AppDialogLoader loader;
    private int nodeNumber;
    private MyDrawerLayout drawer;
    private NavigationView navigationView;
    private static final int ENABLE_BT_ACTIVITY = 4;
    public int tabSelected;
    private Map currentDeviceDiscovered = null;
    private View headerView;
    private Vibrator vibrator;
    private TextView txtLogin;
    private TextView txtSignUp;
    private RelativeLayout lytShareConfig;
    private RelativeLayout lytLoadConfig;
    private RelativeLayout lytForgotNetwork;
    private RelativeLayout lytAbout;
    private RelativeLayout lytAppSettings;
    private RelativeLayout lytPrivacyPolicy;
    private RelativeLayout lytHelp;
    private RelativeLayout lytNotLoggedIn;
    private RelativeLayout lytLoggedIn, loggerRL;
    private TextView txtLogout;
    private TextView txtLoginName;
    private static String uniqueID = null;
    private Integer mGreetingTip = null;
    public static boolean isFromCreateNetwork;
    public static boolean isFromJoinNetwork;
    //SharedPreferences pref_model_selection;
    SharedPreferences.Editor editor_model_selection;
    public static int provisionerUnicastLowAddress = 1;        ////default provisioner low range
    public static int provisionerUnicastHighAddress = 100;     ////default provisioner high range
    public static int provisionerGroupLowAddress = 49153;     ////default provisioner high range
    public static int provisionerGroupHighAddress = 49353;     ////default provisioner high range
    public ArrayList<Nodes> mUnprovisionedList = new ArrayList<>();
    public boolean isProvisioningProcessLive = false;
    public boolean isTabUpdating = true;
    private RelativeLayout lytCloudInteraction;
    private Switch vendor_generic_switch;
    private RelativeLayout lytExchngMeshConfig;
    private TextView txtForgotPassword;
    public static mobleNetwork network;
    public UserApplication app;
    private boolean is_bluetooth_pop = false;
    private boolean is_gps_pop = false;
    private String name;
    private int element_counter = 2; //element_counter is treated as element address
    private boolean tabUiInitialised = false;
    public Subject mUserDataRepository;
    private int publication_first_time = 0;
    private BluetoothAdapter mBluetoothAdapter;
    private mobleAddress nextElementAddress;
    private boolean isAdvised = false;
    public int PROVISIONED_TAB = 1;
    private Switch reliable_switch;
    public static String mCid = "";
    public static String mPid = "";
    public static String mVid = "";
    public static String mCrpl = "";
    private Nodes nodeSelected = null;
    private final BroadcastReceiver bluetoothReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                if (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1)
                        == BluetoothAdapter.STATE_OFF) {
                    is_bluetooth_pop = false;
                    enableBluetooth();
                }
            }
        }
    };

    private BroadcastReceiver gpsReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (LocationManager.PROVIDERS_CHANGED_ACTION.equals(action)) {
                //enableBluetooth();
                // Refresh main activity upon close of dialog box
                Intent refresh = new Intent(MainActivity.this, MainActivity.class);
                startActivity(refresh);
                finishAffinity();
            }
        }
    };

    BroadcastReceiver internetReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            TextView txtInternetWarning = (TextView) findViewById(R.id.txtInternetWarning);
            if (Utils.isOnline(context)) {
                txtInternetWarning.setVisibility(View.GONE);
            } else {

                txtInternetWarning.setVisibility(View.VISIBLE);
            }
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        registerObersever();
        Utils.contextMainActivity = MainActivity.this;
        loader = AppDialogLoader.getLoader(this);

        regitserReceiver();
        getViewReference();
        updateJsonData();
        moveToSplashFragment();
        /*new Handler().post(new Runnable() {
            @Override
            public void run() {
                Utils.screenWidgetsIntro(MainActivity.this, R.id.tab_layoutt);
            }
        });*/
        //moveToTabFragment();
    }

    private void moveToSplashFragment() {
        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        Fragment f = new SplashScreenFragment();
        transaction.add(R.id.lytMain, f);
        transaction.commit();
    }

    public void moveToTabFragment() {

        if (!tabUiInitialised) {
            tabUiInitialised = true;
            FragmentManager manager = getSupportFragmentManager();
            FragmentTransaction transaction = manager.beginTransaction();
            Fragment f = new MainViewPagerFragment();
            transaction.add(R.id.lytMain, f, new MainViewPagerFragment().getClass().getName());
            transaction.commitAllowingStateLoss();
        }
    }

    private void regitserReceiver() {

        if (internetReceiver != null && getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
            registerReceiver(internetReceiver, new IntentFilter("android.net.conn.CONNECTIVITY_CHANGE"));
        }
        if (bluetoothReceiver != null) {
            registerReceiver(bluetoothReceiver, new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED));
        }
        if (gpsReceiver != null) {
            registerReceiver(gpsReceiver, new IntentFilter(LocationManager.PROVIDERS_CHANGED_ACTION));
        }

    }

    public void enablePermissions() {

        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Utils.showToast(this, getResources().getString(R.string.str_ble_not_supported));
            finish();
        }
        if (!checkGPS()) {
            //turn on gps from onResume
            //turnGPSOn();
        } else if (BluetoothAdapter.getDefaultAdapter().getState() != BluetoothAdapter.STATE_ON) {
            enableBluetooth();
        } else {
            moveToTabFragment();
            new Handler().post(new Runnable() {
                @Override
                public void run() {
                    startNetwork();
                }
            });
        }
    }

    public void enableBluetooth() {
        if (mProvisioningInProgress) {
            mProvisioningInProgress = false;
            mSettings.cancel();
        }

        if (!is_bluetooth_pop) {
            is_bluetooth_pop = true;
            mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            if (mBluetoothAdapter == null) {
                Utils.showToast(MainActivity.this, "Device doesn't support bluetooth.");
            } else {
                if (!mBluetoothAdapter.isEnabled()) {
                    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                    startActivityForResult(enableBtIntent, ENABLE_BT_ACTIVITY);
                }
            }

        }
    }

    public boolean checkGPS() {
        LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        boolean GpsStatus = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        if (!GpsStatus) {
            return getLocationMode(MainActivity.this) != Settings.Secure.LOCATION_MODE_OFF;
        } else {
            return GpsStatus;
        }
    }

    private static int getLocationMode(Context context) {
        return Settings.Secure.getInt(context.getContentResolver(), Settings.Secure.LOCATION_MODE, Settings.Secure.LOCATION_MODE_OFF);
    }


    public void turnGPSOn() {

        LocationManager service = (LocationManager) getSystemService(LOCATION_SERVICE);
        boolean enabled = service
                .isProviderEnabled(LocationManager.GPS_PROVIDER);
        if (!enabled) {
            AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(
                    this);
            alertDialogBuilder
                    .setIcon(getResources().getDrawable(R.drawable.ic_settings_bluetooth_black_24dp))
                    .setMessage(getString(R.string.str_gps_enable_label))
                    .setCancelable(false)
                    .setPositiveButton("Enable GPS",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,
                                                    int id) {
                                    if (mProgress != null) {
                                        mProgress.hide();
                                    }
                                    Intent callGPSSettingIntent = new Intent(
                                            android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                    startActivity(callGPSSettingIntent);
                                }
                            });
            alertDialogBuilder.setNegativeButton("Cancel",
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.cancel();
                            finishAffinity();
                        }
                    });
            final AlertDialog alert = alertDialogBuilder.create();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    alert.show();
                }
            });

        }

    }

    private void startNetwork() {

        LoginData loginData = null;
        try {
            loginData = ParseManager.getInstance().fromJSON(new JSONObject(Utils.getLoginData(MainActivity.this)), LoginData.class);
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (Exception e) {

        }

        try {
            if (Utils.isUserLoggedIn(MainActivity.this) && getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
                //restart session
                if (Utils.isOnline(MainActivity.this)) {
                    Utils.showToast(MainActivity.this, "Establishing cloud network...");
                    callLoginApi(loginData.getUserName(), loginData.getUserPassword());
                } else {
                    resumeNetworkAndCallbacks("", meshRootClass.getMeshUUID(), false);
                }

            } else {
                Utils.showToast(MainActivity.this, "Establishing local network...");
                if (Utils.getNetKey(MainActivity.this) == null) {

                    if (meshRootClass == null) {
                        //first
                        createNewNetwork(getString(R.string.str_ble_mesh_label), "", true);
                    }
                } else {
                    resumeNetworkAndCallbacks("", meshRootClass.getMeshUUID(), false);
                }
            }
        } catch (Exception e) {
        }
    }

    private void getViewReference() {

        vibrator = Utils.getVibrator(MainActivity.this);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbarMain);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        ImageView imgDrawerIcon = (ImageView) findViewById(R.id.imgActionBarDrawerIcon);
        imgDrawerIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openDrawer();
            }
        });
        drawer = (MyDrawerLayout) findViewById(R.id.drawer_layout);
        //setDrawableLockMode(drawer, DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        ActionBarDrawerToggle mDrawerToggle = new ActionBarDrawerToggle(
                this,
                drawer,
                toolbar,
                R.string.navigation_drawer_open,
                R.string.navigation_drawer_close
        ) {

            @Override
            public void onDrawerClosed(View drawerView) {

                //super.onDrawerClosed(drawerView);
                closeDrawer();
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                //super.onDrawerOpened(drawerView);
                openDrawer();
            }
        };
        drawer.setDrawerListener(mDrawerToggle);
        navigationView = (NavigationView) findViewById(R.id.nav_view);
        headerView = navigationView.getHeaderView(0);
        lytCloudInteraction = (RelativeLayout) headerView.findViewById(R.id.lytCloudInteraction);
        lytCloudInteraction.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                //Utils.moveToFragment(MainActivity.this, new CloudInteractionFragment(), null, 0);

            }
        });
        lytNotLoggedIn = (RelativeLayout) headerView.findViewById(R.id.lytNotLoggedIn);
        lytLoggedIn = (RelativeLayout) headerView.findViewById(R.id.lytLoggedIn);
        txtForgotPassword = (TextView) headerView.findViewById(R.id.txtForgotPassword);
        txtForgotPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                closeDrawer();
                Utils.moveToFragment(MainActivity.this, new ChangePasswordFragment(), null, 0);
            }
        });
        txtLoginName = (TextView) headerView.findViewById(R.id.txtLoginName);
        txtLogout = (TextView) headerView.findViewById(R.id.txtLogout);
        txtLogout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //logout api
                closeDrawer();
                Utils.DEBUG("Userkey : " + Utils.getUserLoginKey(MainActivity.this));
                callLogoutApi(Utils.getUserLoginKey(MainActivity.this));
            }
        });
        txtLogin = (TextView) headerView.findViewById(R.id.txtLogin);
        txtLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                if (getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
                    Utils.moveToFragment(MainActivity.this, new LoginDetailsFragment(), null, 0);
                } else {
                    Utils.showPopUpForMessage(MainActivity.this, getString(R.string.str_error_Gatt_Not_Responding));
                }

            }
        });
        txtSignUp = (TextView) headerView.findViewById(R.id.txtSignUp);
        txtSignUp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                if (getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
                    Utils.moveToFragment(MainActivity.this, new SignUpFragment(), null, 0);
                } else {
                    Utils.showPopUpForMessage(MainActivity.this, getString(R.string.str_error_Gatt_Not_Responding));
                }
            }
        });
        loggerRL = (RelativeLayout) headerView.findViewById(R.id.loggerRL);
        lytShareConfig = (RelativeLayout) headerView.findViewById(R.id.lytShareConfig);
        lytLoadConfig = (RelativeLayout) headerView.findViewById(R.id.lytLoadConfig);
        lytForgotNetwork = (RelativeLayout) headerView.findViewById(R.id.lytForgotNetwork);
        lytAbout = (RelativeLayout) headerView.findViewById(R.id.lytAbout);
        loggerRL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                /*Intent  i = new Intent(MainActivity.this, LoggerActivity.class);*/
                Utils.moveToFragment(MainActivity.this, new LoggerFragment(), null, 0);
            }
        });
        lytShareConfig.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                sendDataOverMail();
            }
        });
        lytLoadConfig.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                action_config_setting();
            }
        });
        lytForgotNetwork.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Utils.showPopUp(MainActivity.this, new MainActivity().getClass().getName(), true, true, getResources().getString(R.string.str_delete_mesh_data), getResources().getString(R.string.str_setting_reset));
            }
        });
        lytAbout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (vibrator != null) vibrator.vibrate(40);
                Utils.moveToFragment(MainActivity.this, new About(), null, 0);

            }
        });
        lytAppSettings = (RelativeLayout) headerView.findViewById(R.id.lytAppSettings);
        lytAppSettings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (vibrator != null) vibrator.vibrate(40);
                Utils.moveToFragment(MainActivity.this, new ChangeNameFragment(), null, 0);
            }
        });

        lytHelp = (RelativeLayout) headerView.findViewById(R.id.lytHelp);
        lytHelp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                vibrator = (Vibrator) MainActivity.this.getSystemService(Context.VIBRATOR_SERVICE);
                if (vibrator != null) vibrator.vibrate(40);

                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.str_helppdf)));
                startActivity(intent);
            }
        });

        lytPrivacyPolicy = (RelativeLayout) headerView.findViewById(R.id.lytPrivacyPolicy);
        lytPrivacyPolicy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                final Dialog dialog = new Dialog(MainActivity.this);
                dialog.setContentView(R.layout.dialog_proxy);
                Window window = dialog.getWindow();
                window.setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

                CardView lytPrivacyPolicy = (CardView) dialog.findViewById(R.id.lytPrivacyPolicy);
                lytPrivacyPolicy.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        vibrator = (Vibrator) MainActivity.this.getSystemService(Context.VIBRATOR_SERVICE);
                        if (vibrator != null) vibrator.vibrate(40);

                        String url = getString(R.string.str_policy_html);
                        Intent i = new Intent(Intent.ACTION_VIEW);
                        i.setData(Uri.parse(url));
                        startActivity(i);
                    }
                });

                CardView lytUrRights = (CardView) dialog.findViewById(R.id.lytUrRights);
                lytUrRights.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        vibrator = (Vibrator) MainActivity.this.getSystemService(Context.VIBRATOR_SERVICE);
                        if (vibrator != null) vibrator.vibrate(40);

                        String url = getString(R.string.str_trust_hash);
                        Intent i = new Intent(Intent.ACTION_VIEW);
                        i.setData(Uri.parse(url));
                        startActivity(i);
                    }
                });
                dialog.show();
            }
        });

        vendor_generic_switch = (Switch) headerView.findViewById(R.id.vendor_generic_switch);
        reliable_switch = (Switch) headerView.findViewById(R.id.reliable_switch);
        if (Utils.isReliableEnabled(MainActivity.this)) {
            reliable_switch.setChecked(true);
        } else {
            reliable_switch.setChecked(false);
        }

        if (Utils.isReliableEnabled(MainActivity.this)) {
            vendor_generic_switch.setChecked(true);
        } else {
            reliable_switch.setChecked(false);
        }

        vendor_generic_switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean vendorModelSelection) {

                Utils.setVendorModelCommand(MainActivity.this, vendorModelSelection);
            }
        });

        lytExchngMeshConfig = (RelativeLayout) headerView.findViewById(R.id.lytExchngMeshConfig);
        lytExchngMeshConfig.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Utils.moveToFragment(MainActivity.this, new ExchangeConfigFragment(), null, 0);
            }
        });

        reliable_switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                rel_unrel = b;
                Utils.setReliable(MainActivity.this, b);
            }
        });

        Switch user_help_switch = (Switch) headerView.findViewById(R.id.user_help_switch);
        user_help_switch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (buttonView.isChecked()) {
                    Utils.setHelpGuideData(getApplicationContext(), true);
                } else {
                    Utils.setHelpGuideData(getApplicationContext(), false);
                }
            }
        });

        ((UserApplication) getApplication()).setActivity(this);
        Utils.controlNavigationDrawer(MainActivity.this, null, DrawerLayout.LOCK_MODE_UNLOCKED);

    }

    public void closeDrawer() {

        drawer.closeDrawer(GravityCompat.START);
    }

    public void openDrawer() {
        Utils.DEBUG("MainActivity >> openDrawer() >> called ");
        //first check user login status and change UI accordingly
        updateUIForLogin();
        drawer.openDrawer(GravityCompat.START);
    }

    private void updateUIForLogin() {

        if (Utils.isUserLoggedIn(this) && getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
            lytLoggedIn.setVisibility(View.VISIBLE);
            lytNotLoggedIn.setVisibility(View.GONE);
            try {
                LoginData loginData = ParseManager.getInstance().fromJSON(new JSONObject(Utils.getLoginData(this)), LoginData.class);
                txtLoginName.setText("Welcome " + loginData.getUserName() + " !!");
            } catch (Exception e) {
                Utils.ERROR("MainActivity >> Error while parsing json : " + e.toString());
            }

        } else {
            lytLoggedIn.setVisibility(View.GONE);
            lytNotLoggedIn.setVisibility(View.VISIBLE);
        }

    }

    /* Used to lock navigation drawer*/
    public void setDrawableLockMode(DrawerLayout drawer, int lock) {
        drawer.setDrawerLockMode(lock);
    }

    public void updateJsonData() {

        try {
            String meshData = Utils.getBLEMeshDataFromLocal(MainActivity.this);
            if (meshData != null) {
                Utils.getBLEMeshDataFromLocal(MainActivity.this);
                meshRootClass = ParseManager.getInstance().fromJSON(new JSONObject(meshData), MeshRootClass.class);
                Utils.DEBUG(">> Json Data : " + meshData);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroy() {

        try {
            if (internetReceiver != null && bluetoothReceiver != null) {
                unregisterReceiver(internetReceiver);
                unregisterReceiver(bluetoothReceiver);
                unregisterReceiver(gpsReceiver);
            }
            JsonUtil.ClearLoggerFile(this);
        } catch (IllegalArgumentException e) {
        }
        super.onDestroy();
    }

    public void resumeNetworkAndCallbacks(String meshName, String meshUUIDD,
                                          boolean isNewJoiner) {

        if (BluetoothAdapter.getDefaultAdapter().getState() != BluetoothAdapter.STATE_ON) {
            //mHandler.sendEmptyMessage(MSG_ENABLE_BLUETOOTH);
            enableBluetooth();
        } else if (meshRootClass != null) {
            //create network and advice call bks
            adviceAllCallBacks(meshName, meshUUIDD, isNewJoiner);
        } else {
            //Utils.showPopUp(MainActivity.this, new MainActivity().getClass().getName(), true, false, getResources().getString(R.string.str_create_network_msg_label), getResources().getString(R.string.str_login_import_label));
        }

        if (mGreetingTip != null) {
            Toast.makeText(this, mGreetingTip, Toast.LENGTH_SHORT).show();
        }

    }

    public void adviceAllCallBacks(String meshName, String meshUUIDD,
                                   boolean isNewJoiner) {

        try {
            if (Utils.getProvisionerUnicastLowAddress(MainActivity.this) != null) {
                provisionerUnicastLowAddress = Integer.parseInt(Utils.getProvisionerUnicastLowAddress(MainActivity.this));
            }

            Utils.DEBUG(">>>Current Provisioner Address : " + provisionerUnicastLowAddress);
            Utils.showToast(MainActivity.this, "Resuming previous network state...");

            network = mobleNetwork.restoreNetwork(mobleAddress.deviceAddress(provisionerUnicastLowAddress), meshRootClass.getNetKeys().get(0).getKey(), meshRootClass.getAppKeys().get(0).getKey(), ParseManager.getInstance().toJSON(meshRootClass));

            getNetworkStatusResume();
            app = (UserApplication) getApplication();
            app.mConfiguration = new Configuration();
            app.mConfiguration.setmNetwork(network);

            network.advise(mOnDeviceAppearedCallback);
            network.advise(mProxyConnectionEventCallback);
            network.advise(onDeviceRssiChangedCallback);
            network.advise(onNetworkStatusChanged);

            if (this.getResources().getBoolean(R.bool.bool_packetSniffing)) {
                network.advise(mWriteLocalCallback);
                network.advise(modelCallback_cb);
            }


            if (((UserApplication) getApplication()).start().failed()) {
                mGreetingTip = R.string.moble_start_fail;
                finish();
            }

            String appKeys = Utils.array2string(mobleNetwork.getaAppKey());
            String networkKey = Utils.array2string(mobleNetwork.getaNetworkKey());
            Utils.setNetKey(MainActivity.this, networkKey);
            Utils.setAppKey(MainActivity.this, appKeys);

            String meshUUID = isNewJoiner ? Utils.generateMeshUUID(MainActivity.this, networkKey) : meshUUIDD;


            if (isNewJoiner) {
                Utils.updateProvisionerNetAppKeys(MainActivity.this, meshRootClass, meshName, meshUUID, appKeys, networkKey, false);
            }
            updateJsonData();

        } catch (Exception e) {
        }
    }

    public void sendDataOverMail() {

        //updateJsonData();
        if (Build.VERSION.SDK_INT >= 23) {
            if (checkPermission()) {
                Utils.saveUniversalFilterDataToFile(MainActivity.this);

                //updateJsonData();
                String[] mailAdd = {"e-mail id"};
                File dir = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + "BlueNrgCache");
                File file = new File(dir, "bluenrg-mesh_configuration.json");
                Utils.DEBUG(">> File Exist : " + dir.getAbsolutePath() + " " + file.getAbsolutePath());
                Utils.sendMail(MainActivity.this, mailAdd, null, "BlueNRG-Mesh Configuration File", "Please find configuration file as attachment!.", file.getAbsolutePath().toString());

            } else {
                requestPermission(); // Code for permission
            }
        } else {

            String[] mailAdd = {"e-mail id"};
            File dir = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + "BlueNrgCache");
            File file = new File(dir, "bluenrg-mesh_configuration.json");
            Utils.DEBUG(">> File Exist : " + dir.getAbsolutePath() + " " + file.getAbsolutePath());
            Utils.sendMail(MainActivity.this, mailAdd, null, "BLE MESH FILE", "ATTACHMENT", file.getAbsolutePath().toString());

        }

    }


    public void updateProvisionedTab() {
        fragmentCommunication(new ProvisionedTabFragment().getClass().getName(), null, 0, null, false, null);
    }

    public void updateModelTab() {
        fragmentCommunication(new ModelTabFragment().getClass().getName(), Utils.getSelectedModel(MainActivity.this), 0, null, false, null);
    }

    public void startProvisioning(Nodes node) {
        new Handler().post(new Runnable() {
            @Override
            public void run() {
                try {
                    if (meshRootClass.getGroups() == null || meshRootClass.getGroups().size() == 0) {
                        Utils.addNewGroupToJson(MainActivity.this, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), getString(R.string.str_default_group_label));
                    }
                } catch (Exception e) { }
                updateJsonData();
            }
        });
        nodeSelected = node;
        element_counter = 1;
        unAdviseCallbacks();
        Utils.setsubscriptiongroupAddressOnProvsioning(this, "");
        Utils.setpublicationListAddressOnProvsioning(this, "");
        configureDevice(node.getAddress());
    }

    public void unAdviseCallbacks() {
        if (isAdvised) {
            isAdvised = false;
            try {
                Utils.DEBUG(">> RSSI Call Stopped");
                //app.stop();

                network.unadvise(mOnDeviceAppearedCallback);
                network.unadvise(onNetworkStatusChanged);
                network.unadvise(onDeviceRssiChangedCallback);
                // app.mConfiguration.getNetwork().unadvise(mWriteLocalCallback);
                //app.mConfiguration.getNetwork().unadvise(mOnGattError);
                app.start();

            } catch (Exception e) {
            }
        }
    }

    public void adviseCallbacks() {
        Utils.DEBUG(">> RSSI Call Resume");
        if (!isAdvised) {
            isAdvised = true;
            try {
                network.advise(mOnDeviceAppearedCallback);
                network.advise(mProxyConnectionEventCallback);
                network.advise(onDeviceRssiChangedCallback);
                network.advise(onNetworkStatusChanged);
                if (this.getResources().getBoolean(R.bool.bool_packetSniffing)) {

                    network.advise(mWriteLocalCallback);
                    app.mConfiguration.getNetwork().advise(modelCallback_cb);

                }
                app.start();

            } catch (Exception e) {
            }
        }
    }


    /**
     * Following method used to handle various events w.r.t fragment communication when we need to dynamically update
     * the fragment UI for any fragment screen.
     *
     * @param className
     * @param strData           : This parameter used to store any string data like : address, model name
     * @param anyDigit_Rssi     : This parameter can be used as a number data(RSSI value) , a number that represent case type, a tab number.
     * @param deviceDiscovered
     * @param isScrollViewPager : This parameter used to swipe tab page when needed automatically by system.
     * @param status
     */
    public void fragmentCommunication(String className, String strData, int anyDigit_Rssi, Nodes deviceDiscovered,
                                      boolean isScrollViewPager, ApplicationParameters.Status status) {
        try {
            if (className.equals(new UnprovisionedFragment().getClass().getName())) {
                if (strData == null || /*mRssi*/anyDigit_Rssi == 0) {
                    //update node
                    MainViewPagerFragment mainViewPagerFragment = (MainViewPagerFragment) getSupportFragmentManager().findFragmentByTag(new MainViewPagerFragment().getClass().getName());
                    mainViewPagerFragment.updateFragmentUi(null, 0, new UnprovisionedFragment().getClass().getName(), deviceDiscovered, null);

                } else {
                    //update rssi
                    MainViewPagerFragment mainViewPagerFragment = (MainViewPagerFragment) getSupportFragmentManager().findFragmentByTag(new MainViewPagerFragment().getClass().getName());
                    mainViewPagerFragment.updateFragmentUi(strData, /*mRssi*/anyDigit_Rssi, className, null, null);
                }

            } else if (className.equals(new ProvisionedTabFragment().getClass().getName())) {
                MainViewPagerFragment mainViewPagerFragment = (MainViewPagerFragment) getSupportFragmentManager().findFragmentByTag(new MainViewPagerFragment().getClass().getName());
                mainViewPagerFragment.updateFragmentUi(null, anyDigit_Rssi, className, deviceDiscovered, null);

            } else if (className.equals(new GroupTabFragment().getClass().getName())) {
                MainViewPagerFragment mainViewPagerFragment = (MainViewPagerFragment) getSupportFragmentManager().findFragmentByTag(new MainViewPagerFragment().getClass().getName());
                mainViewPagerFragment.updateFragmentUi(strData, 0, className, null, null);

            } else if (className.equals(new ModelTabFragment().getClass().getName())) {
                MainViewPagerFragment mainViewPagerFragment = (MainViewPagerFragment) getSupportFragmentManager().findFragmentByTag(new MainViewPagerFragment().getClass().getName());

                if (isScrollViewPager) {
                    mainViewPagerFragment.scrollViewPager(/*tab number*/anyDigit_Rssi);
                } else {
                    mainViewPagerFragment.updateFragmentUi(/*model name*/strData, anyDigit_Rssi, className, null, null);
                }
            } else if (className.equals(new GroupSettingFragment().getClass().getName())) {
                GroupSettingFragment groupSettingFragment = (GroupSettingFragment) getSupportFragmentManager().findFragmentByTag(new GroupSettingFragment().getClass().getName());
                groupSettingFragment.updateFragmentUi(strData, anyDigit_Rssi, status);
            } else if (className.equals(new AddGroupFragment().getClass().getName())) {
                AddGroupFragment addGroupFragment = (AddGroupFragment) getSupportFragmentManager().findFragmentByTag(new AddGroupFragment().getClass().getName());
                addGroupFragment.updateFragmentUi(strData, anyDigit_Rssi, status);

            } else if (className.equals(new GroupSettingFragment().getClass().getName())) {
                GroupSettingFragment groupSettingFragment = (GroupSettingFragment) getSupportFragmentManager().findFragmentByTag(new GroupSettingFragment().getClass().getName());
                groupSettingFragment.updateFragmentUi(strData, anyDigit_Rssi, status);

            }
        } catch (Exception e) {
            Utils.DEBUG("Fragment Communication Failed");
        }
    }

    private void configureDevice(String bt_addr) {
        isProvisioningProcessLive = true;
        mAutoName = DEFAULT_NAME;
        setAutoParameters(bt_addr);
        mProgress.show(MainActivity.this, "Provisioning . . . : ", true);
        mHandler.sendEmptyMessage(MSG_CONFIG);
    }

    private void setAutoParameters(final String addr) {
        new Handler().post(new Runnable() {
            @Override
            public void run() {
                DeviceEntry de = ((UserApplication) getApplication()).mConfiguration.getDevice(addr);
                if (de != null) {
                    mAutoDevice = de;
                } else {
                    updateJsonData();

                    try {
                        Collections.sort(meshRootClass.getNodes());
                    } catch (Exception e) {
                    }
                    nodeNumber = Utils.getNextNodeNumber(meshRootClass.getNodes(), meshRootClass);


                    //name = String.format("%s %02d", mAutoName, nodeNumber - 1);
                    name = String.format("%s %02d", mAutoName, nodeNumber);
                    //here : (next node address) = (next node element number) = (missing/deleted node element number)

                    int min = Utils.getNextElementNumber(MainActivity.this, meshRootClass.getNodes());
                    if (min == 0) {
                        makeToast(getString(R.string.network_is_full));
                        return;
                    }
                    mAutoDevice = new DeviceEntry(name, mobleAddress.deviceAddress(min));
                }
                mAutoAddress = addr;
            }
        });

    }

    private static class DialogListener implements DialogInterface.OnClickListener, DialogInterface.OnCancelListener {
        private Runnable clickTask;
        private Runnable cancelTask;

        DialogListener(Runnable clickListener, Runnable cancelListener) {
            clickTask = clickListener;
            cancelTask = cancelListener;
        }

        @Override
        public void onClick(DialogInterface dialogInterface, int i) {
            if (clickTask != null) {
                clickTask.run();
                clickTask = null;
            }
            cancelTask = null;
        }

        @Override
        public void onCancel(DialogInterface dialogInterface) {
            if (cancelTask != null) {
                cancelTask.run();
                cancelTask = null;
            }
            clickTask = null;
        }
    }

    public void action_config_setting() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Warning!");
        builder.setMessage(R.string.warning);
        builder.setPositiveButton(R.string.Yes, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {

                Utils.showFileChooser(MainActivity.this, false);
            }
        });
        builder.setNegativeButton(R.string.No, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        builder.create().show();
    }

    @Override
    public void onBackPressed() {

        Utils.closeKeyboard(MainActivity.this, null);
        updateJsonData();

        int count = getSupportFragmentManager().getBackStackEntryCount();
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else if (count > 0) {
            FragmentManager.BackStackEntry a = getSupportFragmentManager().getBackStackEntryAt(getSupportFragmentManager().getBackStackEntryCount() - 1);//top
            Fragment baseFrag = (Fragment) getSupportFragmentManager().findFragmentByTag(a.getName());
            if (baseFrag instanceof BFragment) {
                ((BFragment) baseFrag).onBackEventPre();
            }

            //control navigation drawer
            //Utils.controlNavigationDrawer(MainActivity.this, a.getName(),DrawerLayout.LOCK_MODE_UNLOCKED);
            //pop back stack
            getSupportFragmentManager().popBackStack();
            //now update action bar, depending upon screen
            try {
                FragmentManager.BackStackEntry entry = null;
                Fragment baseFragment = null;

                if (getSupportFragmentManager().getBackStackEntryCount() == 1) {

                    //update actionbar if hardware b
                    if (baseFrag.getClass().getName().equalsIgnoreCase(new AddGroupFragment().getClass().getName())) {
                        if (!Utils.checkGrpHasSubElements(MainActivity.this, AddGroupFragment.eleSubscriptionList)) {
                            Utils.removeGroupFromJson(MainActivity.this, AddGroupFragment.addr);
                            Utils.showPopUpForMessage(MainActivity.this, AddGroupFragment.addr + " " + getString(R.string.str_addgroupmsg_label));
                        }
                        fragmentCommunication(new GroupTabFragment().getClass().getName(), null, 0, null, false, null);
                        Utils.updateActionBarForFeatures(MainActivity.this, new GroupTabFragment().getClass().getName());
                        updateJsonData();
                    } else if (baseFrag.getClass().getName().equalsIgnoreCase(new GroupSettingFragment().getClass().getName())) {
                        //fragmentCommunication(new GroupTabFragment().getClass().getName(), null, 0, null, false, null);
                        Utils.updateActionBarForFeatures(MainActivity.this, new GroupTabFragment().getClass().getName());
                        //updateJsonData();
                    } else {
                        Utils.updateActionBarForFeatures(this, new MainViewPagerFragment().getClass().getName());
                        //back from login page
                        try {
                            if (!Utils.isUserLoggedIn(MainActivity.this) && meshRootClass.getMeshUUID().equals("")) {
                                Utils.showPopUp(MainActivity.this, new MainActivity().getClass().getName(), true, false, getResources().getString(R.string.str_create_network_msg_label), getResources().getString(R.string.str_login_import_label));
                            }
                        } catch (Exception e) {
                            Utils.showPopUp(MainActivity.this, new MainActivity().getClass().getName(), true, false, getResources().getString(R.string.str_create_network_msg_label), getResources().getString(R.string.str_login_import_label));
                        }
                    }

                } else {
                    entry = getSupportFragmentManager().getBackStackEntryAt(getSupportFragmentManager().getBackStackEntryCount() - 2);
                    baseFragment = (Fragment) getSupportFragmentManager().findFragmentByTag(entry.getName());
                    Utils.updateActionBarForFeatures(this, entry.getName());
                    if (baseFrag instanceof BFragment) {
                        ((BFragment) baseFragment).onFocusEvent();
                    }
                }

            } catch (Exception e) {

            }
            if (baseFrag instanceof BFragment) {
                ((BFragment) baseFrag).onBackEventPost();
            }
            Utils.hideKeyboard(this, baseFrag.getView());
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onResume() {

        //if user clicks cancel button on gps dialog
        if (!checkGPS()) {
            turnGPSOn();
        }

        new Handler().post(new Runnable() {
            @Override
            public void run() {
                updateJsonData();
                try {
                    //post event update
                    if (tabSelected == 1) {
                        //runs at the time of unprovisioning
                        updateProvisionedTab();
                    } else if (tab == 2) {
                        //groupTabNew();
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        super.onResume();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        ((UserApplication) getApplication()).setActivity(this);

        switch (requestCode) {
            case PERMISSION_SETTING:
                enablePermissions();
                break;
            case ENABLE_BT_ACTIVITY:
                if (resultCode == RESULT_OK) {
                    moveToTabFragment();
                    new Handler().post(new Runnable() {
                        @Override
                        public void run() {
                            startNetwork();
                        }
                    });
                } else {
                    makeToast("Unable to start Bluetooth");
                    UserApplication.trace("System request to turn Bluetooth on has been denied by user");
                    finish();
                }
                break;
            case FILE_SELECT_CODE:
                if (resultCode == RESULT_OK) {
                    try {
                        Uri uri = data.getData();

                        String path = Utils.getPath(MainActivity.this, uri);

                        ((UserApplication) getApplication()).load(path);
                        ((UserApplication) getApplication()).setActivity(this);

                        if (Utils.checkConfiguration(MainActivity.this)) {
                            ((UserApplication) getApplication()).stop();

                            network.advise(mOnDeviceAppearedCallback);
                            network.advise(mProxyConnectionEventCallback);
                            ((UserApplication) getApplication()).mConfiguration.getNetwork().advise(onDeviceRssiChangedCallback);
                            ((UserApplication) getApplication()).start();
                            mProgress.show(MainActivity.this, false);

                            //updateRequest(true);
                        } else {
                            try {
                                createNewNetwork("", meshRootClass.getMeshUUID(), false);
                            } catch (Exception e) {
                            }

                        }
                    } catch (URISyntaxException e) {
                        e.printStackTrace();
                    }
                }
                break;
            case 600:
            case 700:
                if (resultCode == RESULT_OK) {
                    mProgress.show(MainActivity.this, false);

                    //updateRequest(true);
                }
                break;
            case UPDATE_GROUP_DATA_RESULT_CODE:
                if (resultCode == RESULT_OK) {
                    //Update GroupTabFragment to show new added group
                    fragmentCommunication(new GroupTabFragment().getClass().getName(), null, 0, null, false, null);
                }
                break;
            case UNPROVISION_SUCCESS_RESULT_CODE:
                try {
                    if (resultCode == RESULT_OK) {
                        //update unprovision data in all list
                        clearUnprovisionList();

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case 60:
                break;
            case PROVSIONING_RESULT_CODE:

                provisioningStep++;
                mProvisionerStateChanged.onStateChanged(provisioningStep + 1, "");
                setCurrentNode(false);
                new Handler().post(new Runnable() {
                    @Override
                    public void run() {
                        adviseCallbacks();
                    }
                });
                new Handler().post(new Runnable() {
                    @Override
                    public void run() { doRestProvisionSubscription(0);
                    }
                });
                break;
        }
    }

    public void clearUnprovisionList() {
        //mData.clear();
        //mDataUnprovisioned.clear();
        mUnprovisionedList.clear();
    }

    public void createNewNetwork(String meshName, String meshUUIDD, boolean isNewJoiner) {

        app = (UserApplication) getApplication();
        app.mConfiguration = new Configuration(mobleAddress.deviceAddress(provisionerUnicastLowAddress));
        network = app.mConfiguration.getNetwork();
        getNetworkStatusBefore();
        network.advise(mOnDeviceAppearedCallback);
        network.advise(mProxyConnectionEventCallback);
        network.advise(onDeviceRssiChangedCallback);
        network.advise(onNetworkStatusChanged);
        network.advise(mWriteLocalCallback);
        app.start();
        getNetworkStatusAfter();
        mobleAddress address = mobleAddress.groupAddress(((UserApplication) getApplication()).mConfiguration.getGroupMinAvailableAddress() | mobleAddress.GROUP_HEADER);
        app.mConfiguration.addGroup(address, new GroupEntry(getString(R.string.str_default_group_label)));
        app.save();
        updateProvisionerProperties(meshName, meshUUIDD, isNewJoiner);
    }

    private void getNetworkStatusAfter() {
        if (network.start(this) == mobleStatus.FAIL) {
            mUserDataRepository.getNewDataFromRemote("Network Started Failed!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Ver=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);
        } else {
            mUserDataRepository.getNewDataFromRemote("Network Started!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Ver=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);
        }
    }

    public void getNetworkStatusBefore() {
        if (app.mConfiguration != null && network != null) {
            mUserDataRepository.getNewDataFromRemote("Network Created!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Ver=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);
        } else {
            mUserDataRepository.getNewDataFromRemote("Network failed!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Ver=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);

        }
    }


    public void getNetworkStatusResume() {
        if (network != null) {
            mUserDataRepository.getNewDataFromRemote("Network Restored!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Version=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);
        } else {

            mUserDataRepository.getNewDataFromRemote("Network Restored failed!\n" + "Lib Ver=>" + mobleNetwork.getlibversion() + "\nApp Version=>" + BuildConfig.VERSION_NAME, LoggerConstants.TYPE_NONE);
        }

    }

    private void updateProvisionerProperties(String meshName, String meshUUIDD,
                                             boolean isNewJoiner) {

        String appKeys = Utils.array2string(mobleNetwork.getaAppKey());
        String networkKey = Utils.array2string(mobleNetwork.getaNetworkKey());
        //String meshUUID = isNewJoiner ? meshUUIDD : Utils.generateMeshUUID(MainActivity.this, networkKey);
        String meshUUID = isNewJoiner ? Utils.generateMeshUUID(MainActivity.this, networkKey) : meshUUIDD;
        Utils.setNetKey(MainActivity.this, networkKey);
        Utils.setAppKey(MainActivity.this, appKeys);
        //setup provisioner
        int provisonerUnicastRange = provisionerUnicastHighAddress - provisionerUnicastLowAddress;
        Utils.setProvisionerUnicastLowAddress(MainActivity.this, String.valueOf(provisionerUnicastLowAddress));
        Utils.setProvisionerUnicastHighAddress(MainActivity.this, String.valueOf(provisionerUnicastHighAddress));
        Utils.setProvisionerGroupLowAddress(MainActivity.this, String.valueOf(provisionerGroupLowAddress));
        Utils.setProvisionerGroupHighAddress(MainActivity.this, String.valueOf(provisionerGroupHighAddress));
        Utils.setProvisionerUnicastRange(MainActivity.this, String.valueOf(provisonerUnicastRange));
        Utils.onGetNewProvisioner(MainActivity.this);
        Utils.updateProvisionerNetAppKeys(MainActivity.this, meshRootClass, meshName, meshUUID, appKeys, networkKey, true);
        updateJsonData();
        if (!Utils.isUserLoggedIn(MainActivity.this) && getResources().getBoolean(R.bool.bool_isCloudFunctionality)) {
            Utils.showToast(MainActivity.this, getString(R.string.str_login_to_use_cloud_label));
        }
    }

    public void autoConfigure() {

        mSettings = network.getSettings();
        if (/*!Utils.checkConfiguration(this) ||*/ (null == mAutoAddress)) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mProgress.hide();
                    makeToast("Network does not exist. Please create network");
                    UserApplication.trace("Network does not exists");
                }
            });
        } else {

            new Handler().post(new Runnable() {
                @Override
                public void run() {
                    mProvisioningInProgress = true;
                    mcp = new CustomProvisioning(false);

                    if (getResources().getBoolean(R.bool.bool_isFasterProvisioningSupported)) {
                        mcp = new CustomProvisioning(mCustomGroupId, true);
                    }
                    mUserDataRepository.getNewDataFromRemote("provision started==>" + mAutoAddress, LoggerConstants.TYPE_SEND);
                    mSettings.provision(MainActivity.this,
                            mAutoAddress,
                            mAutoDevice.getAddress(),
                            PROVISIONING_IDENTIFY_DURATION,
                            mProvisionCallback, mCapabilitiesLstnr, mProvisionerStateChanged, COMPLETION_DELAY, mcp);
                }
            });
        }
    }

    public class MyHandler extends Handler {

        private final WeakReference<MainActivity> mActivity;

        MyHandler(MainActivity activity) {
            super(Looper.getMainLooper());
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            final MainActivity activity = mActivity.get();
            Object[] args;
            if (activity == null) return;

            switch (msg.what) {
                case MSG_UPDATE_LIST:

                    break;
                case MSG_HIDE_PROGRESS:
                    long dt = System.currentTimeMillis() - activity.mProgress.startTime;
                    if (dt < progress.PROGRESS_MIN_DELAY) {
                        activity.mHandler.sendEmptyMessageDelayed(MSG_HIDE_PROGRESS, dt);
                        break;
                    }
                    activity.mProgress.hide();
                    break;
                case MSG_CONFIG:
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            activity.autoConfigure();
                        }
                    }, 100);
                    break;
                case MSG_TOAST:
                    Toast.makeText(activity, (String) msg.obj, Toast.LENGTH_SHORT).show();
                    msg.obj = null;
                    break;
                case MSG_DEVICE_APPEARED:

                    //activity.updateRequest((boolean) msg.obj);
                    break;
                case MSG_EXCEPTION:
                    activity.makeToast("Exception");
                    break;
                case MSG_ENABLE_BLUETOOTH:
                    enableBluetooth();
                    break;
                case MSG_UNKNOWN_DEVICE_NOTIFICATION:
                    activity.mUnknownDeviceDialog.createDialog();
                    break;
                case MSG_UPDATE_RSSI:

                    break;
                case MSG_UPDATE_NETWORK_STATUS:
                    args = (Object[]) msg.obj;
                    activity.onNetworkStatusChanged((boolean) args[0], (boolean) args[1]);
                    break;
                case MSG_OUT_OF_RANGE:

                    if (!isNear) {
                        mLostConnectionDialog.createDialog();
                    } else {
                        mLostConnectionDialog.hideDialog();
                    }

                    break;
                case MSG_UPDATE_RELIABLE_NODE_ROW:
                    tab = 1;
                    fragmentCommunication(new ProvisionedTabFragment().getClass().getName(), null, 0, null, false, null);
                    break;
            }
        }
    }

    public void restartNetwork() {
        Utils.showToast(MainActivity.this, "Restablishing Network Again.");

        if (mBluetoothAdapter == null) {
            mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        }

        if (mBluetoothAdapter.isEnabled()) {
            mBluetoothAdapter.disable();
        }
    }

    public defaultAppCallback mWriteLocalCallback = new defaultAppCallback() {
        @Override
        public void onWriteLocalData(mobleAddress peer, mobleAddress dst, Object cookies, short offset, byte count, byte[] data) {


            Utils.DEBUG(" VendorWrite Async CallBack source  : " + peer.toString());
            Utils.DEBUG(" VendorWrite Async CallBack destination  : " + dst.toString());
            Utils.DEBUG(" VendorWrite Async CallBack data : " + Utils.array2string(data));
            mUserDataRepository.getNewDataFromRemote("Vendor Async CallBack source  ==>" + peer, LoggerConstants.TYPE_RECEIVE);
            mUserDataRepository.getNewDataFromRemote("Vendor Async CallBack destination  ==>" + dst, LoggerConstants.TYPE_RECEIVE);
            mUserDataRepository.getNewDataFromRemote("Vendor Async CallBack data ==>" + Utils.array2string(data), LoggerConstants.TYPE_RECEIVE);


        }
    };

    public defaultAppCallback modelCallback_cb = new defaultAppCallback() {
        @Override
        public void modelCallback(ApplicationParameters.Address src, ApplicationParameters.Address dst) {

            Utils.DEBUG(" GenericOnOff Async CallBack source : " + src);
            Utils.DEBUG(" GenericOnOff Async CallBack  dst : " + dst);

            mUserDataRepository.getNewDataFromRemote("GenericOnOff Async CallBack source  ==>" + src, LoggerConstants.TYPE_RECEIVE);
            mUserDataRepository.getNewDataFromRemote("GenericOnOff Async CallBack destination ==>" + dst, LoggerConstants.TYPE_RECEIVE);


        }
    };


    private boolean isGattErrorNoified = false;
    /*public defaultAppCallback mOnGattError = new defaultAppCallback() {

        @Override
        public void onGattError(int status) {

            //disable provisioning dialog
            //disable bluetooth
            //show pop-up with gatt error
            if(!isGattErrorNoified)
            {
                Utils.showToast(MainActivity.this, "Gatt Error : " + String.valueOf(status));
                isGattErrorNoified = true;
                mProgress.hide();
                new Handler().post(new Runnable() {
                    @Override
                    public void run() {
                        app.stop();
                    }
                });
                Utils.showPopForGattError(MainActivity.this, "Error");
            }

        }
    };*/

    public defaultAppCallback mOnDeviceAppearedCallback = new defaultAppCallback() {
        @Override
        public void onDeviceAppeared(String bt_addr) {

            Utils.DEBUG(">>>>>>>>>>>>>>>>>>>>> DEVICE APPEARED : >>>>>>>>> " + bt_addr);
            onNewDeviceAppeared(bt_addr);
            /*if (!isTabUpdating) {

            }*/
        }
    };

    public void onNewDeviceAppeared(String bt_addr) {

        try {
            Future<DeviceCollection> futureED = null;
            Device device = null;
            try {
                futureED = ((UserApplication) getApplication()).mConfiguration.getNetwork().enumerateDevices();

                try {
                    collectionD = futureED.get();
                    device = collectionD.getDevice(bt_addr);

                } catch (InterruptedException e) {
                    UserApplication.trace("Interrupted exception");

                } catch (ExecutionException e) {
                    UserApplication.trace("Execution exception");
                }

            } catch (Exception e) {
            }

            if (mLostConnectionDialog != null && mLostConnectionDialog.mDialog != null) {
                if (mLostConnectionDialog.mDialog.isShowing()) {
                    mLostConnectionDialog.hideDialog();
                }
            }

            final Nodes node = new Nodes(0);
            node.setUUID(Utils.array2string(device.getUuid()) + "");
            node.setAddress(device.getAddress().toString());
            node.setRssi(String.valueOf(device.getmRssi()));
            node.setChecked(false);

            boolean isAlreadyAdded = false;
            for (int i = 0; i < mUnprovisionedList.size(); i++) {
                if (mUnprovisionedList.get(i).getAddress().equals(node.getAddress())) {
                    isAlreadyAdded = true;
                    break;
                }
            }

            if (!isAlreadyAdded) {
                mUnprovisionedList.add(node);
            }

            new Handler().post(new Runnable() {
                @Override
                public void run() {
                    fragmentCommunication(new UnprovisionedFragment().getClass().getName(), null,
                            0, node, false, null);
                }
            });
        } catch (Exception e) {
        }
    }

    public defaultAppCallback onDeviceRssiChangedCallback = new defaultAppCallback() {

        @Override
        public void onDeviceRssiChanged(final String bt_addr, final int mRssi) {
            super.onDeviceRssiChanged(bt_addr, mRssi);

            //Utils.DEBUG(">> RSSI Call Continue . . . ");
            new Handler().post(new Runnable() {
                @Override
                public void run() {
                    fragmentCommunication(new UnprovisionedFragment().getClass().getName(), bt_addr, mRssi, null, false, null);
                }
            });
        }
    };

    /*  True -> Connected
     * False -> Disconnected
     * @param prevStatus previous connection status.
     * @param newStatus new connection status.
     * @param prevStatus -> false and @param newStatus -> false, previously disconnected and remained disconnected.
     * @param prevStatus -> false and @param newStatus -> true, previously disconnected and then connected.
     * @param prevStatus -> true and @param newStatus -> false, previously connected and then disconnected.
     * @param prevStatus -> true and @param newStatus -> true, previously connected and remained connected.
     * On network status changed.
     *
     * @param prevStatus the prev status
     * @param newStatus  the new status*/

    public defaultAppCallback onNetworkStatusChanged = new defaultAppCallback() {

        @Override
        public void inRange(boolean prevStatus, boolean newStatus) {
            super.inRange(prevStatus, newStatus);
            Message msg = Message.obtain();
            msg.obj = new Object[]{prevStatus, newStatus};
            msg.what = MSG_UPDATE_NETWORK_STATUS;
            mHandler.sendMessage(msg);
        }
    };

    public void onNetworkStatusChanged(boolean prevStatus, boolean newStatus) {

        if ((!prevStatus && !newStatus) || (prevStatus && !newStatus)) {
            isNear = false;
        } else if ((!prevStatus && newStatus) || (prevStatus && newStatus)) {
            isNear = true;
        }
    }

    private static class UnknownDeviceNotificationDialog {

        WeakReference<Activity> mActivity;
        AlertDialog mDialog;

        UnknownDeviceNotificationDialog(Activity a) {
            mActivity = new WeakReference<Activity>(a);
        }

        void createDialog() {
            final MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;
            if (mDialog != null)
                return;
            if (activity.isFinishing())
                return;
            AlertDialog.Builder builder;
            builder = new AlertDialog.Builder(activity);
            builder
                    .setTitle(R.string.unknown)
                    .setCancelable(false)
                    .setMessage("Some of devices in the list is unknown because of incorrect removal. Please try to add or remove them again.")
                    .setPositiveButton(android.R.string.ok, new DialogListener(new Runnable() {
                        @Override
                        public void run() {
                            hideDialog();
                        }
                    }, null));
            mDialog = builder.create();
            mDialog.setCancelable(false);
            mDialog.setCanceledOnTouchOutside(false);

            //mDialog.show();
        }

        void hideDialog() {
            MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;

            if (mDialog == null)
                return;
            mDialog.getButton(DialogInterface.BUTTON_POSITIVE).setOnClickListener(null);
            mDialog.dismiss();
            mDialog = null;
        }
    }

    public progress mProgress = new progress(MainActivity.this, new progress.onEventListener() {

        @Override
        public void onCancel() {
            mProgress.hide();
            if (mProvisioningInProgress) {
                mProvisioningInProgress = false;
                mSettings.cancel();
            }
            try {
                ((UserApplication) getApplication()).mConfiguration.getNetwork().advise(onNetworkStatusChanged);
            } catch (Exception e) {
            }
        }

        @Override
        public void onShow() {

        }

        @Override
        public void onHide() {

        }
    });


    private void setCurrentNode(boolean call_group_command) {

        String uuid = "";
        if (nodeSelected != null) {
            if (nodeSelected.getAddress().equals(mAutoAddress)) {
                uuid = nodeSelected.getUUID();
            }
        }

        currentNode = new Nodes(nodeNumber);
        currentNode.setCid(mCid);
        currentNode.setPid(mPid);
        currentNode.setVid(mVid);
        currentNode.setCrpl(mCrpl);
        currentNode.setUUID(uuid + "");
        currentNode.setDeviceKey(Utils.array2string(mobleNetwork.getaDeviceKey()) + "");
        currentNode.setAddress(mAutoAddress + "");
        currentNode.setConfigured("true");
        currentNode.setConfigComplete(true);
        currentNode.setSubtitle("");
        currentNode.setM_address(mAutoDevice.getAddress() + "");
        currentNode.setName(mAutoDevice.getName());
        currentNode.setTitle(mAutoDevice.getName());
        currentNode.setType("0");
        currentNode.setNumberOfElements(elementsSize);
        newElements = Utils.designElementsForCurrentNode(MainActivity.this, currentNode, meshRootClass);
        currentNode.setElements(newElements);

        try {
            if (Utils.getNodeFeatures(MainActivity.this) != null) {
                Features features = ParseManager.getInstance().fromJSON(new JSONObject(Utils.getNodeFeatures(MainActivity.this)), Features.class);
                currentNode.setFeatures(features);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        Utils.setProvisionedNodeData(MainActivity.this, currentNode, meshRootClass);
        updateJsonData();
        loader.hide();
        //Utils.updateElementsInJson(MainActivity.this, meshRootClass, newElements, true);
        //node provisioning done
        isProvisioningProcessLive = false;
        //element publication and subscription starts
        //updateJsonData();
        if (call_group_command) {
            elementCount = 0;
            isElementSubscribing = true;
            isElementPublishing = false;
            network.getSettings().addGroup(MainActivity.this, mAutoDevice.getAddress(), mobleAddress.deviceAddress(Integer.parseInt(currentNode.getElements().get(elementCount).getUnicastAddress())),/*1-sub address*/ mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), mSubscriptionListener);
            elementCount++;
        }
        //update provisioned list
        fragmentCommunication(new ProvisionedTabFragment().getClass().getName(), null, 0, null, false, null);
        fragmentCommunication(new GroupTabFragment().getClass().getName(), null, 0, null, false, null);
        //swipe to provisionedtab
        fragmentCommunication(new ModelTabFragment().getClass().getName(), null, 1, null, true, null);
    }

    public static class LostConnectionDialog {

        WeakReference<Activity> mActivity;
        AlertDialog mDialog;

        LostConnectionDialog(Activity a) {
            mActivity = new WeakReference<Activity>(a);
        }

        public void createDialog() {
            final MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;
            if (mDialog != null)
                return;
            mDialog = new ProgressDialog(activity);
            mDialog.setTitle(R.string.disconectedDialogTitle);
            mDialog.setMessage("Network is not in range. Please check if proxy node turned on and wait for connection");
            mDialog.setCanceledOnTouchOutside(false);
            mDialog.setOnCancelListener(new DialogListener(null, new Runnable() {
                @Override
                public void run() {
                    activity.onBackPressed();
                }
            }));


            if (!mDialog.isShowing()) {

                mDialog.show();
            }

        }


        void hideDialog() {
            MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;

            if (mDialog == null)
                return;
            mDialog.setOnCancelListener(null);
            mDialog.dismiss();
            mDialog = null;
        }
    }

    private static class IdentifyDialog {

        WeakReference<Activity> mActivity;

        AlertDialog mDialog;

        IdentifyDialog(Activity a) {
            mActivity = new WeakReference<Activity>(a);
        }

        void createDialog(final mobleSettings.Identifier identifier) {
            final MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;
            if (mDialog != null)
                return;
            if (activity.isFinishing())
                return;
            identifier.setIdentified(true);
        }

        void hideDialog() {
            MainActivity activity = (MainActivity) mActivity.get();
            if (activity == null)
                return;

            if (mDialog == null)
                return;
            mDialog.getButton(DialogInterface.BUTTON_NEGATIVE).setOnClickListener(null);
            mDialog.getButton(DialogInterface.BUTTON_POSITIVE).setOnClickListener(null);
            mDialog.dismiss();
            mDialog = null;
        }
    }

    void makeToast(String text) {
        Message msg = Message.obtain();
        msg.what = MSG_TOAST;
        msg.obj = text;
        mHandler.sendMessage(msg);
    }

    public final mobleSettings.provisionerStateChanged mProvisionerStateChanged = new mobleSettings.provisionerStateChanged() {
        @Override
        public void onStateChanged(final int state, final String label) {
            provisioningStep = state;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mUserDataRepository.getNewDataFromRemote("Provisioning ==>" + (state + 1) * 10, LoggerConstants.TYPE_RECEIVE);
                    mProgress.setProgress(state + 1, "Provisioning . . . \n" + label);

                    /*if(state == 8)
                    {
                        fragmentCommunication(new ModelTabFragment().getClass().getName(), null, 1, null, true);
                    }*/
                }
            });
        }
    };

    // Listener for requests to MoBLE Settings. Handles autoConfigurecompleted
    public final mobleSettings.onProvisionComplete mProvisionCallback = new mobleSettings.onProvisionComplete() {
        @Override
        public void onCompleted(byte status) {
            mProvisioningInProgress = false;
            mobleAddress mobleAddress = com.msi.moble.mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP);

            if (status == mobleProvisioningStatus.SUCCESS) {
                mUserDataRepository.getNewDataFromRemote(" provisioning successful", LoggerConstants.TYPE_RECEIVE);
                Intent i = new Intent(MainActivity.this, ProvisionAddConfigurationActivity.class);
                startActivityForResult(i, PROVSIONING_RESULT_CODE);
            } else {
                makeToast("Provisioning unsuccessful,Please reset the device !");
            }
        }
    };

    public final mobleSettings.capabilitiesListener mCapabilitiesLstnr = new mobleSettings.capabilitiesListener() {
        @Override
        public void onCapabilitiesReceived(mobleSettings.Identifier identifier, Byte elementsNumber) {
            mUserDataRepository.getNewDataFromRemote("Capabilities Listener==>" + "element supported==>" + elementsSize, LoggerConstants.TYPE_RECEIVE);
            if (getResources().getBoolean(R.bool.bool_isElementFunctionality)) {
                elementsSize = elementsNumber;
            } else {
                elementsSize = 1;
            }

            mIdentifyDialog.createDialog(identifier);
        }
    };

    public final defaultAppCallback mProxyConnectionEventCallback = new defaultAppCallback() {

        @Override
        public void onProxyConnectionEvent(boolean process, String proxyAddress) {
            mProxyAddress = proxyAddress;

            if (mProxyAddress != null) {
                Utils.DEBUG("Proxy Mac = " + proxyAddress);

                isNear = true;
                Utils.setProxyNode(MainActivity.this, proxyAddress);
                mLostConnectionDialog.hideDialog();

                //update ui for proxy node
                fragmentCommunication(new ProvisionedTabFragment().getClass().getName(), null, 0, null, false, null);


            } else {
                isNear = false;
                if (mLostConnectionDialog.mDialog != null) {
                    if (!mLostConnectionDialog.mDialog.isShowing()) {
                        mLostConnectionDialog.createDialog();
                    }
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
            if (status == ApplicationParameters.Status.SUCCESS) {
                UserApplication app = (UserApplication) getApplication();
                Log.i("MultiElement", "1 PUBLISH_SUCCESS_PROV");


                if (isElementPublishing && elementCount < elementsSize) {

                    UserApplication.trace(" >>Ele Published : " + elementCount);
                    app.mConfiguration.getNetwork().getSettings().setPublicationAddress(MainActivity.this, mAutoDevice.getAddress(), mobleAddress.deviceAddress(Integer.parseInt(currentNode.getElements().get(elementCount).getUnicastAddress())),/*2-pub address*/ GroupEntry.LIGHTS_GROUP, mPublicationListener);
                    elementCount++;

                } else if (elementCount == elementsSize) {
                    isElementPublishing = false;
                    isElementSubscribing = false;
                    elementCount = 0;

                } else {

                    //add lights group
                    try {
                        if (meshRootClass.getGroups().isEmpty()) {

                            Utils.addNewGroupToJson(MainActivity.this, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), getString(R.string.str_default_group_label));
                        }
                    } catch (Exception e) {

                        Utils.addNewGroupToJson(MainActivity.this, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), getString(R.string.str_default_group_label));
                    }

                    //updateJsonData();

                    new Handler().post(new Runnable() {
                        @Override
                        public void run() {
                            loader.show();
                            setCurrentNode(true);
                        }
                    });

                }

            } else {
                Log.i("publicationStatus", "PUBLISH_FAIL_PROV");
            }

        }
    };


    public final ConfigurationModelClient.ConfigModelSubscriptionStatusCallback mSubscriptionListener = new ConfigurationModelClient.ConfigModelSubscriptionStatusCallback() {
        @Override
        public void onModelSubscriptionStatus(boolean timeout, ApplicationParameters.Status status, ApplicationParameters.Address address, ApplicationParameters.Address subAddress, ApplicationParameters.GenericModelID model) {
            UserApplication app = (UserApplication) getApplication();
            if (mAutoAddress != null) {
                if (timeout) {
                    UserApplication.trace("Retrying to subscribe group");
                    switch (mAutoDevice.getDeviceType()) {
                        case 0:
                            network.getSettings().addGroup(MainActivity.this, mAutoDevice.getAddress(), mAutoDevice.getAddress(), mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), mSubscriptionListener);
                            break;
                        default:
                            Log.i("log", "Incorrect Device Type");
                            break;

                    }
                } else {
                    mProgress.hide();
                    if (status == ApplicationParameters.Status.SUCCESS) {

                        int check = GroupEntry.LIGHTS_GROUP;

                        if (isElementSubscribing && (elementCount < elementsSize)) {
                            UserApplication.trace(" >>Ele Subscribed : " + elementCount);
                            network.getSettings().addGroup(MainActivity.this, mAutoDevice.getAddress(), mobleAddress.deviceAddress(Integer.parseInt(currentNode.getElements().get(elementCount).getUnicastAddress())), mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP), mSubscriptionListener);
                            elementCount++;

                        } else if (elementCount == elementsSize) {
                            elementCount = 0;
                            isElementPublishing = true;
                            isElementSubscribing = false;
                            app.mConfiguration.getNetwork().getSettings().setPublicationAddress(MainActivity.this, mAutoDevice.getAddress(), mobleAddress.deviceAddress(Integer.parseInt(currentNode.getElements().get(elementCount).getUnicastAddress())),/*2-pub address*/ GroupEntry.LIGHTS_GROUP, mPublicationListener);
                            elementCount++;
                        } else {
                            network.getSettings().setPublicationAddress(MainActivity.this, mAutoDevice.getAddress(), mAutoDevice.getAddress(),/*2-pub address*/ GroupEntry.LIGHTS_GROUP, mPublicationListener);
                        }

                        app.mConfiguration.setPublication(String.valueOf(mAutoDevice.getAddress()), mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP).toString());
                        app.save();


                    } else {
                        makeToast("Device has not been recognized");
                    }

                    new Handler().post(new Runnable() {
                        @Override
                        public void run() {
                            adviseCallbacks();
                        }
                    });
                    //updateRequest(true);


                }

            }
        }
    };

    public void callLogoutApi(final String userKey) {
        String tag_json_obj = "json_obj_req";
        String url = getString(R.string.URL_BASE) + getString(R.string.URL_MED) + getString(R.string.API_LogOut);

        loader.show();
        JSONObject requestObject = new JSONObject();
        try {
            requestObject.put("userKey", userKey);

        } catch (Exception e) {
            Utils.ERROR("Error while creating json request : " + e.toString());
        }
        MyJsonObjectRequest jsonObjReq = new MyJsonObjectRequest(
                false,
                MainActivity.this,
                Request.Method.POST,
                url,
                requestObject,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        if (response == null) {
                            return;
                        }
                        Utils.DEBUG("Logout onResponse() called : " + response.toString());

                        try {
                            CloudResponseData cloudResponseData = ParseManager.getInstance().fromJSON(response, CloudResponseData.class);
                            if (cloudResponseData.getStatusCode() == 110) {
                                Utils.showToast(MainActivity.this, cloudResponseData.getErrorMessage());
                            } else {
                                Utils.setLoginData(MainActivity.this, "");
                                Utils.setUserLoginKey(MainActivity.this, "");
                                Utils.setProvisioner(MainActivity.this, "");
                                //Utils.setProvisionerUUID(MainActivity.this, "");
                                Utils.setUserRegisteredToDownloadJson(MainActivity.this, "false");
                                /*if(meshRootClass.getNodes() == null || meshRootClass.getNodes().size() == 0)
                                {
                                    Utils.setUserRegisteredToDownloadJson(MainActivity.this,"false");
                                }*/
                                Utils.showToast(MainActivity.this, getString(R.string.str_logout_success_label));
                            }

                            openDrawer();
                        } catch (Exception e) {
                        }
                        loader.hide();
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Utils.ERROR("Error: " + error);
                //Utils.showToast(getActivity(), getString(R.string.string_common_error_message));
                loader.hide();
            }
        }
        );
        // Adding request to request queue
        UserApplication.getInstance().addToRequestQueue(jsonObjReq, tag_json_obj);
    }

    public void callLoginApi(final String username, final String password) {
        String tag_json_obj = "json_obj_req";
        String url = getString(R.string.URL_BASE) + getString(R.string.URL_MED) + getString(R.string.API_LoginDetails);

        if (loader != null) loader.show();

        JSONObject requestObject = new JSONObject();
        try {
            requestObject.put("lUserName", username);
            requestObject.put("lPassword", password);

        } catch (Exception e) {
            Utils.ERROR("Error while creating json request : " + e.toString());
        }
        MyJsonObjectRequest jsonObjReq = new MyJsonObjectRequest(
                false,
                MainActivity.this,
                Request.Method.POST,
                url,
                requestObject,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        if (response == null) {
                            return;
                        }
                        Utils.DEBUG("Login onResponse() called : " + response.toString());

                        try {
                            LoginData loginData = ParseManager.getInstance().fromJSON(response, LoginData.class);
                            if (loginData.getStatusCode() == 101) {
                                Utils.showToast(MainActivity.this, getString(R.string.str_login_warning_label));
                                //error show pop
                                if (meshRootClass.getMeshUUID() == null) {
                                    Utils.showPopUp(MainActivity.this, new MainActivity().getClass().getName(), true, false, getResources().getString(R.string.str_create_network_msg_label), getResources().getString(R.string.str_login_import_label));
                                }
                            } else if (loginData.getStatusCode() == 0) {
                                //success
                                LoginData loginData1 = new LoginData();
                                loginData1.setUserName(username);
                                loginData1.setUserPassword(password);
                                loginData1.setUserKey(loginData.getResponseMessage());
                                String loginDataString = ParseManager.getInstance().toJSON(loginData1);
                                Utils.setLoginData(MainActivity.this, loginDataString);
                                Utils.setUserLoginKey(MainActivity.this, loginData.getResponseMessage());
                                Utils.setPreviousUserLoginKey(MainActivity.this, loginData.getResponseMessage());

                                Utils.DEBUG("Login Data : " + Utils.getLoginData(MainActivity.this));
                                Utils.showToast(MainActivity.this, getString(R.string.str_session_restarted_label));
                                updateJsonData();

                                loader.hide();
                                try {
                                    resumeNetworkAndCallbacks("", meshRootClass.getMeshUUID(), false);
                                } catch (Exception e) {
                                }

                            }

                        } catch (Exception e) {
                        }
                        loader.hide();
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Utils.ERROR("Error: " + error);
                //Utils.showToast(getActivity(), getString(R.string.string_common_error_message));
                loader.hide();
            }
        }
        );
        // Adding request to request queue
        UserApplication.getInstance().addToRequestQueue(jsonObjReq, tag_json_obj);
    }


    private void doRestProvisionSubscription(int is_first_time) {
        UserApplication.trace("doRestProvision=> inside");
        publication_first_time = is_first_time;
        mobleAddress Nodeaddres = mAutoDevice.getAddress();

        if (is_first_time == 0) {
            UserApplication.trace("doRestProvisionSubscription First Time");
            nextElementAddress = mobleAddress.deviceAddress(Integer.parseInt(String.valueOf(Nodeaddres), 16));

        } else {
            UserApplication.trace("doRestProvisionSubscription Not first Time");
            nextElementAddress = mobleAddress.deviceAddress(nextElementAddress.mValue + 1);
        }

        UserApplication.trace("nextElementAddress = " + nextElementAddress);
        UserApplication.trace("doRestProvision=> element_counter===>" + nextElementAddress + "nextElementAddress=>" + nextElementAddress);
        String address_str = Utils.getsubscriptiongroupAddressOnProvsioning(this);
        if (address_str.startsWith("c") || address_str.startsWith("C")) {

            UserApplication.trace("doRestProvision=> default");
            app.mConfiguration.getNetwork().getSettings().addGroup(MainActivity.this, Nodeaddres, nextElementAddress, mobleAddress.groupAddress
                    (Integer.parseInt(address_str, 16)), mSubscriptionListener1);
        } else {
            UserApplication.trace("doRestProvision=> element");
            app.mConfiguration.getNetwork().getSettings().addGroup
                    (this, mAutoDevice.getAddress(), mAutoDevice.getAddress(),
                            mobleAddress.groupAddress
                                    (Integer.parseInt(address_str))
                            , mSubscriptionListener1);
        }

        mUserDataRepository.getNewDataFromRemote("Subscription started for ==>" + address_str, LoggerConstants.TYPE_SEND);

    }


    public final ConfigurationModelClient.ConfigModelSubscriptionStatusCallback mSubscriptionListener1 = new ConfigurationModelClient.ConfigModelSubscriptionStatusCallback() {
        @Override
        public void onModelSubscriptionStatus(boolean timeout, ApplicationParameters.Status status, ApplicationParameters.Address address, ApplicationParameters.Address subAddress, ApplicationParameters.GenericModelID model) {
            mProgress.hide();
            if (mAutoAddress != null) {
                if (timeout) {
                    mUserDataRepository.getNewDataFromRemote("Subscription Status timeout ==>" + address, LoggerConstants.TYPE_RECEIVE);
                    UserApplication.trace("doRestProvision=> subs timeout retry");
                    UserApplication.trace("Retrying to subscribe group");
                    makeToast("Timeout on Subscription");
                    showRetryOption("Subscription");
                } else {

                    if (status == ApplicationParameters.Status.SUCCESS) {
                        UserApplication.trace("doRestProvision=> subs success for address " + address);
                        mUserDataRepository.getNewDataFromRemote("Subscription Status Success ==>" + address, LoggerConstants.TYPE_RECEIVE);
                        //call publication
                        doRestProvisionPublication();

                    } else {
                        UserApplication.trace("doRestProvision=>subs null");
                        mUserDataRepository.getNewDataFromRemote("Subscription Status Null ==>" + address, LoggerConstants.TYPE_RECEIVE);

                        makeToast("Device has not been recognized");
                        showRetryOption("Subscription");
                    }

                    //adviseCallbacks();


                }

            }
        }
    };


    private void doRestProvisionPublication() {
        UserApplication app = (UserApplication) getApplication();
        String address_str = Utils.getpublicationListAddressOnProvsioning(MainActivity.this);
        mobleAddress Nodeaddres = mAutoDevice.getAddress();
//        mobleAddress nextElementAddress;

//        if (publication_first_time == 0) {
//
//            UserApplication.trace("doRestProvisionPublication First Time");
//
//            nextElementAddress = mobleAddress.deviceAddress(Integer.parseInt(String.valueOf(Nodeaddres), 16));
//        } else {
//
//            UserApplication.trace("doRestProvisionPublication Not  First Time");
//
//            nextElementAddress = mobleAddress.deviceAddress(Utils.getNextElementNumber(this, meshRootClass.getNodes()));
//        }
//        UserApplication.trace("doRestProvision=> publication=>" + nextElementAddress);

        if (address_str.startsWith("c") || address_str.startsWith("C")) {
            UserApplication.trace("doRestProvision=> subs publication default called");
            app.mConfiguration.getNetwork().getSettings().setPublicationAddress(MainActivity.this, Nodeaddres,
                    nextElementAddress, /*GroupEntry.LIGHTS_GROUP*/Integer.parseInt(Utils.getpublicationListAddressOnProvsioning(MainActivity.this), 16),
                    mPublicationListener1);

        } else {
            UserApplication.trace("doRestProvision=> subs publication element called");

            app.mConfiguration.getNetwork().getSettings().setPublicationAddress(MainActivity.this, Nodeaddres,
                    nextElementAddress, Integer.parseInt(Utils.getpublicationListAddressOnProvsioning(MainActivity.this)),
                    mPublicationListener1);

        }
        mUserDataRepository.getNewDataFromRemote("Publication Sent for ==>" + address_str, LoggerConstants.TYPE_SEND);
        app.mConfiguration.setPublication(String.valueOf(mAutoDevice.getAddress()), mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP).toString());
        app.save();

    }


    private final ConfigurationModelClient.ConfigModelPublicationStatusCallback mPublicationListener1 = new ConfigurationModelClient.ConfigModelPublicationStatusCallback() {

        @Override
        public void onModelPublicationStatus(boolean b, ApplicationParameters.Status status, ApplicationParameters.Address address,
                                             ApplicationParameters.Address address1, ApplicationParameters.KeyIndex keyIndex,
                                             ApplicationParameters.TTL ttl, ApplicationParameters.Time time,
                                             ApplicationParameters.GenericModelID genericModelID) {
            if (status == ApplicationParameters.Status.SUCCESS) {
                mUserDataRepository.getNewDataFromRemote("Publication Status Success ==>" + address, LoggerConstants.TYPE_RECEIVE);
                UserApplication.trace("doRestProvision=> pubs success");
                Log.i("MultiElement", "1 PUBLISH_SUCCESS_PROV");
                try {
                    if (meshRootClass.getGroups().isEmpty()) {
                        UserApplication.trace("doRestProvision=> pubs create group if not present");
                        Utils.addNewGroupToJson(MainActivity.this, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP),
                                getString(R.string.str_default_group_label));
                    }
                } catch (Exception e) {
                    UserApplication.trace("doRestProvision=> pubs create group if not present execption");
                    Utils.addNewGroupToJson(MainActivity.this, mobleAddress.groupAddress(GroupEntry.LIGHTS_GROUP),
                            getString(R.string.str_default_group_label));
                }
                //updateJsonData();
                if (element_counter == elementsSize) {
                    UserApplication.trace("doRestProvision=> pubs setCurrentNode");
                    mUserDataRepository.getNewDataFromRemote("Set Current Node ==>" + address, LoggerConstants.TYPE_SEND);
                    //setCurrentNode(false);
                }
                if (element_counter < (elementsSize)) {
                    UserApplication.trace("Element couner => " + element_counter);
                    UserApplication.trace("elementsSize  => " + elementsSize);
                    //call subscription for e1=e1+1 address
                    element_counter++;
                    doRestProvisionSubscription(1);
                }
            } else {
                makeToast("Publication failed,reset the device");
                showRetryOption("Publication");
                Log.i("publicationStatus", "PUBLISH_FAIL_PROV");
            }
        }
    };

    private void showRetryOption(final String from) {
        AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);
        dialog.setCancelable(false);
        dialog.setTitle("Alert");
        dialog.setMessage(from + " failed ! Please Reset the Node.");
        dialog.setPositiveButton("Okay", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                /*if(from.equalsIgnoreCase("Publication")){
                    doRestProvisionPublication();
                }else
                {
                    doRestProvisionSubscription(0);

                }*/
                dialog.dismiss();
            }
        });
             /*   .setNegativeButton("No ", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });*/

        final AlertDialog alert = dialog.create();
        alert.show();
    }


    void registerObersever() {
        mUserDataRepository = UserDataRepository.getInstance();
        mUserDataRepository.registerObserver(this);

//        mUserDataRepository.getNewDataFromRemote("Logging started..");

    }


    @Override
    public void onUserDataChanged(String logs, String type) {


    }

    @Override
    public Context getContext() {
        return MainActivity.this;
    }

    public Group getGroupData() {
        GroupSettingFragment fragmentByTag = (GroupSettingFragment) getSupportFragmentManager().findFragmentByTag(new GroupSettingFragment().getClass().getName());
        return fragmentByTag.getGroupData();
    }

    public NodeSettings getNodeData() {
        NodeSettingFragment fragmentByTag = (NodeSettingFragment) getSupportFragmentManager().findFragmentByTag(new NodeSettingFragment().getClass().getName());
        return fragmentByTag.getNodeData();
    }

    //RUNTIME PERMISSION **************************************************************************
    public boolean checkPermission() {
        int result = ContextCompat.checkSelfPermission(getApplicationContext(), ACCESS_FINE_LOCATION);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);

        return result == PackageManager.PERMISSION_GRANTED && result1 == PackageManager.PERMISSION_GRANTED;
    }

    public void requestPermission() {

        ActivityCompat.requestPermissions(this, new String[]{ACCESS_FINE_LOCATION, WRITE_EXTERNAL_STORAGE}, PERMISSION_REQUEST_CODE);

    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[],
                                           int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE:
                if (grantResults.length > 0) {

                    boolean locationAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED;
                    boolean storageAccepted = grantResults[1] == PackageManager.PERMISSION_GRANTED;

                    if (locationAccepted && storageAccepted) {
                        Snackbar.make(navigationView, "Permission Granted.", Snackbar.LENGTH_LONG).show();
                        enablePermissions();
                    } else {

                        Snackbar.make(navigationView, "Permission Denied, Please Goto Setting-->Permission-->Turn On permissions to access the App", Snackbar.LENGTH_LONG).show();

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (shouldShowRequestPermissionRationale(ACCESS_FINE_LOCATION)) {
                                showMessageOKCancel("", "You need to allow access to both the permissions",
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                                    requestPermissions(new String[]{ACCESS_FINE_LOCATION, WRITE_EXTERNAL_STORAGE},
                                                            PERMISSION_REQUEST_CODE);
                                                }
                                            }
                                        }, true);
                                return;
                            } else {


                                showMessageOKCancel("Permission Denied !", "Please Goto Settings ---> find Permission option ---> Turn On both the permissions to access the App",
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                Intent intent = new Intent();
                                                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                                Uri uri = Uri.fromParts("package", getPackageName(), null);
                                                intent.setData(uri);
                                                startActivityForResult(intent, PERMISSION_SETTING);
                                            }
                                        }, true);


                            }
                        }

                    }
                }


                break;
        }
    }


    private void showMessageOKCancel(String title, String
            message, DialogInterface.OnClickListener okListener, boolean is_request_permission) {
        new AlertDialog.Builder(MainActivity.this)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton("OK", okListener)
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Toast.makeText(MainActivity.this, "permission is required !", Toast.LENGTH_SHORT).show();
                        finish();
                    }
                })
                .create()
                .show();
    }

}

